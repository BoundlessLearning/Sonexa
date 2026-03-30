import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

export 'package:audio_service/audio_service.dart' show AudioServiceRepeatMode;

class MusicAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
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

  // ── 播放健康监控（Bug #4：进度条在走但没有声音） ──
  Timer? _healthCheckTimer;
  Duration _lastBufferedPosition = Duration.zero;
  int _staleBufferCount = 0;
  static const int _maxStaleBufferChecks = 3; // 3 次 × 5 秒 = 15 秒无缓冲推进则触发恢复

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<bool> get playingStream => _player.playingStream;

  /// 当前是否处于手动 shuffle 模式
  bool get shuffleEnabled => _shuffleEnabled;

  /// 终端可见的诊断日志。
  /// Linux 桌面环境下 `dart:developer.log` 默认不输出到 stdout，
  /// 因此统一使用 debugPrint 作为调试主通道。
  void _diag(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint(message);
    if (error != null) {
      debugPrint('[DIAG] error=$error');
    }
    if (stackTrace != null) {
      debugPrintStack(label: '[DIAG] stackTrace', stackTrace: stackTrace);
    }
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
          'loopMode=${_player.loopMode}, '
          'queueLen=${queue.value.length}, '
          'position=${_player.position}, '
          'duration=${_player.duration}');
      if (state == ProcessingState.completed) {
        // ConcatenatingAudioSource 在 LoopMode.off 时会自动播放下一首，
        // 在 LoopMode.all 时会自动 wrap。不再手动调用 skipToNext()。
        // UI 更新由 _listenToCurrentIndex() 的 sequenceStateStream 负责。
        _diag('[DIAG] ★ COMPLETED — loopMode=${_player.loopMode}, '
            'index=${_player.currentIndex}/${queue.value.length}, '
            '_currentIndex=$_currentIndex');
      }
    });

    _player.playerStateStream.listen((state) {
      _diag('[DIAG] playerState: processing=${state.processingState}, '
          'playing=${state.playing}, '
          '_skipInProgress=$_skipInProgress, '
          'queueLen=${queue.value.length}, '
          '_currentIndex=$_currentIndex');
      if (state.processingState == ProcessingState.idle &&
          !_skipInProgress &&
          queue.value.isNotEmpty &&
          !state.playing) {
        _diag('[DIAG] ⚠ Player IDLE with non-empty queue — '
            'scheduling recovery in 500ms');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_player.processingState == ProcessingState.idle &&
              queue.value.isNotEmpty &&
              !_skipInProgress) {
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
      queueIndex: event.currentIndex,
    );
  }

  AudioSource _audioSourceFromItem(MediaItem item) {
    final isLocal = item.extras?['isLocal'] == true;
    final uri = isLocal ? Uri.file(item.id) : Uri.parse(item.id);
    return AudioSource.uri(uri, tag: item);
  }

  String _songIdOf(MediaItem item) =>
      item.extras?['songId'] as String? ?? item.id;

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

    if (position > Duration.zero) {
      await _player.seek(position, index: currentIndexAfterReorder);
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
        'shuffleEnabled=$_shuffleEnabled');
    // 新队列加载时重置 shuffle 状态
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
      await _player.setAudioSource(_playlist, initialIndex: initialIndex);

      // 同步自维护的 _currentIndex
      _currentIndex = initialIndex;

      // 初始 mediaItem 立即设置，不等 stream —— 只在 loadAndPlay 时做。
      if (initialIndex >= 0 && initialIndex < items.length) {
        mediaItem.add(items[initialIndex]);
      }

      // 如果当前 shuffle 模式已开启，立即打乱
      if (_shuffleEnabled) {
        // 先保存原始顺序，再触发 shuffle 逻辑
        _shuffleEnabled = false; // 临时关闭，让 setShuffle 能正确执行
        await setShuffle(true);
      } else {
        await play();
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
      await _player.play();
      _diag('[DIAG] play() succeeded');
    } catch (e, st) {
      _diag('[DIAG] play() FAILED: $e', error: e, stackTrace: st);
      // 暂停后继续播放失败时，尝试重新加载当前曲目
      await _retryCurrentTrack();
    }
  }

  @override
  Future<void> pause() async {
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
    _diag('[DIAG] seek($position) called: '
        '_currentIndex=$_currentIndex, '
        'playing=${_player.playing}');
    try {
      await _player.seek(position);
    } catch (e, st) {
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
          'loopMode=${_player.loopMode}, '
          'playing=${_player.playing}, '
          'position=${_player.position}, '
          'mediaItem="${mediaItem.valueOrNull?.title}"');
      if (total == 0) return;

      int nextIdx;
      if (currentIdx < total - 1) {
        nextIdx = currentIdx + 1;
      } else if (_player.loopMode == LoopMode.all) {
        // 列表循环模式下，末尾回到第一首
        nextIdx = 0;
      } else {
        _diag('[DIAG] skipToNext: no next track available');
        return;
      }

      _diag('[DIAG] skipToNext: seeking to index $nextIdx');
      await _player.seek(Duration.zero, index: nextIdx);
      // 立即更新自维护的 _currentIndex，不等 sequenceStateStream 异步回调
      _currentIndex = nextIdx;
      if (nextIdx >= 0 && nextIdx < queue.value.length) {
        mediaItem.add(queue.value[nextIdx]);
      }
      _diag('[DIAG] skipToNext DONE: $currentIdx → $nextIdx, '
          '_player.currentIndex=${_player.currentIndex}');
      // mediaItem 更新由 _listenToCurrentIndex() 的 sequenceStateStream 驱动
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
          'position=${_player.position}');

      // 如果当前播放超过 3 秒，回到曲目开头
      if (_player.position.inSeconds > 3) {
        _diag('[DIAG] skipToPrevious: position > 3s, '
            'seeking to beginning of current track');
        await _player.seek(Duration.zero);
        return;
      }

      final total = queue.value.length;
      if (total == 0) return;

      int prevIdx;
      if (currentIdx > 0) {
        prevIdx = currentIdx - 1;
      } else if (_player.loopMode == LoopMode.all) {
        // 列表循环模式下，开头回到最后一首
        prevIdx = total - 1;
      } else {
        _diag('[DIAG] skipToPrevious: no previous track available');
        return;
      }

      _diag('[DIAG] skipToPrevious: seeking to index $prevIdx');
      await _player.seek(Duration.zero, index: prevIdx);
      // 立即更新自维护的 _currentIndex
      _currentIndex = prevIdx;
      if (prevIdx >= 0 && prevIdx < queue.value.length) {
        mediaItem.add(queue.value[prevIdx]);
      }
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
    if (_skipInProgress) return;
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

  /// [Round8-F5] 播放恢复失败时，用全新的 AudioSource 重新加载当前曲目。
  /// 重建 _playlist 以确保 HTTP 连接是全新的（解决长时间暂停后连接断开的问题）。
  Future<void> _retryCurrentTrack() async {
    final currentIdx = _currentIndex;
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
      await _player.setAudioSource(_playlist, initialIndex: currentIdx);
      _currentIndex = currentIdx;
      // 恢复到上次播放的位置
      if (resumePosition > Duration.zero) {
        await _player.seek(resumePosition);
      }
      await _player.play();
      _diag('[DIAG] _retryCurrentTrack SUCCEEDED');
    } catch (e, st) {
      _diag('[DIAG] _retryCurrentTrack FAILED: $e',
          error: e, stackTrace: st);
      _trySkipOnError();
    }
  }

  /// [Round8-F5] 尝试恢复播放器：在音频设备丢失、长时间暂停后连接断开等
  /// 严重错误后重建播放器。
  /// 与之前的实现不同，这里会用 queue.value 重新创建 _playlist（全新的
  /// AudioSource.uri 实例），避免使用已经断开 HTTP 连接的旧 AudioSource 对象。
  Future<void> _attemptRecovery() async {
    final currentIdx = _currentIndex;
    final position = _player.position;
    final wasPlaying = _player.playing;
    final items = queue.value;

    _diag('[DIAG] _attemptRecovery ENTER: index=$currentIdx, '
        'position=$position, wasPlaying=$wasPlaying, '
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
      await _player.setAudioSource(_playlist, initialIndex: safeIdx);
      if (position > Duration.zero) {
        await _player.seek(position);
      }
      // 手动同步 mediaItem
      mediaItem.add(items[safeIdx]);
      _currentIndex = safeIdx;

      if (wasPlaying) {
        await _player.play();
      }
      _diag('[DIAG] _attemptRecovery SUCCEEDED: '
          '_player.currentIndex=${_player.currentIndex}, '
          'position=${_player.position}');
    } catch (e, st) {
      _diag('[DIAG] _attemptRecovery FAILED: $e',
          error: e, stackTrace: st);
      // 广播错误状态，让 UI 显示错误
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
        ],
        processingState: AudioProcessingState.error,
        playing: false,
        updatePosition: position,
        queueIndex: currentIdx,
      ));
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
    final loopMode = switch (repeatMode) {
      AudioServiceRepeatMode.none => LoopMode.off,
      AudioServiceRepeatMode.all ||
      AudioServiceRepeatMode.group => LoopMode.all,
      AudioServiceRepeatMode.one => LoopMode.one,
    };

    _diag('[DIAG] setRepeatMode: repeatMode=$repeatMode → loopMode=$loopMode, '
        'current _player.loopMode=${_player.loopMode}, '
        '_currentIndex=$_currentIndex, '
        'position=${_player.position}');

    return _player.setLoopMode(loopMode);
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
        'playing=${_player.playing}');
    if (enabled == _shuffleEnabled) {
      _diag('[DIAG] setShuffle: no-op, already $_shuffleEnabled');
      return;
    }
    _shuffleEnabled = enabled;

    final currentItems = queue.value;
    if (currentItems.isEmpty) return;

    // 获取当前正在播放的曲目（通过 tag，不依赖 currentIndex）
    final currentTag = _player.sequenceState?.currentSource?.tag as MediaItem?;
    final wasPlaying = _player.playing;
    final currentPosition = _player.position;

    if (enabled) {
      // ── 启用 Shuffle ──
      // 1. 保存原始队列顺序（用于恢复）
      _originalQueue = List<MediaItem>.from(currentItems);
      // 2. 创建打乱后的队列（当前曲目放 index=0）
      final shuffled = List<MediaItem>.from(currentItems);
      shuffled.shuffle();
      // 把当前播放的曲目移到最前面
      if (currentTag != null) {
        shuffled.removeWhere((item) =>
            item.extras?['songId'] == currentTag.extras?['songId']);
        shuffled.insert(0, currentTag);
      }
      // 3. 更新 queue，并尽量原地重排 playlist，避免触发 setAudioSource
      if (rebuild) {
        await _reorderQueuePreservingPlayback(
          shuffled,
          currentIndexAfterReorder: 0,
          position: currentPosition,
        );
      } else {
        queue.add(shuffled);
        _currentIndex = 0;
        mediaItem.add(shuffled[0]);
      }
      _diag('[DIAG] setShuffle(true): shuffled ${shuffled.length} items, '
          'current="${currentTag?.title}" at index=0');
    } else {
      // ── 关闭 Shuffle ──
      if (_originalQueue.isEmpty) return;
      // 找到当前曲目在原始队列中的位置
      int restoredIndex = 0;
      if (currentTag != null) {
        final songId = currentTag.extras?['songId'];
        restoredIndex = _originalQueue.indexWhere(
            (item) => item.extras?['songId'] == songId);
        if (restoredIndex < 0) restoredIndex = 0;
      }
      // 恢复原始队列
      if (rebuild) {
        await _reorderQueuePreservingPlayback(
          _originalQueue,
          currentIndexAfterReorder: restoredIndex,
          position: currentPosition,
        );
        _diag('[DIAG] setShuffle(false): restored original order, '
            'current="${currentTag?.title}" at index=$restoredIndex');
      } else {
        // 不重建播放器，只切换逻辑上的 shuffle 开关。
        // 这样可以避免 setAudioSource 导致的进度闪回 0。
        queue.add(List<MediaItem>.from(_originalQueue));
        _currentIndex = restoredIndex;
        if (restoredIndex >= 0 && restoredIndex < _originalQueue.length) {
          mediaItem.add(_originalQueue[restoredIndex]);
        }
        _diag('[DIAG] setShuffle(false): disable shuffle without rebuild, '
            'preserve current physical queue order');
      }
      _originalQueue = [];
    }

    // 恢复播放状态
    if (wasPlaying) {
      await _player.play();
    }
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
