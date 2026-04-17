import 'dart:async';

import 'package:audio_service/audio_service.dart'
    show AudioProcessingState, MediaItem, PlaybackState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import 'package:sonexa/core/audio/audio_handler.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/features/library/domain/entities/song.dart';
import 'package:sonexa/features/player/domain/entities/player_state.dart' as ps;

class _PlaybackTimelineSnapshot {
  const _PlaybackTimelineSnapshot({
    required this.songId,
    required this.position,
    required this.bufferedPosition,
    required this.duration,
    this.holdPositionUntilEpochMs = 0,
  });

  final String? songId;
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final int holdPositionUntilEpochMs;
}

class _PlaybackTimelineEvent {
  const _PlaybackTimelineEvent({
    required this.playbackState,
    required this.resolvedMediaItem,
    required this.rawPosition,
    required this.rawBufferedPosition,
    required this.playbackPositionHint,
    required this.playbackBufferedHint,
  });

  final PlaybackState playbackState;
  final MediaItem? resolvedMediaItem;
  final Duration rawPosition;
  final Duration rawBufferedPosition;
  final Duration playbackPositionHint;
  final Duration playbackBufferedHint;
}

/// Will be overridden in main.dart after AudioService.init completes.
final audioHandlerProvider = Provider<MusicAudioHandler>((ref) {
  throw UnimplementedError(
    'audioHandlerProvider must be overridden after AudioService.init',
  );
});

final playerSeekIntentProvider = StateProvider<DateTime?>((ref) => null);

/// 播放模式枚举：顺序 → 随机 → 单曲循环 → 列表循环
enum PlayMode {
  /// 顺序播放
  sequential,

  /// 随机播放
  shuffle,

  /// 单曲循环
  repeatOne,

  /// 列表循环
  repeatAll,
}

/// 控制播放模式，按顺序循环切换：顺序 → 随机 → 单曲循环 → 列表循环。
final playModeProvider = StateProvider<PlayMode>((ref) => PlayMode.sequential);

/// Converts a MediaItem to a Song entity.
Song? _mediaItemToSong(MediaItem? item) {
  if (item == null) return null;
  return Song(
    id: item.extras?['songId'] as String? ?? item.id,
    title: item.title,
    artist: item.artist ?? '',
    artistId: item.extras?['artistId'] as String? ?? '',
    album: item.album ?? '',
    albumId: item.extras?['albumId'] as String? ?? '',
    duration: item.duration?.inSeconds ?? 0,
    coverArtId: item.artUri?.toString(),
    suffix: item.extras?['sourceSuffix'] as String?,
  );
}

MediaItem? _resolveCurrentMediaItem(
  PlaybackState playbackState,
  MediaItem? mediaItem,
  List<MediaItem> queue,
) {
  final queueIndex = playbackState.queueIndex;
  if (queueIndex != null && queueIndex >= 0 && queueIndex < queue.length) {
    return queue[queueIndex];
  }

  if (mediaItem == null) {
    return null;
  }

  final mediaSongId = mediaItem.extras?['songId'] as String? ?? mediaItem.id;
  final matchedQueueItem = queue.cast<MediaItem?>().firstWhere(
    (item) =>
        item != null &&
        ((item.extras?['songId'] as String? ?? item.id) == mediaSongId),
    orElse: () => null,
  );
  return matchedQueueItem ?? mediaItem;
}

Duration _clampDuration(Duration value, Duration max) {
  if (value < Duration.zero) {
    return Duration.zero;
  }
  if (max <= Duration.zero) {
    return value;
  }
  if (value > max) {
    return max;
  }
  return value;
}

