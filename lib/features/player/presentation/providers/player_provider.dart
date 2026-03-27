import 'package:audio_service/audio_service.dart'
    show AudioProcessingState, MediaItem, PlaybackState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import 'package:ohmymusic/core/audio/audio_handler.dart';
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

/// Combines playbackState, mediaItem, and queue into a unified PlayerState.
final playerProvider = StreamProvider<ps.PlayerState>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);

  return Rx.combineLatest3<PlaybackState, MediaItem?, List<MediaItem>,
      ps.PlayerState>(
    audioHandler.playbackState,
    audioHandler.mediaItem,
    audioHandler.queue,
    (playbackState, mediaItem, queue) {
      final isBuffering =
          playbackState.processingState == AudioProcessingState.buffering ||
              playbackState.processingState == AudioProcessingState.loading;

      return ps.PlayerState(
        currentSong: _mediaItemToSong(mediaItem),
        queue: queue.map((item) => _mediaItemToSong(item)!).toList(),
        currentIndex: playbackState.queueIndex ?? 0,
        isPlaying: playbackState.playing,
        isBuffering: isBuffering,
        position: playbackState.updatePosition,
        bufferedPosition: playbackState.bufferedPosition,
        duration: mediaItem?.duration ?? Duration.zero,
      );
    },
  );
});

/// Extracts the current Song from the player state.
final currentSongProvider = Provider<Song?>((ref) {
  final playerAsync = ref.watch(playerProvider);
  return playerAsync.valueOrNull?.currentSong;
});

/// 当前播放歌曲 ID 的响应式 Stream，用于歌词等需要跟踪切歌的组件。
final currentSongIdProvider = StreamProvider<String?>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  return audioHandler.mediaItem
      .map((item) => item?.extras?['songId'] as String?)
      .distinct();
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
