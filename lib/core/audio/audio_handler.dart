import 'dart:async';
import 'dart:developer' as dev;

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
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
        dev.log('playbackEvent error: $error', error: error, stackTrace: st);
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
  }

  /// [F2 修复] 监听 sequenceStateStream，从 currentSource.tag 获取 MediaItem。
  /// 不做 ID 去重——直接 add，让 BehaviorSubject 的 downstream 自己 distinct()。
  /// 根因：之前的 ID 去重在 _safeSkipToIndex 提前 add 后，stream 回调被吞掉。
  /// [Round8-F3] 同时更新 _currentIndex，使 skipToNext/skipToPrevious
  /// 始终使用最新的曲目索引，不依赖 _player.currentIndex 的异步管道。
  void _listenToCurrentIndex() {
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null || sequenceState.currentSource == null) return;
      final tag = sequenceState.currentSource!.tag;
      final idx = sequenceState.currentIndex;
      if (tag is MediaItem) {
        // 更新自维护的 currentIndex
        _currentIndex = idx;
        // 直接发送，不做去重。
        // sequenceStateStream 在 seek(index:), auto-advance, seekToNext() 等
        // 场景都会触发，确保 UI 总是反映当前实际播放的曲目。
        mediaItem.add(tag);
        dev.log('mediaItem updated from sequenceState: '
            '${tag.title} (index=$idx)');
      }
    });
  }

  /// 监听播放处理状态，在完成或出错时自动跳到下一首
  void _listenToProcessingState() {
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        // ConcatenatingAudioSource 在 LoopMode.off 时会自动播放下一首，
        // 在 LoopMode.all 时会自动 wrap。不再手动调用 skipToNext()。
        // UI 更新由 _listenToCurrentIndex() 的 sequenceStateStream 负责。
        dev.log('ProcessingState.completed — loopMode=${_player.loopMode}, '
            'index=${_player.currentIndex}/${queue.value.length}');
      }
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.idle &&
          !_skipInProgress &&
          queue.value.isNotEmpty &&
          !state.playing) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_player.processingState == ProcessingState.idle &&
              queue.value.isNotEmpty &&
              !_skipInProgress) {
            dev.log('Player stuck in idle — attempting recovery');
            _attemptRecovery();
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
        dev.log('Health check: stale buffer count=$_staleBufferCount, '
            'buffered=$currentBuffered, position=$currentPosition');
        if (_staleBufferCount >= _maxStaleBufferChecks) {
          dev.log('Health check: buffered position stale for '
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

  Future<void> loadAndPlay(
    List<MediaItem> items, {
    int initialIndex = 0,
  }) async {
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
      dev.log('loadAndPlay failed at index $initialIndex: $e',
          error: e, stackTrace: st);
      // 如果首选曲目加载失败，尝试下一首
      if (initialIndex < items.length - 1) {
        dev.log('Trying next track at index ${initialIndex + 1}');
        try {
          await _player.setAudioSource(_playlist,
              initialIndex: initialIndex + 1);
          _currentIndex = initialIndex + 1;
          if (initialIndex + 1 < items.length) {
            mediaItem.add(items[initialIndex + 1]);
          }
          await _player.play();
        } catch (retryError, retrySt) {
          dev.log('Retry also failed: $retryError',
              error: retryError, stackTrace: retrySt);
        }
      }
    }
  }

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e, st) {
      dev.log('play() failed: $e', error: e, stackTrace: st);
      // 暂停后继续播放失败时，尝试重新加载当前曲目
      await _retryCurrentTrack();
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e, st) {
      dev.log('pause() failed: $e', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e, st) {
      dev.log('seek() failed: $e', error: e, stackTrace: st);
    }
  }

  /// [Round7-F1] skipToNext 使用手动索引计算。
  /// [Round8-F3] 使用自维护的 _currentIndex 而非 _player.currentIndex，
  /// 避免 auto-advance 后 _player.currentIndex 尚未更新导致的跳转错误。
  @override
  Future<void> skipToNext() async {
    if (_skipInProgress) return;
    _skipInProgress = true;
    try {
      final currentIdx = _currentIndex;
      final total = queue.value.length;
      if (total == 0) return;

      int nextIdx;
      if (currentIdx < total - 1) {
        nextIdx = currentIdx + 1;
      } else if (_player.loopMode == LoopMode.all) {
        // 列表循环模式下，末尾回到第一首
        nextIdx = 0;
      } else {
        dev.log('skipToNext: no next track available');
        return;
      }

      await _player.seek(Duration.zero, index: nextIdx);
      // 立即更新自维护的 _currentIndex，不等 sequenceStateStream 异步回调
      _currentIndex = nextIdx;
      dev.log('skipToNext: $currentIdx → $nextIdx');
      // mediaItem 更新由 _listenToCurrentIndex() 的 sequenceStateStream 驱动
    } catch (e, st) {
      dev.log('skipToNext() failed: $e', error: e, stackTrace: st);
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
    if (_skipInProgress) return;
    _skipInProgress = true;
    try {
      // 如果当前播放超过 3 秒，回到曲目开头
      if (_player.position.inSeconds > 3) {
        await _player.seek(Duration.zero);
        return;
      }

      final currentIdx = _currentIndex;
      final total = queue.value.length;
      if (total == 0) return;

      int prevIdx;
      if (currentIdx > 0) {
        prevIdx = currentIdx - 1;
      } else if (_player.loopMode == LoopMode.all) {
        // 列表循环模式下，开头回到最后一首
        prevIdx = total - 1;
      } else {
        dev.log('skipToPrevious: no previous track available');
        return;
      }

      await _player.seek(Duration.zero, index: prevIdx);
      // 立即更新自维护的 _currentIndex
      _currentIndex = prevIdx;
      dev.log('skipToPrevious: $currentIdx → $prevIdx');
    } catch (e, st) {
      dev.log('skipToPrevious() failed: $e', error: e, stackTrace: st);
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

    try {
      // 使用 seek 切换曲目，避免 setAudioSource 的全量重载。
      // mediaItem 更新由 sequenceStateStream listener 自动处理。
      await _player.seek(Duration.zero, index: index);
      dev.log('_safeSkipToIndex($index) seek succeeded');
    } catch (e, st) {
      dev.log('_safeSkipToIndex($index) seek failed: $e',
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
    if (currentIdx < total - 1) {
      dev.log('Auto-skipping from $currentIdx to ${currentIdx + 1} after error');
      skipToNext();
    } else {
      dev.log('Last track failed, stopping playback');
      _player.stop();
    }
  }

  /// [Round8-F5] 播放恢复失败时，用全新的 AudioSource 重新加载当前曲目。
  /// 重建 _playlist 以确保 HTTP 连接是全新的（解决长时间暂停后连接断开的问题）。
  Future<void> _retryCurrentTrack() async {
    final currentIdx = _currentIndex;
    final items = queue.value;
    if (currentIdx < 0 || currentIdx >= items.length) {
      _trySkipOnError();
      return;
    }

    final resumePosition = _player.position;
    dev.log('Retrying current track at index $currentIdx, position=$resumePosition');

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
    } catch (e, st) {
      dev.log('_retryCurrentTrack failed: $e', error: e, stackTrace: st);
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

    dev.log('Attempting player recovery: index=$currentIdx, position=$position, '
        'queueSize=${items.length}');

    if (items.isEmpty) return;

    try {
      // 用 queue 中的 MediaItem 重新创建全新的 AudioSource 实例。
      // 这确保 HTTP 连接是全新建立的，不复用可能已断开的旧连接。
      final sources = items.map(_audioSourceFromItem).toList();
      _playlist = ConcatenatingAudioSource(children: sources);

      final safeIdx = currentIdx.clamp(0, items.length - 1);
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
      dev.log('Player recovery succeeded');
    } catch (e, st) {
      dev.log('Player recovery failed: $e', error: e, stackTrace: st);
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

    try {
      await _player.setAudioSource(_playlist, initialIndex: index);
      // forceSkip 是最后兜底手段，需要手动更新 mediaItem 和 _currentIndex
      _currentIndex = index;
      mediaItem.add(items[index]);
      await _player.play();
    } catch (e, st) {
      dev.log('_forceSkipToIndex($index) failed: $e',
          error: e, stackTrace: st);
      if (index < items.length - 1) {
        await _forceSkipToIndex(index + 1);
      }
    }
  }

  @override
  Future<void> stop() async {
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

    return _player.setLoopMode(loopMode);
  }

  /// [Round7-F1] 手动 Shuffle 实现。
  /// 不调用 _player.setShuffleModeEnabled() / _player.shuffle()，
  /// 因为 just_audio_media_kit#3 会导致 currentIndex 错乱。
  /// 改为：物理打乱 ConcatenatingAudioSource 的子项顺序，
  /// 当前播放曲目始终放在 index=0，然后 setAudioSource() 重新加载。
  /// 关闭 shuffle 时恢复原始队列顺序，定位到当前播放曲目的原始位置。
  Future<void> setShuffle(bool enabled) async {
    if (enabled == _shuffleEnabled) return;
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
      // 3. 更新 queue + 重建 audio source
      queue.add(shuffled);
      await _rebuildAudioSource(shuffled, 0, currentPosition);
      dev.log('setShuffle(true): shuffled ${shuffled.length} items, '
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
      queue.add(List<MediaItem>.from(_originalQueue));
      await _rebuildAudioSource(_originalQueue, restoredIndex, currentPosition);
      dev.log('setShuffle(false): restored original order, '
          'current="${currentTag?.title}" at index=$restoredIndex');
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
    final sources = items.map(_audioSourceFromItem).toList();
    _playlist = ConcatenatingAudioSource(children: sources);
    await _player.setAudioSource(_playlist, initialIndex: initialIndex);
    // 同步自维护的 _currentIndex
    _currentIndex = initialIndex;
    if (position > Duration.zero) {
      await _player.seek(position);
    }
    // 手动同步 mediaItem（setAudioSource 会触发 sequenceStateStream，
    // 但以防时序问题，这里也显式设置一次）
    if (initialIndex >= 0 && initialIndex < items.length) {
      mediaItem.add(items[initialIndex]);
    }
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
