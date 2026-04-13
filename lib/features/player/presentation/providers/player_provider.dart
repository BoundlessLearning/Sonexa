import 'dart:async';

import 'package:audio_service/audio_service.dart'
    show AudioProcessingState, MediaItem, PlaybackState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import 'package:ohmymusic/core/audio/audio_handler.dart';
import 'package:ohmymusic/core/utils/diagnostic_logger.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';
import 'package:ohmymusic/features/player/domain/entities/player_state.dart'
    as ps;

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
  });

  final PlaybackState playbackState;
  final MediaItem? resolvedMediaItem;
  final Duration rawPosition;
  final Duration rawBufferedPosition;
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
  final rawPosition = _clampDuration(event.rawPosition, duration);
  final rawBuffered = _clampDuration(event.rawBufferedPosition, duration);
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

  final isRecovering = playbackState.processingState ==
          AudioProcessingState.buffering ||
      playbackState.processingState == AudioProcessingState.loading;
  final jumpedBackToZero = rawPosition == Duration.zero &&
      previous.position > const Duration(seconds: 2) &&
      duration > const Duration(seconds: 2) &&
      playbackState.processingState != AudioProcessingState.completed;
  final abruptBackwardJump = rawPosition < const Duration(seconds: 3) &&
      previous.position > const Duration(seconds: 5) &&
      rawPosition + const Duration(seconds: 2) < previous.position &&
      duration > previous.position + const Duration(seconds: 3);
  final shouldHold = !recentUserSeek &&
      playbackState.playing &&
      (isRecovering || previous.holdPositionUntilEpochMs > nowEpochMs) &&
      (jumpedBackToZero || abruptBackwardJump);

  final holdUntilEpochMs =
      shouldHold ? nowEpochMs + 1800 : 0;
  final stabilizedPosition =
      shouldHold ? previous.position : rawPosition;
  final stabilizedBuffered =
      _clampDuration(rawBuffered < stabilizedPosition ? stabilizedPosition : rawBuffered, duration);

  if (shouldHold) {
    unawaited(DiagnosticLogger.instance.log(
      '[DIAG][PLAYER] hold position during buffering: '
      'songId=${songId ?? '<null>'}, previous=${previous.position}, '
      'rawPosition=$rawPosition, rawBuffered=$rawBuffered, '
      'recentUserSeek=$recentUserSeek, processingState=${playbackState.processingState}',
    ));
  }

  return _PlaybackTimelineSnapshot(
    songId: songId,
    position: _clampDuration(stabilizedPosition, duration),
    bufferedPosition: stabilizedBuffered,
    duration: duration,
    holdPositionUntilEpochMs: holdUntilEpochMs,
  );
}

/// Combines playbackState, mediaItem, and queue into a unified PlayerState.
final playerProvider = StreamProvider<ps.PlayerState>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);

  return Rx.combineLatest3<PlaybackState, MediaItem?, List<MediaItem>,
      ps.PlayerState>(
    audioHandler.playbackState,
    audioHandler.mediaItem,
    audioHandler.queue,
    (playbackState, mediaItem, queue) {
      final resolvedMediaItem =
          _resolveCurrentMediaItem(playbackState, mediaItem, queue);
      final isBuffering =
          playbackState.processingState == AudioProcessingState.buffering ||
              playbackState.processingState == AudioProcessingState.loading;

      return ps.PlayerState(
        currentSong: _mediaItemToSong(resolvedMediaItem),
        queue: queue.map((item) => _mediaItemToSong(item)!).toList(),
        currentIndex: playbackState.queueIndex ?? 0,
        isPlaying: playbackState.playing,
        isBuffering: isBuffering,
        position: playbackState.updatePosition,
        bufferedPosition: playbackState.bufferedPosition,
        duration: resolvedMediaItem?.duration ?? Duration.zero,
      );
    },
  );
});

/// Extracts the current Song from the player state.
final currentSongProvider = Provider<Song?>((ref) {
  final playerAsync = ref.watch(playerProvider);
  return playerAsync.valueOrNull?.currentSong;
});

