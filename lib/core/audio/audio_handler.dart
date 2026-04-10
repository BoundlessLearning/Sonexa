import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ohmymusic/core/utils/diagnostic_logger.dart';

export 'package:audio_service/audio_service.dart' show AudioServiceRepeatMode;

enum PlaybackMode {
  sequential,
  shuffle,
  repeatOne,
  repeatAll,
}

class MusicAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  static const Duration _playerOperationTimeout = Duration(seconds: 12);
  static const Duration _seekGuardWindow = Duration(seconds: 3);

  MusicAudioHandler()
      : _player = AudioPlayer(),
        _playlist = ConcatenatingAudioSource(children: []) {
    _init();
  }

  // ignore: prefer_final_fields — 播放器可能需要在严重错误后重建
  AudioPlayer _player;
  ConcatenatingAudioSource _playlist;

  bool _skipInProgress = false;

  // ── [Round8-F3] 自维护 currentIndex ──
  // _player.currentIndex 依赖 just_audio 的异步 stream pipeline
  // （playbackEvent → _currentIndexSubject → sequenceState），
  // 在 auto-advance 后可能尚未更新。用户此时点击"下一首"会读到旧值。
  // 解决方案：在 sequenceStateStream 回调中维护自己的 _currentIndex，
  // skipToNext/skipToPrevious 使用此值而非 _player.currentIndex。
  int _currentIndex = 0;

  // ── 手动 Shuffle 实现 ──
  // just_audio_media_kit 的 setShuffleModeEnabled(true) 会破坏 currentIndex
  // （参见 just_audio_media_kit#3），所以我们不用它的 shuffle 功能，
  // 而是手动打乱队列顺序并重建 ConcatenatingAudioSource。
  bool _shuffleEnabled = false;
  /// shuffle 模式下保存的原始（未打乱的）队列顺序，用于恢复。
  List<MediaItem> _originalQueue = [];
  PlaybackMode _playMode = PlaybackMode.sequential;
  bool _pauseRequested = false;
  bool _recoveryInProgress = false;
  bool _completionAdvanceInProgress = false;
  final Random _random = Random();

  // ── 播放健康监控（Bug #4：进度条在走但没有声音） ──
  Timer? _healthCheckTimer;
  Duration _lastBufferedPosition = Duration.zero;
  int _staleBufferCount = 0;
  static const int _maxStaleBufferChecks = 3; // 3 次 × 5 秒 = 15 秒无缓冲推进则触发恢复
  int? _guardedSeekIndex;
  MediaItem? _guardedSeekItem;
  Duration? _guardedSeekResumePosition;
  DateTime? _seekGuardUntil;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<int?> get currentIndexStream =>
      playbackState.map((state) => state.queueIndex).distinct();
  Stream<bool> get playingStream => _player.playingStream;

  /// 当前是否处于手动 shuffle 模式
  bool get shuffleEnabled => _shuffleEnabled;

  bool get _seekGuardActive =>
      _seekGuardUntil != null && DateTime.now().isBefore(_seekGuardUntil!);

  /// 终端可见的诊断日志。
  /// Linux 桌面环境下 `dart:developer.log` 默认不输出到 stdout，
  /// 因此统一使用 debugPrint 作为调试主通道。
  void _diag(String message, {Object? error, StackTrace? stackTrace}) {
    unawaited(DiagnosticLogger.instance.log(message));
    if (error != null) {
      unawaited(DiagnosticLogger.instance.log('[DIAG] error=$error'));
    }
    if (stackTrace != null) {
      debugPrintStack(label: '[DIAG] stackTrace', stackTrace: stackTrace);
      unawaited(
        DiagnosticLogger.instance.log('[DIAG] stackTrace=$stackTrace'),
      );
    }
  }

  Future<T> _withTimeout<T>(Future<T> future, String operation) {
    return future.timeout(
      _playerOperationTimeout,
      onTimeout: () => throw TimeoutException(
        '$operation timed out after ${_playerOperationTimeout.inSeconds}s',
      ),
    );
  }

  void _startSeekGuard({
    required int index,
    required MediaItem? item,
    required Duration resumePosition,
  }) {
    _guardedSeekIndex = index;
    _guardedSeekItem = item;
    _guardedSeekResumePosition = resumePosition;
    _seekGuardUntil = DateTime.now().add(_seekGuardWindow);
    _diag('[DIAG] seek guard armed: index=$index, '
        'resumePosition=$resumePosition, title="${item?.title}"');
  }

  void _clearSeekGuard(String reason) {
    if (_guardedSeekIndex != null || _seekGuardUntil != null) {
      _diag('[DIAG] seek guard cleared: reason=$reason');
    }
    _guardedSeekIndex = null;
    _guardedSeekItem = null;
    _guardedSeekResumePosition = null;
    _seekGuardUntil = null;
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    _listenToPlaybackEvents();
    _listenToCurrentIndex();
    _listenToProcessingState();
    _startHealthCheck();
  }

  /// 用 .listen() 替代 .pipe()，防止错误关闭 playbackState sink
  void _listenToPlaybackEvents() {
    _player.playbackEventStream.listen(
      (event) {
        playbackState.add(_transformEvent(event));
      },
      onError: (Object error, StackTrace st) {
        _diag('[DIAG] playbackEvent ERROR: $error',
            error: error, stackTrace: st);
        // 发送一个安全的错误状态，而非让 sink 关闭
        playbackState.add(PlaybackState(
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.play,
            MediaControl.skipToNext,
          ],
          processingState: AudioProcessingState.error,
          playing: false,
          updatePosition: _player.position,
          queueIndex: _player.currentIndex,
        ));
      },
    );

    // [DIAG] 直接监听 currentIndexStream，观察 just_audio 原始 index 变化
    _player.currentIndexStream.listen((rawIndex) {
      _diag('[DIAG] currentIndexStream RAW: rawIndex=$rawIndex, '
          '_currentIndex=$_currentIndex, '
          'playing=${_player.playing}, '
          'processingState=${_player.processingState}');
    });
  }

  /// [F2 修复] 监听 sequenceStateStream，从 currentSource.tag 获取 MediaItem。
  /// 不做 ID 去重——直接 add，让 BehaviorSubject 的 downstream 自己 distinct()。
  /// 根因：之前的 ID 去重在 _safeSkipToIndex 提前 add 后，stream 回调被吞掉。
  /// [Round8-F3] 同时更新 _currentIndex，使 skipToNext/skipToPrevious
  /// 始终使用最新的曲目索引，不依赖 _player.currentIndex 的异步管道。
  void _listenToCurrentIndex() {
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) {
        _diag('[DIAG] sequenceState: null');
        return;
      }
      if (sequenceState.currentSource == null) {
        _diag('[DIAG] sequenceState: currentSource=null, '
            'index=${sequenceState.currentIndex}');
        return;
      }
      final tag = sequenceState.currentSource!.tag;
      final idx = sequenceState.currentIndex;
      final loopMode = sequenceState.loopMode;
      final shuffleMode = sequenceState.shuffleModeEnabled;
      if (_seekGuardActive &&
          _guardedSeekIndex != null &&
          idx != _guardedSeekIndex) {
        _diag('[DIAG] sequenceState IGNORED by seek guard: '
            'incomingIdx=$idx, guardedIdx=$_guardedSeekIndex, '
            'incomingTitle="${tag is MediaItem ? tag.title : '<non-media>'}"');
        return;
      }
      if (tag is MediaItem) {
        final prevIdx = _currentIndex;
        final prevTitle = mediaItem.valueOrNull?.title ?? '<null>';
        // 更新自维护的 currentIndex
        _currentIndex = idx;
        // 直接发送，不做去重。
        // sequenceStateStream 在 seek(index:), auto-advance, seekToNext() 等
        // 场景都会触发，确保 UI 总是反映当前实际播放的曲目。
        mediaItem.add(tag);
        _diag('[DIAG] sequenceState FIRED: '
            'prevIdx=$prevIdx→newIdx=$idx, '
            'prevTitle="$prevTitle"→newTitle="${tag.title}", '
            'songId=${tag.extras?['songId']}, '
            'loopMode=$loopMode, shuffleMode=$shuffleMode, '
            'playerPosition=${_player.position}, '
            '_player.currentIndex=${_player.currentIndex}');
        playbackState.add(_transformEvent(_player.playbackEvent));
      } else {
        _diag('[DIAG] sequenceState: tag is NOT MediaItem, '
            'tag.runtimeType=${tag.runtimeType}, idx=$idx');
      }
    });
  }

  /// 监听播放处理状态，在完成或出错时自动跳到下一首
  void _listenToProcessingState() {
    _player.processingStateStream.listen((state) {
      _diag('[DIAG] processingState: $state, '
          'index=${_player.currentIndex}, _currentIndex=$_currentIndex, '
          'playing=${_player.playing}, '
          'playMode=$_playMode, '
          'queueLen=${queue.value.length}, '
          'position=${_player.position}, '
          'duration=${_player.duration}');
      if (state == ProcessingState.idle && _seekGuardActive) {
        _diag('[DIAG] processingState idle during seek guard — '
            'triggering _retryCurrentTrack');
        unawaited(_retryCurrentTrack());
        return;
      }
      if (state == ProcessingState.completed) {
        _diag('[DIAG] ★ COMPLETED — playMode=$_playMode, '
            'index=${_player.currentIndex}/${queue.value.length}, '
            '_currentIndex=$_currentIndex');
        unawaited(_handleTrackCompleted());
      }
    });

    _player.playerStateStream.listen((state) {
      _diag('[DIAG] playerState: processing=${state.processingState}, '
          'playing=${state.playing}, '
          '_skipInProgress=$_skipInProgress, '
          'queueLen=${queue.value.length}, '
          '_currentIndex=$_currentIndex');
      if (_pauseRequested && !state.playing) {
        _diag('[DIAG] playerState after explicit pause — skip auto recovery');
        return;
      }
      if (state.processingState == ProcessingState.idle &&
          !_skipInProgress &&
          queue.value.isNotEmpty &&
          !state.playing) {
        if (_seekGuardActive) {
          _diag('[DIAG] Player IDLE during seek guard — keeping guarded track identity');
          final guardedIndex = _guardedSeekIndex;
          final guardedItem = _guardedSeekItem;
          if (guardedIndex != null &&
              guardedIndex >= 0 &&
              guardedIndex < queue.value.length) {
            _currentIndex = guardedIndex;
            mediaItem.add(guardedItem ?? queue.value[guardedIndex]);
          }
        }
        _diag('[DIAG] ⚠ Player IDLE with non-empty queue — '
            'scheduling recovery in 500ms');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_player.processingState == ProcessingState.idle &&
              queue.value.isNotEmpty &&
              !_skipInProgress &&
              !_pauseRequested) {
            _diag('[DIAG] ⚠ Player still IDLE after 500ms — '
                'triggering _attemptRecovery');
            _attemptRecovery();
          } else {
            _diag('[DIAG] Recovery cancelled: '
                'processingState=${_player.processingState}, '
                'queueEmpty=${queue.value.isEmpty}, '
                '_skipInProgress=$_skipInProgress');
          }
        });
      }
    });
  }

  /// [F5] 播放健康监控：检测 "播放中但无声音" 的异常状态。
  /// 每 5 秒检查 bufferedPosition 是否推进；如果连续 15 秒不推进且 playing=true，
  /// 判定为音频输出故障，触发恢复流程。
  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_player.playing) {
        _staleBufferCount = 0;
        _lastBufferedPosition = Duration.zero;
        return;
      }

      final currentBuffered = _player.bufferedPosition;
      final currentPosition = _player.position;
      final duration = _player.duration;

      // 如果已经播放到末尾，不算 stale
      if (duration != null &&
          currentPosition.inMilliseconds > 0 &&
          currentPosition >= duration - const Duration(seconds: 2)) {
        _staleBufferCount = 0;
        return;
      }

      // 正在 loading/buffering 状态不计算
      if (_player.processingState == ProcessingState.loading ||
          _player.processingState == ProcessingState.buffering) {
        _staleBufferCount = 0;
        _lastBufferedPosition = currentBuffered;
        return;
      }

      // 拖动进度条后的 seek 保护窗口内，不允许健康检查触发恢复。
      // 否则旧的 stale 计数会把一次正常 seek 误判成 15 秒卡死，
      // 提前调用 _attemptRecovery() 打断 seek 后的继续播放。
      if (_seekGuardActive) {
        _staleBufferCount = 0;
        _lastBufferedPosition = currentBuffered;
        return;
      }

      // 如果 bufferedPosition 没有推进
      if (currentBuffered == _lastBufferedPosition &&
          currentBuffered.inMilliseconds > 0) {
        _staleBufferCount++;
        _diag('[DIAG] Health check: stale buffer count=$_staleBufferCount, '
            'buffered=$currentBuffered, position=$currentPosition');
        if (_staleBufferCount >= _maxStaleBufferChecks) {
          _diag('[DIAG] Health check: buffered position stale for '
              '${_staleBufferCount * 5}s while playing — triggering recovery');
          _staleBufferCount = 0;
          _attemptRecovery();
        }
      } else {
        _staleBufferCount = 0;
      }
      _lastBufferedPosition = currentBuffered;
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (_player.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex,
    );
  }

  AudioSource _audioSourceFromItem(MediaItem item) {
    final isLocal = item.extras?['isLocal'] == true;
    final uri = isLocal ? Uri.file(item.id) : Uri.parse(item.id);
    return AudioSource.uri(uri, tag: item);
  }

  String _songIdOf(MediaItem item) =>
      item.extras?['songId'] as String? ?? item.id;

  Future<void> _normalizePlayerTransitionModes() async {
    await _player.setShuffleModeEnabled(false);
    await _player.setLoopMode(LoopMode.off);
  }

  void _syncCurrentTrack(int index, {required String reason}) {
    if (index < 0 || index >= queue.value.length) {
      return;
    }
    _currentIndex = index;
    mediaItem.add(queue.value[index]);
    playbackState.add(_transformEvent(_player.playbackEvent));
    _diag('[DIAG] track sync: reason=$reason, '
        'index=$index, title="${queue.value[index].title}", '
        'playMode=$_playMode');
  }

  int? _randomDifferentIndex(int currentIndex, int total) {
    if (total <= 0) {
      return null;
    }
    if (total == 1) {
      return 0;
    }

    var candidate = currentIndex;
    while (candidate == currentIndex) {
      candidate = _random.nextInt(total);
    }
    return candidate;
  }

  int? _resolveNextIndex() {
    final total = queue.value.length;
    if (total == 0) {
      return null;
    }

    return switch (_playMode) {
      PlaybackMode.sequential =>
        _currentIndex < total - 1 ? _currentIndex + 1 : null,
      PlaybackMode.shuffle => _randomDifferentIndex(_currentIndex, total),
      PlaybackMode.repeatOne => _currentIndex,
      PlaybackMode.repeatAll => (_currentIndex + 1) % total,
    };
  }

  int? _resolvePreviousIndex() {
    final total = queue.value.length;
    if (total == 0) {
      return null;
    }

    final restartCurrent = _player.position.inSeconds > 3;
    return switch (_playMode) {
      PlaybackMode.sequential => restartCurrent
          ? _currentIndex
          : (_currentIndex > 0 ? _currentIndex - 1 : null),
      PlaybackMode.shuffle => restartCurrent
          ? _currentIndex
          : _randomDifferentIndex(_currentIndex, total),
      PlaybackMode.repeatOne => _currentIndex,
      PlaybackMode.repeatAll => restartCurrent
          ? _currentIndex
          : (_currentIndex - 1 + total) % total,
    };
  }

  Future<void> _transitionToIndex(
    int index, {
    required String reason,
    bool resumeAfterSeek = false,
  }) async {
    if (index < 0 || index >= queue.value.length) {
      return;
    }

    await _player.seek(Duration.zero, index: index);
    _syncCurrentTrack(index, reason: reason);

    if (resumeAfterSeek && !_player.playing) {
      await _player.play();
    }
  }

  Future<void> _handleTrackCompleted() async {
    if (_completionAdvanceInProgress) {
      _diag('[DIAG] completed handling skipped: already in progress');
      return;
    }

    _completionAdvanceInProgress = true;
    try {
      final targetIndex = _resolveNextIndex();
      if (targetIndex == null) {
        _diag('[DIAG] completed handling: no next transition for playMode=$_playMode');
        return;
      }

      await _transitionToIndex(
        targetIndex,
        reason: 'completed',
        resumeAfterSeek: true,
      );
    } catch (e, st) {
      _diag('[DIAG] completed handling FAILED: $e',
          error: e, stackTrace: st);
    } finally {
      _completionAdvanceInProgress = false;
    }
  }

  /// 非破坏式重排当前队列，尽量避免 `setAudioSource()` 带来的位置归零与 stop 噪音。
  Future<void> _reorderQueuePreservingPlayback(
    List<MediaItem> targetItems, {
    required int currentIndexAfterReorder,
    required Duration position,
  }) async {
    final workingQueue = List<MediaItem>.from(queue.value);

    if (workingQueue.length != targetItems.length) {
      _diag('[DIAG] _reorderQueuePreservingPlayback: length mismatch, '
          'fallback to _rebuildAudioSource');
      await _rebuildAudioSource(targetItems, currentIndexAfterReorder, position);
      return;
    }

    for (var targetIndex = 0; targetIndex < targetItems.length; targetIndex++) {
      final targetSongId = _songIdOf(targetItems[targetIndex]);
      final sourceIndex = workingQueue.indexWhere(
        (item) => _songIdOf(item) == targetSongId,
      );

      if (sourceIndex < 0) {
        _diag('[DIAG] _reorderQueuePreservingPlayback: target song missing, '
            'fallback to _rebuildAudioSource');
        await _rebuildAudioSource(targetItems, currentIndexAfterReorder, position);
        return;
      }

      if (sourceIndex == targetIndex) {
        continue;
      }

      final movedItem = workingQueue.removeAt(sourceIndex);
      workingQueue.insert(targetIndex, movedItem);
      await _playlist.move(sourceIndex, targetIndex);
    }

    queue.add(List<MediaItem>.from(targetItems));
    _currentIndex = currentIndexAfterReorder;
    if (currentIndexAfterReorder >= 0 &&
        currentIndexAfterReorder < targetItems.length) {
      mediaItem.add(targetItems[currentIndexAfterReorder]);
    }

    _diag('[DIAG] _reorderQueuePreservingPlayback DONE: '
        'newIndex=$currentIndexAfterReorder, position=$position');
  }

  Future<void> loadAndPlay(
    List<MediaItem> items, {
    int initialIndex = 0,
  }) async {
    _diag('[DIAG] loadAndPlay: ${items.length} items, '
        'initialIndex=$initialIndex, '
        'playMode=$_playMode');
    _originalQueue = [];

    queue.add(items);

    if (items.isEmpty) {
      await _playlist.clear();
      mediaItem.add(null);
      return;
    }

    final sources = items.map(_audioSourceFromItem).toList();

    try {
      _playlist = ConcatenatingAudioSource(children: sources);
      await _withTimeout(
        _player.setAudioSource(_playlist, initialIndex: initialIndex),
        'loadAndPlay.setAudioSource',
      );

      // 同步自维护的 _currentIndex
      _currentIndex = initialIndex;

      // 初始 mediaItem 立即设置，不等 stream —— 只在 loadAndPlay 时做。
      if (initialIndex >= 0 && initialIndex < items.length) {
        mediaItem.add(items[initialIndex]);
      }

      await play();
    } on TimeoutException catch (e, st) {
      _diag('[DIAG] loadAndPlay TIMEOUT at index $initialIndex: $e',
          error: e, stackTrace: st);
      if (initialIndex < items.length - 1) {
        await loadAndPlay(items, initialIndex: initialIndex + 1);
      }
    } catch (e, st) {
      _diag('[DIAG] loadAndPlay FAILED at index $initialIndex: $e',
          error: e, stackTrace: st);
      // 如果首选曲目加载失败，尝试下一首
      if (initialIndex < items.length - 1) {
        _diag('[DIAG] Trying next track at index ${initialIndex + 1}');
        try {
          await _player.setAudioSource(_playlist,
              initialIndex: initialIndex + 1);
          _currentIndex = initialIndex + 1;
          if (initialIndex + 1 < items.length) {
            mediaItem.add(items[initialIndex + 1]);
          }
          await _player.play();
        } catch (retryError, retrySt) {
          _diag('[DIAG] Retry also failed: $retryError',
              error: retryError, stackTrace: retrySt);
        }
      }
    }
  }

  @override
  Future<void> play() async {
    _pauseRequested = false;
    _diag('[DIAG] play() called: '
        'processingState=${_player.processingState}, '
        'playing=${_player.playing}, '
        '_currentIndex=$_currentIndex, '
        'position=${_player.position}');

    if (_player.processingState == ProcessingState.idle &&
        queue.value.isNotEmpty) {
      _diag('[DIAG] play(): player is idle with non-empty queue, '
          'retry current track before normal play');
      await _retryCurrentTrack();
      return;
    }

    try {
      await _withTimeout(_player.play(), 'play');
      _diag('[DIAG] play() succeeded');
    } catch (e, st) {
      _diag('[DIAG] play() FAILED: $e', error: e, stackTrace: st);
      // 暂停后继续播放失败时，尝试重新加载当前曲目
      await _retryCurrentTrack();
    }
  }

  @override
  Future<void> pause() async {
    _pauseRequested = true;
    _diag('[DIAG] pause() called: '
        'playing=${_player.playing}, '
        '_currentIndex=$_currentIndex, '
        'position=${_player.position}');
    try {
      await _player.pause();
    } catch (e, st) {
      _diag('[DIAG] pause() FAILED: $e', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    _pauseRequested = false;
    _staleBufferCount = 0;
    _lastBufferedPosition = _player.bufferedPosition;
    final savedIndex = _currentIndex;
    final savedItem = mediaItem.valueOrNull;
    final resumePosition = _player.position;
    _diag('[DIAG] seek($position) called: '
        '_currentIndex=$_currentIndex, '
        'playing=${_player.playing}');
    _startSeekGuard(
      index: savedIndex,
      item: savedItem,
      resumePosition: resumePosition,
    );
    try {
      await _withTimeout(_player.seek(position), 'seek');
      Future<void>.delayed(_seekGuardWindow, () {
        if (_seekGuardActive && _guardedSeekIndex == savedIndex) {
          _clearSeekGuard('seek-window-expired');
        }
      });
    } on TimeoutException catch (e, st) {
      _currentIndex = savedIndex;
      if (savedItem != null) {
        mediaItem.add(savedItem);
      }
      _diag('[DIAG] seek() TIMEOUT: $e', error: e, stackTrace: st);
    } catch (e, st) {
      _currentIndex = savedIndex;
      if (savedItem != null) {
        mediaItem.add(savedItem);
      }
      _diag('[DIAG] seek() FAILED: $e', error: e, stackTrace: st);
    }
  }

  /// [Round7-F1] skipToNext 使用手动索引计算。
  /// [Round8-F3] 使用自维护的 _currentIndex 而非 _player.currentIndex，
  /// 避免 auto-advance 后 _player.currentIndex 尚未更新导致的跳转错误。
  @override
  Future<void> skipToNext() async {
    if (_skipInProgress) {
      _diag('[DIAG] skipToNext: BLOCKED — _skipInProgress=true');
      return;
    }
    _skipInProgress = true;
    try {
      final currentIdx = _currentIndex;
      final playerIdx = _player.currentIndex;
      final total = queue.value.length;
      _diag('[DIAG] skipToNext ENTER: '
          '_currentIndex=$currentIdx, '
          '_player.currentIndex=$playerIdx, '
          'total=$total, '
          'playMode=$_playMode, '
          'playing=${_player.playing}, '
          'position=${_player.position}, '
          'mediaItem="${mediaItem.valueOrNull?.title}"');
      if (total == 0) return;

      final nextIdx = _resolveNextIndex();
      if (nextIdx == null) {
        _diag('[DIAG] skipToNext: no next track available');
        return;
      }

      _diag('[DIAG] skipToNext: resolving to index $nextIdx');
      await _transitionToIndex(nextIdx, reason: 'skipToNext');
      _diag('[DIAG] skipToNext DONE: $currentIdx → $nextIdx, '
          '_player.currentIndex=${_player.currentIndex}');
    } catch (e, st) {
      _diag('[DIAG] skipToNext FAILED: $e', error: e, stackTrace: st);
      // 回退：用 setAudioSource 强制跳转
      final nextIdx = _currentIndex + 1;
      if (nextIdx < queue.value.length) {
        await _forceSkipToIndex(nextIdx);
      }
    } finally {
      _skipInProgress = false;
    }
  }

  /// [Round7-F1] skipToPrevious 使用手动索引计算。
  /// [Round8-F3] 使用自维护的 _currentIndex，理由同 skipToNext。
  @override
  Future<void> skipToPrevious() async {
    if (_skipInProgress) {
      _diag('[DIAG] skipToPrevious: BLOCKED — _skipInProgress=true');
      return;
    }
    _skipInProgress = true;
    try {
      final currentIdx = _currentIndex;
      final playerIdx = _player.currentIndex;
      _diag('[DIAG] skipToPrevious ENTER: '
          '_currentIndex=$currentIdx, '
          '_player.currentIndex=$playerIdx, '
          'position=${_player.position}, '
          'playMode=$_playMode');

      final total = queue.value.length;
      if (total == 0) return;

      final prevIdx = _resolvePreviousIndex();
      if (prevIdx == null) {
        _diag('[DIAG] skipToPrevious: no previous track available');
        return;
      }

      _diag('[DIAG] skipToPrevious: resolving to index $prevIdx');
      await _transitionToIndex(prevIdx, reason: 'skipToPrevious');
      _diag('[DIAG] skipToPrevious DONE: $currentIdx → $prevIdx');
    } catch (e, st) {
      _diag('[DIAG] skipToPrevious FAILED: $e', error: e, stackTrace: st);
      final prevIndex = _currentIndex - 1;
      if (prevIndex >= 0) {
        await _forceSkipToIndex(prevIndex);
      }
    } finally {
      _skipInProgress = false;
    }
  }

  /// [F4 修复] 不再提前 mediaItem.add(items[index])。
  /// mediaItem 更新统一由 _listenToCurrentIndex() 的 sequenceStateStream 驱动。
  /// 根因：提前 add 后，stream 回调因去重逻辑被吞掉，导致后续切歌 UI 不更新。
  Future<void> _safeSkipToIndex(int index) async {
    final items = queue.value;
    if (index < 0 || index >= items.length) return;

    _diag('[DIAG] _safeSkipToIndex($index): '
        '_currentIndex=$_currentIndex, '
        'title="${items[index].title}"');

    try {
      // 使用 seek 切换曲目，避免 setAudioSource 的全量重载。
      // mediaItem 更新由 sequenceStateStream listener 自动处理。
      await _player.seek(Duration.zero, index: index);
      _currentIndex = index;
      mediaItem.add(items[index]);
      _diag('[DIAG] _safeSkipToIndex($index) seek succeeded, '
          '_player.currentIndex=${_player.currentIndex}');
    } catch (e, st) {
      _diag('[DIAG] _safeSkipToIndex($index) seek FAILED: $e',
          error: e, stackTrace: st);
      // seek 失败时回退到 setAudioSource
      await _forceSkipToIndex(index);
    }
  }

  @override
  /// 跳转到播放队列中指定索引的歌曲
  Future<void> skipToQueueItem(int index) async {
    final items = queue.value;
    if (index < 0 || index >= items.length) return;
    await _safeSkipToIndex(index);
  }

  /// 播放出错时尝试跳到下一首；如果已是最后一首则停止
  void _trySkipOnError() {
    if (_skipInProgress || _pauseRequested) return;
    final currentIdx = _currentIndex;
    final total = queue.value.length;
    _diag('[DIAG] _trySkipOnError: currentIdx=$currentIdx, total=$total');
    if (currentIdx < total - 1) {
      _diag('[DIAG] Auto-skipping from $currentIdx to ${currentIdx + 1} after error');
      skipToNext();
    } else {
      _diag('[DIAG] Last track failed, stopping playback');
      _player.stop();
    }
  }

  void _publishRecoveryErrorState(Duration position) {
    playbackState.add(PlaybackState(
      controls: const [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
      ],
      processingState: AudioProcessingState.error,
      playing: false,
      updatePosition: position,
      queueIndex: _currentIndex,
    ));
  }

  /// [Round8-F5] 播放恢复失败时，用全新的 AudioSource 重新加载当前曲目。
  /// 重建 _playlist 以确保 HTTP 连接是全新的（解决长时间暂停后连接断开的问题）。
  Future<void> _retryCurrentTrack() async {
    if (_recoveryInProgress) {
      _diag('[DIAG] _retryCurrentTrack skipped: recovery already in progress');
      return;
    }
    _recoveryInProgress = true;
    final currentIdx = _seekGuardActive && _guardedSeekIndex != null
        ? _guardedSeekIndex!
        : _currentIndex;
    final items = queue.value;
    if (currentIdx < 0 || currentIdx >= items.length) {
      _diag('[DIAG] _retryCurrentTrack: index $currentIdx out of range, '
          'trying skipOnError');
      _trySkipOnError();
      return;
    }

    final resumePosition = _player.position;
    _diag('[DIAG] _retryCurrentTrack ENTER: index=$currentIdx, '
        'position=$resumePosition, '
        'title="${items[currentIdx].title}", '
        'processingState=${_player.processingState}');

    try {
      // 用全新的 AudioSource 实例重建 _playlist，
      // 确保 HTTP 连接是全新建立的
      final sources = items.map(_audioSourceFromItem).toList();
      _playlist = ConcatenatingAudioSource(children: sources);
      await _withTimeout(
        _player.setAudioSource(_playlist, initialIndex: currentIdx),
        '_retryCurrentTrack.setAudioSource',
      );
      _currentIndex = currentIdx;
      // 恢复到上次播放的位置
      if (resumePosition > Duration.zero) {
        await _withTimeout(
          _player.seek(resumePosition),
          '_retryCurrentTrack.seek',
        );
      }
      await _withTimeout(_player.play(), '_retryCurrentTrack.play');
      _diag('[DIAG] _retryCurrentTrack SUCCEEDED');
      _clearSeekGuard('_retryCurrentTrack-succeeded');
    } catch (e, st) {
      _diag('[DIAG] _retryCurrentTrack FAILED: $e',
          error: e, stackTrace: st);
      _publishRecoveryErrorState(resumePosition);
    } finally {
      _recoveryInProgress = false;
    }
  }

  /// [Round8-F5] 尝试恢复播放器：在音频设备丢失、长时间暂停后连接断开等
  /// 严重错误后重建播放器。
  /// 与之前的实现不同，这里会用 queue.value 重新创建 _playlist（全新的
  /// AudioSource.uri 实例），避免使用已经断开 HTTP 连接的旧 AudioSource 对象。
  Future<void> _attemptRecovery() async {
    if (_recoveryInProgress) {
      _diag('[DIAG] _attemptRecovery skipped: recovery already in progress');
      return;
    }
    _recoveryInProgress = true;
    final currentIdx = _seekGuardActive && _guardedSeekIndex != null
        ? _guardedSeekIndex!
        : _currentIndex;
    final position = _seekGuardActive && _guardedSeekResumePosition != null
        ? _guardedSeekResumePosition!
        : _player.position;
    final shouldResume = _player.playing || !_pauseRequested;
    final items = queue.value;

    _diag('[DIAG] _attemptRecovery ENTER: index=$currentIdx, '
        'position=$position, shouldResume=$shouldResume, '
        'queueSize=${items.length}, '
        'processingState=${_player.processingState}, '
        'title="${currentIdx >= 0 && currentIdx < items.length ? items[currentIdx].title : '<OOB>'}"');

    if (items.isEmpty) {
      _diag('[DIAG] _attemptRecovery: empty queue, aborting');
      return;
    }

    try {
      // 用 queue 中的 MediaItem 重新创建全新的 AudioSource 实例。
      // 这确保 HTTP 连接是全新建立的，不复用可能已断开的旧连接。
      final sources = items.map(_audioSourceFromItem).toList();
      _playlist = ConcatenatingAudioSource(children: sources);

      final safeIdx = currentIdx.clamp(0, items.length - 1);
      _diag('[DIAG] _attemptRecovery: setAudioSource at index=$safeIdx');
      await _withTimeout(
        _player.setAudioSource(_playlist, initialIndex: safeIdx),
        '_attemptRecovery.setAudioSource',
      );
      if (position > Duration.zero) {
        await _withTimeout(
          _player.seek(position),
          '_attemptRecovery.seek',
        );
      }
      // 手动同步 mediaItem
      mediaItem.add(items[safeIdx]);
      _currentIndex = safeIdx;

      if (shouldResume) {
        await _withTimeout(_player.play(), '_attemptRecovery.play');
      }
      _diag('[DIAG] _attemptRecovery SUCCEEDED: '
          '_player.currentIndex=${_player.currentIndex}, '
          'position=${_player.position}');
      _clearSeekGuard('_attemptRecovery-succeeded');
    } catch (e, st) {
      _diag('[DIAG] _attemptRecovery FAILED: $e',
          error: e, stackTrace: st);
      _publishRecoveryErrorState(position);
    } finally {
      _recoveryInProgress = false;
    }
  }

  /// 当 seekToNext/seekToPrevious 失败时，重新加载指定索引的音频源
  Future<void> _forceSkipToIndex(int index) async {
    final items = queue.value;
    if (index < 0 || index >= items.length) return;

    _diag('[DIAG] _forceSkipToIndex($index): '
        'title="${items[index].title}", '
        '_currentIndex=$_currentIndex');

    try {
      await _player.setAudioSource(_playlist, initialIndex: index);
      // forceSkip 是最后兜底手段，需要手动更新 mediaItem 和 _currentIndex
      _currentIndex = index;
      mediaItem.add(items[index]);
      await _player.play();
      _diag('[DIAG] _forceSkipToIndex($index) SUCCEEDED');
    } catch (e, st) {
      _diag('[DIAG] _forceSkipToIndex($index) FAILED: $e',
          error: e, stackTrace: st);
      if (index < items.length - 1) {
        await _forceSkipToIndex(index + 1);
      }
    }
  }

  @override
  Future<void> stop() async {
    _diag('[DIAG] stop() called');
    _healthCheckTimer?.cancel();
    await _player.stop();
    await _player.dispose();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) {
    _playMode = switch (repeatMode) {
      AudioServiceRepeatMode.none =>
        _playMode == PlaybackMode.shuffle ? PlaybackMode.shuffle : PlaybackMode.sequential,
      AudioServiceRepeatMode.all || AudioServiceRepeatMode.group => PlaybackMode.repeatAll,
      AudioServiceRepeatMode.one => PlaybackMode.repeatOne,
    };
    _shuffleEnabled = _playMode == PlaybackMode.shuffle;

    _diag('[DIAG] setRepeatMode: repeatMode=$repeatMode → playMode=$_playMode, '
        '_currentIndex=$_currentIndex, '
        'position=${_player.position}');

    return _normalizePlayerTransitionModes();
  }

  Future<void> setPlayMode(PlaybackMode mode) async {
    _playMode = mode;
    _shuffleEnabled = mode == PlaybackMode.shuffle;
    _diag('[DIAG] setPlayMode($mode): _currentIndex=$_currentIndex, '
        'position=${_player.position}');
    await _normalizePlayerTransitionModes();
  }

  /// [Round7-F1] 手动 Shuffle 实现。
  /// 不调用 _player.setShuffleModeEnabled() / _player.shuffle()，
  /// 因为 just_audio_media_kit#3 会导致 currentIndex 错乱。
  /// 改为：物理打乱 ConcatenatingAudioSource 的子项顺序，
  /// 当前播放曲目始终放在 index=0，然后 setAudioSource() 重新加载。
  /// 关闭 shuffle 时恢复原始队列顺序，定位到当前播放曲目的原始位置。
  Future<void> setShuffle(bool enabled, {bool rebuild = true}) async {
    _diag('[DIAG] setShuffle($enabled, rebuild=$rebuild) ENTER: '
        '_shuffleEnabled=$_shuffleEnabled, '
        '_currentIndex=$_currentIndex, '
        'position=${_player.position}, '
        'playing=${_player.playing}, '
        'playMode=$_playMode');
    if (enabled == _shuffleEnabled) {
      _diag('[DIAG] setShuffle: no-op, already $_shuffleEnabled');
      return;
    }
    _shuffleEnabled = enabled;
    _playMode = enabled ? PlaybackMode.shuffle : PlaybackMode.sequential;
    _originalQueue = [];
    await _normalizePlayerTransitionModes();
    _diag('[DIAG] setShuffle($enabled): logical mode only, '
        'physical queue preserved, playMode=$_playMode');
  }

  /// 重建 ConcatenatingAudioSource 并设置到播放器。
  /// 保持 [initialIndex] 位置和 [position] 进度不变。
  Future<void> _rebuildAudioSource(
    List<MediaItem> items,
    int initialIndex,
    Duration position,
  ) async {
    _diag('[DIAG] _rebuildAudioSource ENTER: '
        'items=${items.length}, initialIndex=$initialIndex, '
        'position=$position, '
        'playing=${_player.playing}');

    final sources = items.map(_audioSourceFromItem).toList();
    _playlist = ConcatenatingAudioSource(children: sources);

    _diag('[DIAG] _rebuildAudioSource: calling setAudioSource...');
    await _player.setAudioSource(_playlist, initialIndex: initialIndex);
    _diag('[DIAG] _rebuildAudioSource: setAudioSource done, '
        '_player.position=${_player.position}, '
        '_player.currentIndex=${_player.currentIndex}');

    // 同步自维护的 _currentIndex
    _currentIndex = initialIndex;
    if (position > Duration.zero) {
      _diag('[DIAG] _rebuildAudioSource: seeking to $position');
      await _player.seek(position);
      _diag('[DIAG] _rebuildAudioSource: seek done, '
          '_player.position=${_player.position}');
    }
    // 手动同步 mediaItem（setAudioSource 会触发 sequenceStateStream，
    // 但以防时序问题，这里也显式设置一次）
    if (initialIndex >= 0 && initialIndex < items.length) {
      mediaItem.add(items[initialIndex]);
    }
    _diag('[DIAG] _rebuildAudioSource DONE');
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await addToQueue(mediaItem);
  }

  Future<void> addToQueue(MediaItem item) async {
    final updatedQueue = [...queue.value, item];
    queue.add(updatedQueue);
    await _playlist.add(_audioSourceFromItem(item));
    // shuffle 模式下也同步到原始队列
    if (_shuffleEnabled) {
      _originalQueue = [..._originalQueue, item];
    }
  }

  Future<void> removeFromQueue(int index) async {
    final currentQueue = [...queue.value];
    if (index < 0 || index >= currentQueue.length) {
      return;
    }

    final removedItem = currentQueue[index];
    currentQueue.removeAt(index);
    queue.add(currentQueue);
    await _playlist.removeAt(index);

    // shuffle 模式下也从原始队列中移除
    if (_shuffleEnabled && _originalQueue.isNotEmpty) {
      _originalQueue.removeWhere((item) =>
          item.extras?['songId'] == removedItem.extras?['songId']);
    }

    if (currentQueue.isEmpty) {
      mediaItem.add(null);
      return;
    }
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    final currentQueue = [...queue.value];
    if (oldIndex < 0 || oldIndex >= currentQueue.length) {
      return;
    }

    if (newIndex < 0 || newIndex >= currentQueue.length) {
      return;
    }

    if (oldIndex == newIndex) {
      return;
    }

    final item = currentQueue.removeAt(oldIndex);
    currentQueue.insert(newIndex, item);

    queue.add(currentQueue);
    await _playlist.move(oldIndex, newIndex);
  }
}
