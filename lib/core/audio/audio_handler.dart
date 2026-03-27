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
  final ConcatenatingAudioSource _playlist;

  bool _skipInProgress = false;

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
  void _listenToCurrentIndex() {
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null || sequenceState.currentSource == null) return;
      final tag = sequenceState.currentSource!.tag;
      if (tag is MediaItem) {
        // 直接发送，不做去重。
        // sequenceStateStream 在 seek(index:), auto-advance, seekToNext() 等
        // 场景都会触发，确保 UI 总是反映当前实际播放的曲目。
        mediaItem.add(tag);
        dev.log('mediaItem updated from sequenceState: '
            '${tag.title} (index=${sequenceState.currentIndex})');
      }
    });
  }

  /// [F3 修复] 从 sequenceState.currentSource.tag 获取当前曲目，
  /// 不再从 queue.value[_player.currentIndex] 读。
  /// 根因：queue.value 是原始插入顺序，_player.currentIndex 在 shuffle
  /// 时是 effectiveIndices 空间的索引，两者不匹配。
  void _syncCurrentMediaItem() {
    final sequenceState = _player.sequenceState;
    if (sequenceState == null || sequenceState.currentSource == null) return;
    final tag = sequenceState.currentSource!.tag;
    if (tag is MediaItem) {
      mediaItem.add(tag);
    }
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
          _player.currentIndex != null &&
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
    queue.add(items);

    if (items.isEmpty) {
      await _playlist.clear();
      mediaItem.add(null);
      return;
    }

    final sources = items.map(_audioSourceFromItem).toList();

    try {
      await _playlist.clear();
      await _playlist.addAll(sources);
      await _player.setAudioSource(_playlist, initialIndex: initialIndex);

      // 初始 mediaItem 立即设置，不等 stream —— 只在 loadAndPlay 时做。
      if (initialIndex >= 0 && initialIndex < items.length) {
        mediaItem.add(items[initialIndex]);
      }

      await play();
    } catch (e, st) {
      dev.log('loadAndPlay failed at index $initialIndex: $e',
          error: e, stackTrace: st);
      // 如果首选曲目加载失败，尝试下一首
      if (initialIndex < items.length - 1) {
        dev.log('Trying next track at index ${initialIndex + 1}');
        try {
          await _player.setAudioSource(_playlist,
              initialIndex: initialIndex + 1);
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

  /// [F1 修复] 使用 just_audio 内置的 seekToNext()。
  /// seekToNext() 内部调用 seek(Duration.zero, index: nextIndex)，
  /// 其中 nextIndex 走 effectiveIndices，正确处理 shuffle + loopMode。
  /// 不再手工计算 currentIndex + 1 —— 那在 currentIndex 未及时更新时
  /// 总是返回 0+1=1，导致"永远跳到第二首"。
  @override
  Future<void> skipToNext() async {
    if (_skipInProgress) return;
    _skipInProgress = true;
    try {
      if (_player.hasNext) {
        await _player.seekToNext();
        dev.log('skipToNext: seekToNext() succeeded, '
            'newIndex=${_player.currentIndex}');
      } else if (_player.loopMode == LoopMode.all &&
          queue.value.isNotEmpty) {
        // 列表循环模式下，末尾回到第一首
        await _player.seek(Duration.zero, index: 0);
        dev.log('skipToNext: wrapped to index 0 (loopMode=all)');
      } else {
        dev.log('skipToNext: no next track available');
      }
    } catch (e, st) {
      dev.log('skipToNext() seekToNext failed: $e',
          error: e, stackTrace: st);
      // 回退：用 setAudioSource 强制跳转
      final nextIdx = (_player.currentIndex ?? 0) + 1;
      if (nextIdx < queue.value.length) {
        await _forceSkipToIndex(nextIdx);
      }
    } finally {
      _skipInProgress = false;
    }
  }

  /// [F1 修复] 使用 just_audio 内置的 seekToPrevious()。
  /// 同理不再手工计算 currentIndex - 1。
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
      if (_player.hasPrevious) {
        await _player.seekToPrevious();
        dev.log('skipToPrevious: seekToPrevious() succeeded, '
            'newIndex=${_player.currentIndex}');
      } else if (_player.loopMode == LoopMode.all &&
          queue.value.isNotEmpty) {
        // 列表循环模式下，开头回到最后一首
        final lastIdx = queue.value.length - 1;
        await _player.seek(Duration.zero, index: lastIdx);
        dev.log('skipToPrevious: wrapped to index $lastIdx (loopMode=all)');
      } else {
        dev.log('skipToPrevious: no previous track available');
      }
    } catch (e, st) {
      dev.log('skipToPrevious() failed: $e', error: e, stackTrace: st);
      final prevIndex = (_player.currentIndex ?? 1) - 1;
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
    final currentIdx = _player.currentIndex ?? 0;
    final total = queue.value.length;
    if (currentIdx < total - 1) {
      dev.log('Auto-skipping from $currentIdx to ${currentIdx + 1} after error');
      skipToNext();
    } else {
      dev.log('Last track failed, stopping playback');
      _player.stop();
    }
  }

  /// 播放恢复失败时，重新加载当前曲目并从上次位置继续播放。
  Future<void> _retryCurrentTrack() async {
    final currentIdx = _player.currentIndex;
    final items = queue.value;
    if (currentIdx == null || currentIdx < 0 || currentIdx >= items.length) {
      _trySkipOnError();
      return;
    }

    final resumePosition = _player.position;
    dev.log('Retrying current track at index $currentIdx, position=$resumePosition');

    try {
      // 重新设置音频源到当前索引
      await _player.setAudioSource(_playlist, initialIndex: currentIdx);
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

  /// 尝试恢复播放器：在音频设备丢失等严重错误后重建播放器。
  Future<void> _attemptRecovery() async {
    final currentIdx = _player.currentIndex;
    final position = _player.position;
    final wasPlaying = _player.playing;

    dev.log('Attempting player recovery: index=$currentIdx, position=$position');

    try {
      // 重新设置音频源并恢复位置
      await _player.setAudioSource(_playlist, initialIndex: currentIdx ?? 0);
      if (position > Duration.zero) {
        await _player.seek(position);
      }
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
      // forceSkip 是最后兜底手段，需要手动更新 mediaItem
      // 因为 setAudioSource 会触发 sequenceStateStream，但以防万一也手动设置
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

  /// 切换 shuffle 模式。
  /// 注意：just_audio_media_kit 不完全支持 just_audio 的 shuffleOrder。
  /// 当前实现使用 just_audio 的 setShuffleModeEnabled + shuffle()，
  /// 并通过 _syncCurrentMediaItem() 从 sequenceState.currentSource.tag 同步，
  /// 避免 queue.value 和 effectiveIndices 的索引空间不匹配问题。
  Future<void> setShuffle(bool enabled) async {
    try {
      await _player.setShuffleModeEnabled(enabled);
      if (enabled) {
        await _player.shuffle();
      }
    } finally {
      // shuffle 完成后，确保 mediaItem 反映真正在播放的曲目
      _syncCurrentMediaItem();
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
  }

  Future<void> removeFromQueue(int index) async {
    final currentQueue = [...queue.value];
    if (index < 0 || index >= currentQueue.length) {
      return;
    }

    currentQueue.removeAt(index);
    queue.add(currentQueue);
    await _playlist.removeAt(index);

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