final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  final controller = StreamController<MediaItem?>();
  PlaybackState? latestPlaybackState;
  MediaItem? latestMediaItem;
  List<MediaItem> latestQueue = const [];
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
      final shouldClear = resolved == null &&
          latestMediaItem == null &&
          latestQueue.isEmpty &&
          playbackState.queueIndex == null &&
          playbackState.processingState == AudioProcessingState.idle &&
          !playbackState.playing;
      if (!shouldClear) {
        return;
      }

      final previousSongId =
          lastResolved?.extras?['songId'] as String? ?? lastResolved?.id ?? '<null>';
      lastResolved = null;
      unawaited(DiagnosticLogger.instance.log(
        '[DIAG][PLAYER] currentMediaItemProvider cleared after debounce: '
        'previousSongId=$previousSongId',
      ));
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
          lastResolved?.extras?['songId'] as String? ?? lastResolved?.id ?? '<null>';
      final queueIndex = playbackState.queueIndex;
      final processingState = playbackState.processingState;
      final shouldDebounceClear = latestQueue.isEmpty &&
          latestMediaItem == null &&
          queueIndex == null &&
          processingState == AudioProcessingState.idle &&
          !playbackState.playing;
      if (shouldDebounceClear) {
        unawaited(DiagnosticLogger.instance.log(
          '[DIAG][PLAYER] currentMediaItemProvider debounce clear: '
          'previousSongId=$previousSongId, queueIndex=$queueIndex, '
          'queueLen=${latestQueue.length}, processingState=$processingState',
        ));
        scheduleClearIfStillEmpty();
        controller.add(lastResolved);
      } else {
        cancelPendingClear();
        unawaited(DiagnosticLogger.instance.log(
          '[DIAG][PLAYER] currentMediaItemProvider unresolved without hold: '
          'previousSongId=$previousSongId, queueIndex=$queueIndex, '
          'queueLen=${latestQueue.length}, processingState=$processingState',
        ));
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

  ref.onDispose(() async {
    cancelPendingClear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await controller.close();
  });

  return controller.stream.distinct((previous, next) {
    final previousSongId = previous?.extras?['songId'] as String? ?? previous?.id;
    final nextSongId = next?.extras?['songId'] as String? ?? next?.id;
    return previousSongId == nextSongId;
  });
});

/// 当前播放歌曲 ID 的响应式 Provider，用于歌词等需要跟踪切歌的组件。
final currentSongIdProvider = Provider<String?>((ref) {
  final currentSong = ref.watch(currentSongProvider);
  return currentSong?.id;
});

/// Stream of the current playback position.
final playbackTimelineProvider = StreamProvider<_PlaybackTimelineSnapshot>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  final lastSeekIntentAt = ref.watch(playerSeekIntentProvider);

  return Rx.combineLatest5<Duration, Duration, PlaybackState, MediaItem?,
      List<MediaItem>,
      _PlaybackTimelineEvent>(
    audioHandler.positionStream,
    audioHandler.bufferedPositionStream,
    audioHandler.playbackState,
    audioHandler.mediaItem,
    audioHandler.queue,
    (rawPosition, rawBufferedPosition, playbackState, mediaItem, queue) {
      final resolvedMediaItem =
          _resolveCurrentMediaItem(playbackState, mediaItem, queue);
      return _PlaybackTimelineEvent(
        playbackState: playbackState,
        resolvedMediaItem: resolvedMediaItem,
        rawPosition: rawPosition,
        rawBufferedPosition: rawBufferedPosition,
      );
    },
  ).scan<_PlaybackTimelineSnapshot>(
    (previous, event, _) =>
        _stabilizeTimelineSnapshot(previous, event, lastSeekIntentAt),
    const _PlaybackTimelineSnapshot(
      songId: null,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
      duration: Duration.zero,
    ),
  ).skip(1).distinct((previous, next) {
    return previous.songId == next.songId &&
        previous.position == next.position &&
        previous.bufferedPosition == next.bufferedPosition &&
        previous.duration == next.duration;
  });
});

/// Stream of the current playback position.
final positionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(playbackTimelineProvider.stream).map((snapshot) => snapshot.position);
});

/// Stream of the buffered position.
final bufferedPositionProvider = StreamProvider<Duration>((ref) {
  return ref
      .watch(playbackTimelineProvider.stream)
      .map((snapshot) => snapshot.bufferedPosition);
});

/// Stream of the total duration of the current track.
final durationProvider = StreamProvider<Duration?>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  return audioHandler.durationStream;
});