_PlaybackTimelineSnapshot _stabilizeTimelineSnapshot(
  _PlaybackTimelineSnapshot? previous,
  _PlaybackTimelineEvent event,
  DateTime? lastSeekIntentAt,
) {
  final playbackState = event.playbackState;
  final resolvedMediaItem = event.resolvedMediaItem;
  final songId =
      resolvedMediaItem?.extras?['songId'] as String? ?? resolvedMediaItem?.id;
  final duration = resolvedMediaItem?.duration ?? Duration.zero;
  final hintedPosition = _clampDuration(event.playbackPositionHint, duration);
  final hintedBuffered = _clampDuration(event.playbackBufferedHint, duration);
  final rawPosition = _clampDuration(
    event.rawPosition > hintedPosition ? event.rawPosition : hintedPosition,
    duration,
  );
  final rawBuffered = _clampDuration(
    event.rawBufferedPosition > hintedBuffered
        ? event.rawBufferedPosition
        : hintedBuffered,
    duration,
  );
  final nowEpochMs = DateTime.now().millisecondsSinceEpoch;
  final lastSeekEpochMs = lastSeekIntentAt?.millisecondsSinceEpoch ?? 0;
  final recentUserSeek = nowEpochMs - lastSeekEpochMs < 2000;

  if (previous == null || previous.songId != songId) {
    return _PlaybackTimelineSnapshot(
      songId: songId,
      position: rawPosition,
      bufferedPosition: rawBuffered >= rawPosition ? rawBuffered : rawPosition,
      duration: duration,
    );
  }

  final isRecovering =
      playbackState.processingState == AudioProcessingState.buffering ||
      playbackState.processingState == AudioProcessingState.loading;
  final jumpedBackToZero =
      rawPosition == Duration.zero &&
      previous.position > const Duration(seconds: 2) &&
      duration > const Duration(seconds: 2) &&
      playbackState.processingState != AudioProcessingState.completed;
  final abruptBackwardJump =
      rawPosition < const Duration(seconds: 3) &&
      previous.position > const Duration(seconds: 5) &&
      rawPosition + const Duration(seconds: 2) < previous.position &&
      duration > previous.position + const Duration(seconds: 3);
  final shouldHold =
      !recentUserSeek &&
      playbackState.playing &&
      (isRecovering || previous.holdPositionUntilEpochMs > nowEpochMs) &&
      (jumpedBackToZero || abruptBackwardJump);

  final holdUntilEpochMs = shouldHold ? nowEpochMs + 1800 : 0;
  final stabilizedPosition = shouldHold ? previous.position : rawPosition;
  final stabilizedBuffered = _clampDuration(
    rawBuffered < stabilizedPosition ? stabilizedPosition : rawBuffered,
    duration,
  );

  if (shouldHold) {
    unawaited(
      DiagnosticLogger.instance.log(
        '[DIAG][PLAYER] hold position during buffering: '
        'songId=${songId ?? '<null>'}, previous=${previous.position}, '
        'rawPosition=$rawPosition, rawBuffered=$rawBuffered, '
        'recentUserSeek=$recentUserSeek, processingState=${playbackState.processingState}',
      ),
    );
  }

  return _PlaybackTimelineSnapshot(
    songId: songId,
    position: _clampDuration(stabilizedPosition, duration),
    bufferedPosition: stabilizedBuffered,
    duration: duration,
    holdPositionUntilEpochMs: holdUntilEpochMs,
  );
}

/// Converts the audio-layer playback snapshot into the UI PlayerState.
final playerProvider = StreamProvider<ps.PlayerState>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);

  return audioHandler.playbackSnapshotStream.map((snapshot) {
    final isBuffering =
        snapshot.processingState == AudioProcessingState.buffering ||
        snapshot.processingState == AudioProcessingState.loading;

    return ps.PlayerState(
      currentSong: _mediaItemToSong(snapshot.currentItem),
      queue: snapshot.queue.map((item) => _mediaItemToSong(item)!).toList(),
      currentIndex: snapshot.queueIndex ?? 0,
      isPlaying: snapshot.playing,
      isBuffering: isBuffering,
      position: snapshot.position,
      bufferedPosition: snapshot.bufferedPosition,
      duration: snapshot.duration,
    );
  });
});

/// Extracts the current Song from the player state.
final currentSongProvider = Provider<Song?>((ref) {
  final playerAsync = ref.watch(playerProvider);
  return playerAsync.valueOrNull?.currentSong;
});

