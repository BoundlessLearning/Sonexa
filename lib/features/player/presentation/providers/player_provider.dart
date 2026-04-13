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

/// Will be overridden in main.dart after AudioService.init completes.
final audioHandlerProvider = Provider<MusicAudioHandler>((ref) {
  throw UnimplementedError(
    'audioHandlerProvider must be overridden after AudioService.init',
  );
});

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
final positionProvider = StreamProvider<Duration>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  return audioHandler.positionStream;
});

/// Stream of the buffered position.
final bufferedPositionProvider = StreamProvider<Duration>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  return audioHandler.bufferedPositionStream;
});

/// Stream of the total duration of the current track.
final durationProvider = StreamProvider<Duration?>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  return audioHandler.durationStream;
});
