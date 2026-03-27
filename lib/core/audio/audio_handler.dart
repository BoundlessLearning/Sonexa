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
  bool _shuffleInProgress = false;

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

  void _listenToCurrentIndex() {
    // 使用 sequenceStateStream 代替 currentIndexStream，
    // 以确保在 shuffle 切换等场景下 sequenceState 已完全更新。
    _player.sequenceStateStream.listen((sequenceState) {
      // shuffle 切换期间跳过事件，避免中间状态污染 UI
      if (_shuffleInProgress) return;
      if (sequenceState == null || sequenceState.currentSource == null) return;
      final tag = sequenceState.currentSource!.tag;
      if (tag is MediaItem) {
        // 去重：如果实际播放的曲目 ID 没有变化，不重复发送 mediaItem 事件。
        // 这能防止 shuffle 切换触发 currentIndex 变化时错误地更新 UI。
        final currentId = mediaItem.valueOrNull?.extras?['songId']
            ?? mediaItem.valueOrNull?.id;
        final newId = tag.extras?['songId'] ?? tag.id;
        if (newId != currentId) {
          mediaItem.add(tag);
        }
      }
    });
  }

  /// 同步 mediaItem 为当前实际播放的曲目。
  /// 在 shuffle 切换后或 auto-advance 后调用，确保 UI 与播放器状态一致。
  void _syncCurrentMediaItem() {
    final index = _player.currentIndex;
    final items = queue.value;
    if (index != null && index >= 0 && index < items.length) {
      final currentItem = items[index];
      final currentId = mediaItem.valueOrNull?.extras?['songId']
          ?? mediaItem.valueOrNull?.id;
      final newId = currentItem.extras?['songId'] ?? currentItem.id;
      if (newId != currentId) {
        mediaItem.add(currentItem);
      }
    }
  }

  /// 监听播放处理状态，在完成或出错时自动跳到下一首
  void _listenToProcessingState() {
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        // just_audio 的 ConcatenatingAudioSource 在 LoopMode.off 时会自动播放下一首，
        // 在 LoopMode.all 时会自动 wrap。不再手动调用 skipToNext()，
        // 避免与平台层自动跳转产生竞争条件。
        // UI 更新由 _listenToCurrentIndex() 的 sequenceStateStream 监听负责。
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

  @override
  Future<void> skipToNext() async {
    if (_skipInProgress) return;
    _skipInProgress = true;
    try {
      final currentIdx = _player.currentIndex ?? 0;
      final nextIdx = currentIdx + 1;
      if (nextIdx >= queue.value.length) {
        // 已到最后一首，不做操作（除非列表循环）
        if (_player.loopMode == LoopMode.all && queue.value.isNotEmpty) {
          await _safeSkipToIndex(0);
        }
        return;
      }
      await _safeSkipToIndex(nextIdx);
    } catch (e, st) {
      dev.log('skipToNext() failed: $e', error: e, stackTrace: st);
      await _forceSkipToIndex((_player.currentIndex ?? 0) + 1);
    } finally {
      _skipInProgress = false;
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_skipInProgress) return;
    _skipInProgress = true;
    try {
      final currentIdx = _player.currentIndex ?? 0;
      // 如果当前播放超过 3 秒，回到曲目开头
      if (_player.position.inSeconds > 3) {
        await _player.seek(Duration.zero);
        return;
      }
      final prevIdx = currentIdx - 1;
      if (prevIdx < 0) return;
      await _safeSkipToIndex(prevIdx);
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

  /// 安全跳转到指定索引：使用 seek 切换曲目而非重新加载整个播放列表，
  /// 避免 mpv 在暂停态执行 stop→reload 产生错误。
  Future<void> _safeSkipToIndex(int index) async {
    final items = queue.value;
    if (index < 0 || index >= items.length) return;

    try {
      // 先更新 mediaItem，确保 UI 立即响应
      mediaItem.add(items[index]);
      // 使用 seek 切换曲目，避免 setAudioSource 的全量重载
      await _player.seek(Duration.zero, index: index);
    } catch (e, st) {
      dev.log('_safeSkipToIndex($index) seek failed: $e',
          error: e, stackTrace: st);
      // seek 失败时回退到 setAudioSource（可能有新的 playlist 未加载）
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
  /// 用于解决暂停后继续播放出错的场景（Bug 10）。
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
      // 重试也失败了，跳到下一首
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
      mediaItem.add(items[index]);
      await _player.play();
    } catch (e, st) {
      dev.log('_forceSkipToIndex($index) failed: $e',
          error: e, stackTrace: st);
      // 如果这首也失败了，尝试跳到再下一首
      if (index < items.length - 1) {
        await _forceSkipToIndex(index + 1);
      }
    }
  }

  @override
  Future<void> stop() async {
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

  Future<void> setShuffle(bool enabled) async {
    _shuffleInProgress = true;
    try {
      await _player.setShuffleModeEnabled(enabled);
      if (enabled) {
        await _player.shuffle();
      }
    } finally {
      _shuffleInProgress = false;
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
