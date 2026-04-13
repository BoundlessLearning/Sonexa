import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ohmymusic/core/audio/audio_handler.dart' as ah;
import 'package:ohmymusic/core/utils/formatters.dart';
import 'package:ohmymusic/core/utils/diagnostic_logger.dart';
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
    final currentSong = ref.watch(currentSongProvider);
    final currentMediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
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
          Builder(
            builder: (context) {
              final songId = currentSong?.id;
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
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.lyrics_rounded),
                tooltip: '搜索歌词',
                onPressed: currentSong == null
                    ? null
                    : () {
                        context.push(Uri(
                          path: '/lyrics-search',
                          queryParameters: {
                            'songId': currentSong.id,
                            'artist': currentSong.artist,
                            'title': currentSong.title,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Builder(
          builder: (context) {
            final showLyrics = ref.watch(showLyricsProvider);

            return Column(
              children: [
                if (showLyrics) ...[
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: const LyricsDisplay(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  const Spacer(flex: 1),
                  Container(
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
                      child: currentMediaItem?.artUri != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                currentMediaItem!.artUri.toString(),
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
                  ),
                  const Spacer(flex: 1),
                ],
                Text(
                  currentSong?.title ?? '未播放',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  currentSong?.artist ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _SeekBar(audioHandler: audioHandler, mediaItem: currentMediaItem),
                const SizedBox(height: 16),
                _PlaybackControls(audioHandler: audioHandler),
                const Spacer(flex: 2),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// [Round7-F2] 进度条：拖拽时只更新视觉位置，松手时才执行 seek。
/// 避免拖拽过程中对 mpv 发起大量 seek 请求（streaming FLAC 会导致 ffmpeg seek failed）。
class _SeekBar extends ConsumerStatefulWidget {
  const _SeekBar({
    required this.audioHandler,
    required this.mediaItem,
  });

  final ah.MusicAudioHandler audioHandler;
  final MediaItem? mediaItem;

  @override
  ConsumerState<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<_SeekBar> {
  /// 是否正在拖拽中
  bool _dragging = false;
  /// 拖拽时的视觉位置（秒）
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final position = positionAsync.valueOrNull ?? Duration.zero;
    final duration =
        durationAsync.valueOrNull ?? widget.mediaItem?.duration ?? Duration.zero;

    final maxSeconds = duration.inSeconds.toDouble();
    // 拖拽中显示拖拽值，否则显示实际播放位置
    final displaySeconds = _dragging
        ? _dragValue
        : position.inSeconds.toDouble().clamp(0.0, maxSeconds > 0 ? maxSeconds : 1.0);

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
            value: displaySeconds,
            max: maxSeconds > 0 ? maxSeconds : 1.0,
            onChangeStart: (value) {
              // 开始拖拽：冻结位置更新
              setState(() {
                _dragging = true;
                _dragValue = value;
              });
            },
            onChanged: (value) {
              // 拖拽中：只更新视觉位置，不 seek
              setState(() {
                _dragValue = value;
              });
            },
            onChangeEnd: (value) {
              // 松手：执行实际 seek
              setState(() {
                _dragging = false;
              });
              DiagnosticLogger.instance
                  .log('[OP] seek_bar_change_end: seconds=${value.toInt()}');
              widget.audioHandler.seek(Duration(seconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(_dragging ? _dragValue.toInt() : position.inSeconds),
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
              onPressed: () {
                DiagnosticLogger.instance.log('[OP] previous_button_tap');
                audioHandler.skipToPrevious();
              },
            ),
            const SizedBox(width: 12),
            // Play/Pause FAB — 带缩放/淡入切换动画
            FloatingActionButton(
              onPressed: () {
                final action = playing ? 'pause_button_tap' : 'play_button_tap';
                DiagnosticLogger.instance.log('[OP] $action');
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
              onPressed: () {
                DiagnosticLogger.instance.log('[OP] next_button_tap');
                audioHandler.skipToNext();
              },
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
      onPressed: () async {
        // 循环切换：sequential → shuffle → repeatOne → repeatAll → sequential
        final nextMode = switch (mode) {
          PlayMode.sequential => PlayMode.shuffle,
          PlayMode.shuffle => PlayMode.repeatOne,
          PlayMode.repeatOne => PlayMode.repeatAll,
          PlayMode.repeatAll => PlayMode.sequential,
        };
        DiagnosticLogger.instance.log('[OP] play_mode_switch: $mode -> $nextMode');
        debugPrint('[DIAG] PlayMode switch: $mode → $nextMode');
        ref.read(playModeProvider.notifier).state = nextMode;

        switch (nextMode) {
          case PlayMode.sequential:
            debugPrint('[DIAG] PlayMode.sequential: setPlayMode(sequential)');
            await audioHandler.setPlayMode(ah.PlaybackMode.sequential);
          case PlayMode.shuffle:
            debugPrint('[DIAG] PlayMode.shuffle: setPlayMode(shuffle)');
            await audioHandler.setPlayMode(ah.PlaybackMode.shuffle);
          case PlayMode.repeatOne:
            debugPrint('[DIAG] PlayMode.repeatOne: setPlayMode(repeatOne)');
            await audioHandler.setPlayMode(ah.PlaybackMode.repeatOne);
          case PlayMode.repeatAll:
            debugPrint('[DIAG] PlayMode.repeatAll: setPlayMode(repeatAll)');
            await audioHandler.setPlayMode(ah.PlaybackMode.repeatAll);
        }
        debugPrint('[DIAG] PlayMode switch DONE: $nextMode');
      },
    );
  }
}
