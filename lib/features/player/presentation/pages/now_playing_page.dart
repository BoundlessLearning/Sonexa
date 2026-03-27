import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ohmymusic/core/audio/audio_handler.dart' as ah;
import 'package:ohmymusic/core/utils/formatters.dart';
import 'package:ohmymusic/features/lyrics/presentation/providers/lyrics_provider.dart';
import 'package:ohmymusic/features/lyrics/presentation/widgets/lyrics_display.dart';
import 'package:ohmymusic/features/player/presentation/providers/favorites_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

class NowPlayingPage extends ConsumerWidget {
  const NowPlayingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final favorites = ref.watch(favoritesNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          iconSize: 32,
          onPressed: () => context.pop(),
        ),
        title: const Text('正在播放'),
        centerTitle: true,
        actions: [
          StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, snapshot) {
              final songId = snapshot.data?.extras?['songId'] as String?;
              final isFavorite = songId != null && favorites.contains(songId);

              return IconButton(
                onPressed: songId == null
                    ? null
                    : () => ref
                        .read(favoritesNotifierProvider.notifier)
                        .toggleFavorite(songId),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                tooltip: isFavorite ? '取消收藏' : '收藏',
              );
            },
          ),
          // 歌词显示切换按钮
          Builder(
            builder: (context) {
              final showLyrics = ref.watch(showLyricsProvider);
              return IconButton(
                icon: const Icon(Icons.text_snippet_rounded),
                color: showLyrics
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                onPressed: () => ref
                    .read(showLyricsProvider.notifier)
                    .state = !showLyrics,
                tooltip: showLyrics ? '显示封面' : '显示歌词',
              );
            },
          ),
          // 歌词搜索替换按钮
          StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, snapshot) {
              final item = snapshot.data;
              return IconButton(
                icon: const Icon(Icons.lyrics_rounded),
                tooltip: '搜索歌词',
                onPressed: item == null
                    ? null
                    : () {
                        final songId =
                            item.extras?['songId'] as String? ?? item.id;
                        context.push(Uri(
                          path: '/lyrics-search',
                          queryParameters: {
                            'songId': songId,
                            'artist': item.artist ?? '',
                            'title': item.title,
                          },
                        ).toString());
                      },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: () => context.push('/queue'),
          ),
        ],
      ),
      body: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, mediaSnapshot) {
          final mediaItem = mediaSnapshot.data;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 1),
                // 封面 / 歌词切换区域
                Builder(
                  builder: (context) {
                    final showLyrics = ref.watch(showLyricsProvider);
                    if (showLyrics) {
                      return SizedBox(
                        width: 280,
                        height: 280,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: const LyricsDisplay(),
                        ),
                      );
                    }
                    return Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Hero(
                        tag: 'now-playing-cover',
                        child: mediaItem?.artUri != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  mediaItem!.artUri.toString(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.album,
                                    size: 200,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: const Icon(Icons.album, size: 200),
                              ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 1),
                // Song title
                Text(
                  mediaItem?.title ?? '未播放',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Artist name
                Text(
                  mediaItem?.artist ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Seek bar
                _SeekBar(audioHandler: audioHandler, mediaItem: mediaItem),
                const SizedBox(height: 16),
                // Playback controls
                _PlaybackControls(audioHandler: audioHandler),
                const Spacer(flex: 2),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SeekBar extends ConsumerWidget {
  const _SeekBar({
    required this.audioHandler,
    required this.mediaItem,
  });

  final ah.MusicAudioHandler audioHandler;
  final MediaItem? mediaItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final position = positionAsync.valueOrNull ?? Duration.zero;
    final duration =
        durationAsync.valueOrNull ?? mediaItem?.duration ?? Duration.zero;

    final maxSeconds = duration.inSeconds.toDouble();
    final currentSeconds =
        position.inSeconds.toDouble().clamp(0.0, maxSeconds > 0 ? maxSeconds : 1.0);

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            thumbColor: colorScheme.primary,
          ),
          child: Slider(
            value: currentSeconds,
            max: maxSeconds > 0 ? maxSeconds : 1.0,
            onChanged: (value) {
              audioHandler.seek(Duration(seconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(position.inSeconds),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                formatDuration(duration.inSeconds),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.audioHandler});

  final ah.MusicAudioHandler audioHandler;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 播放模式（顺序/随机/单曲循环/列表循环）
            _PlayModeButton(audioHandler: audioHandler),
            const SizedBox(width: 16),
            // Previous
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded),
              iconSize: 36,
              color: colorScheme.onSurface,
              onPressed: audioHandler.skipToPrevious,
            ),
            const SizedBox(width: 12),
            // Play/Pause FAB — 带缩放/淡入切换动画
            FloatingActionButton(
              onPressed: () {
                if (playing) {
                  audioHandler.pause();
                } else {
                  audioHandler.play();
                }
              },
              elevation: 2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  key: ValueKey<bool>(playing),
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Next
            IconButton(
              icon: const Icon(Icons.skip_next_rounded),
              iconSize: 36,
              color: colorScheme.onSurface,
              onPressed: audioHandler.skipToNext,
            ),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }
}

/// 播放模式切换按钮：顺序 → 随机 → 单曲循环 → 列表循环
class _PlayModeButton extends ConsumerWidget {
  const _PlayModeButton({required this.audioHandler});

  final ah.MusicAudioHandler audioHandler;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final mode = ref.watch(playModeProvider);

    // 每种模式对应的图标、颜色和提示文字
    final (icon, color, tooltip) = switch (mode) {
      PlayMode.sequential => (
          Icons.arrow_right_alt_rounded,
          colorScheme.onSurfaceVariant,
          '顺序播放',
        ),
      PlayMode.shuffle => (
          Icons.shuffle_rounded,
          colorScheme.primary,
          '随机播放',
        ),
      PlayMode.repeatOne => (
          Icons.repeat_one_rounded,
          colorScheme.primary,
          '单曲循环',
        ),
      PlayMode.repeatAll => (
          Icons.repeat_rounded,
          colorScheme.primary,
          '列表循环',
        ),
    };

    return IconButton(
      icon: Icon(icon),
      iconSize: 24,
      color: color,
      tooltip: tooltip,
      onPressed: () {
        // 循环切换：sequential → shuffle → repeatOne → repeatAll → sequential
        final nextMode = switch (mode) {
          PlayMode.sequential => PlayMode.shuffle,
          PlayMode.shuffle => PlayMode.repeatOne,
          PlayMode.repeatOne => PlayMode.repeatAll,
          PlayMode.repeatAll => PlayMode.sequential,
        };
        ref.read(playModeProvider.notifier).state = nextMode;

        // 将播放模式同步到音频处理器
        switch (nextMode) {
          case PlayMode.sequential:
            audioHandler.setShuffle(false);
            audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
          case PlayMode.shuffle:
            audioHandler.setShuffle(true);
            audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
          case PlayMode.repeatOne:
            audioHandler.setShuffle(false);
            audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
          case PlayMode.repeatAll:
            audioHandler.setShuffle(false);
            audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        }
      },
    );
  }
}