final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  final controller = StreamController<MediaItem?>();
  PlaybackState? latestPlaybackState = audioHandler.playbackState.valueOrNull;
  MediaItem? latestMediaItem = audioHandler.mediaItem.valueOrNull;
  List<MediaItem> latestQueue = audioHandler.queue.valueOrNull ?? const [];
  MediaItem? lastResolved;
  Timer? clearResolvedTimer;

  void cancelPendingClear() {
    clearResolvedTimer?.cancel();
    clearResolvedTimer = null;
  }

  void scheduleClearIfStillEmpty() {
    cancelPendingClear();
    clearResolvedTimer = Timer(const Duration(milliseconds: 800), () {
      final playbackState = latestPlaybackState;
      if (playbackState == null) {
        return;
      }

      final resolved = _resolveCurrentMediaItem(
        playbackState,
        latestMediaItem,
        latestQueue,
      );
      final shouldClear =
          resolved == null &&
          latestMediaItem == null &&
          latestQueue.isEmpty &&
          playbackState.queueIndex == null &&
          playbackState.processingState == AudioProcessingState.idle &&
          !playbackState.playing;
      if (!shouldClear) {
        return;
      }

      final previousSongId =
          lastResolved?.extras?['songId'] as String? ??
          lastResolved?.id ??
          '<null>';
      lastResolved = null;
      unawaited(
        DiagnosticLogger.instance.log(
          '[DIAG][PLAYER] currentMediaItemProvider cleared after debounce: '
          'previousSongId=$previousSongId',
        ),
      );
      controller.add(null);
    });
  }

  void emitResolved() {
    final playbackState = latestPlaybackState;
    if (playbackState == null) {
      return;
    }

    final resolved = _resolveCurrentMediaItem(
      playbackState,
      latestMediaItem,
      latestQueue,
    );

    if (resolved != null) {
      cancelPendingClear();
      lastResolved = resolved;
    } else {
      final previousSongId =
          lastResolved?.extras?['songId'] as String? ??
          lastResolved?.id ??
          '<null>';
      final queueIndex = playbackState.queueIndex;
      final processingState = playbackState.processingState;
      final shouldDebounceClear =
          latestQueue.isEmpty &&
          latestMediaItem == null &&
          queueIndex == null &&
          processingState == AudioProcessingState.idle &&
          !playbackState.playing;
      if (shouldDebounceClear) {
        unawaited(
          DiagnosticLogger.instance.log(
            '[DIAG][PLAYER] currentMediaItemProvider debounce clear: '
            'previousSongId=$previousSongId, queueIndex=$queueIndex, '
            'queueLen=${latestQueue.length}, processingState=$processingState',
          ),
        );
        scheduleClearIfStillEmpty();
        controller.add(lastResolved);
      } else {
        cancelPendingClear();
        unawaited(
          DiagnosticLogger.instance.log(
            '[DIAG][PLAYER] currentMediaItemProvider unresolved without hold: '
            'previousSongId=$previousSongId, queueIndex=$queueIndex, '
            'queueLen=${latestQueue.length}, processingState=$processingState',
          ),
        );
        controller.add(null);
      }
      return;
    }

    controller.add(lastResolved);
  }

  final subscriptions = <StreamSubscription<dynamic>>[
    audioHandler.playbackState.listen((value) {
      latestPlaybackState = value;
      emitResolved();
    }),
    audioHandler.mediaItem.listen((value) {
      latestMediaItem = value;
      emitResolved();
    }),
    audioHandler.queue.listen((value) {
      latestQueue = value;
      emitResolved();
    }),
  ];

  emitResolved();

  ref.onDispose(() async {
    cancelPendingClear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await controller.close();
  });

  return controller.stream.distinct((previous, next) {
    final previousSongId =
        previous?.extras?['songId'] as String? ?? previous?.id;
    final nextSongId = next?.extras?['songId'] as String? ?? next?.id;
    return previousSongId == nextSongId;
  });
});

final resolvedCurrentMediaItemProvider = Provider<MediaItem?>((ref) {
  final currentMediaItemAsync = ref.watch(currentMediaItemProvider);
  final currentMediaItem = currentMediaItemAsync.valueOrNull;
  if (currentMediaItem != null) {
    return currentMediaItem;
  }

  final audioHandler = ref.watch(audioHandlerProvider);
  return _resolveCurrentMediaItem(
    audioHandler.playbackState.value,
    audioHandler.mediaItem.valueOrNull,
    audioHandler.queue.valueOrNull ?? const [],
  );
});

/// 当前播放歌曲 ID 的响应式 Provider，用于歌词等需要跟踪切歌的组件。
final currentSongIdProvider = Provider<String?>((ref) {
  final currentSong = ref.watch(currentSongProvider);
  return currentSong?.id;
});

Stream<_PlaybackTimelineSnapshot> _playbackTimelineStream(Ref ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  final lastSeekIntentAt = ref.watch(playerSeekIntentProvider);

  return Rx.combineLatest5<
        PlaybackState,
        MediaItem?,
        List<MediaItem>,
        Duration,
        Duration,
        _PlaybackTimelineEvent
      >(
        audioHandler.playbackState,
        audioHandler.mediaItem,
        audioHandler.queue,
        audioHandler.positionStream,
        audioHandler.bufferedPositionStream,
        (playbackState, mediaItem, queue, rawPosition, rawBufferedPosition) =>
            _PlaybackTimelineEvent(
              playbackState: playbackState,
              resolvedMediaItem: _resolveCurrentMediaItem(
                playbackState,
                mediaItem,
                queue,
              ),
              rawPosition: rawPosition,
              rawBufferedPosition: rawBufferedPosition,
              playbackPositionHint: playbackState.updatePosition,
              playbackBufferedHint: playbackState.bufferedPosition,
            ),
      )
      .scan<_PlaybackTimelineSnapshot>(
        (previous, event, _) =>
            _stabilizeTimelineSnapshot(previous, event, lastSeekIntentAt),
        const _PlaybackTimelineSnapshot(
          songId: null,
          position: Duration.zero,
          bufferedPosition: Duration.zero,
          duration: Duration.zero,
        ),
      )
      .skip(1)
      .distinct((previous, next) {
        return previous.songId == next.songId &&
            previous.position == next.position &&
            previous.bufferedPosition == next.bufferedPosition &&
            previous.duration == next.duration;
      });
}

/// Stream of the current playback timeline.
final playbackTimelineProvider = StreamProvider<_PlaybackTimelineSnapshot>(
  _playbackTimelineStream,
);

final playbackTimelineSnapshotProvider = Provider<_PlaybackTimelineSnapshot?>((
  ref,
) {
  final timelineAsync = ref.watch(playbackTimelineProvider);
  final timeline = timelineAsync.valueOrNull;
  if (timeline != null) {
    return timeline;
  }

  final audioHandler = ref.watch(audioHandlerProvider);
  final playbackState = audioHandler.playbackState.value;
  final resolvedMediaItem = _resolveCurrentMediaItem(
    playbackState,
    audioHandler.mediaItem.valueOrNull,
    audioHandler.queue.valueOrNull ?? const [],
  );
  return _PlaybackTimelineSnapshot(
    songId:
        resolvedMediaItem?.extras?['songId'] as String? ??
        resolvedMediaItem?.id,
    position: playbackState.updatePosition,
    bufferedPosition: playbackState.bufferedPosition,
    duration: resolvedMediaItem?.duration ?? Duration.zero,
  );
});

/// Stream of the current playback position.
final positionProvider = StreamProvider<Duration>((ref) {
  return _playbackTimelineStream(ref).map((snapshot) => snapshot.position);
});

final resolvedPositionProvider = Provider<Duration>((ref) {
  return ref.watch(playbackTimelineSnapshotProvider)?.position ?? Duration.zero;
});

/// Stream of the buffered position.
final bufferedPositionProvider = StreamProvider<Duration>((ref) {
  return _playbackTimelineStream(
    ref,
  ).map((snapshot) => snapshot.bufferedPosition);
});

final resolvedBufferedPositionProvider = Provider<Duration>((ref) {
  return ref.watch(playbackTimelineSnapshotProvider)?.bufferedPosition ??
      Duration.zero;
});

/// Stream of the total duration of the current track.
final durationProvider = StreamProvider<Duration?>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  return audioHandler.durationStream;
});

final resolvedDurationProvider = Provider<Duration?>((ref) {
  final durationAsync = ref.watch(durationProvider);
  final duration = durationAsync.valueOrNull;
  if (duration != null && duration > Duration.zero) {
    return duration;
  }
  return ref.watch(playbackTimelineSnapshotProvider)?.duration;
});
