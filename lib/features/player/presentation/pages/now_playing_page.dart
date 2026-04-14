import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ohmymusic/core/audio/audio_handler.dart' as ah;
import 'package:ohmymusic/core/utils/diagnostic_logger.dart';
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
    final currentSong = ref.watch(currentSongProvider);
    final currentMediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final showLyrics = ref.watch(showLyricsProvider);
    final songId = currentSong?.id;
    final isFavorite = songId != null && favorites.contains(songId);

    return NowPlayingView(
      title: currentSong?.title ?? '未播放',
      artist: currentSong?.artist ?? '',
      coverUrl: currentMediaItem?.artUri?.toString(),
      showLyrics: showLyrics,
      mediaPanel: showLyrics
          ? const _LyricsPanel()
          : _ArtworkPanel(coverUrl: currentMediaItem?.artUri?.toString()),
      seekBar: _SeekBar(
        audioHandler: audioHandler,
        mediaItem: currentMediaItem,
      ),
      playbackControls: _PlaybackControls(
        audioHandler: audioHandler,
        songId: songId,
        isFavorite: isFavorite,
      ),
      onClose: () => context.pop(),
      onToggleLyrics: () =>
          ref.read(showLyricsProvider.notifier).state = !showLyrics,
      onSearchLyrics: currentSong == null
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
      onShowQueue: () => context.push('/queue'),
    );
  }
}

class NowPlayingView extends StatelessWidget {
  const NowPlayingView({
    super.key,
    required this.title,
    required this.artist,
    required this.showLyrics,
    required this.mediaPanel,
    required this.seekBar,
    required this.playbackControls,
    required this.onClose,
    required this.onToggleLyrics,
    required this.onShowQueue,
    this.coverUrl,
    this.onSearchLyrics,
  });

  final String title;
  final String artist;
  final String? coverUrl;
  final bool showLyrics;
  final Widget mediaPanel;
  final Widget seekBar;
  final Widget playbackControls;
  final VoidCallback onClose;
  final VoidCallback onToggleLyrics;
  final VoidCallback onShowQueue;
  final VoidCallback? onSearchLyrics;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          iconSize: 32,
          onPressed: onClose,
        ),
        title: const Text('正在播放'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_snippet_rounded),
            color: showLyrics
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            onPressed: onToggleLyrics,
            tooltip: showLyrics ? '显示封面' : '显示歌词',
          ),
          IconButton(
            icon: const Icon(Icons.lyrics_rounded),
            tooltip: '搜索歌词',
            onPressed: onSearchLyrics,
          ),
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: onShowQueue,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            Flexible(
              flex: showLyrics ? 5 : 4,
              child: Column(
                mainAxisAlignment:
                    showLyrics ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  mediaPanel,
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            seekBar,
            const SizedBox(height: 8),
            playbackControls,
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _LyricsPanel extends StatelessWidget {
  const _LyricsPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const LyricsDisplay(),
        ),
      ),
    );
  }
}

class _ArtworkPanel extends StatelessWidget {
  const _ArtworkPanel({this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        child: coverUrl != null && coverUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  coverUrl!,
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
  }
}

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
  bool _dragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(positionProvider);
    final bufferedPositionAsync = ref.watch(bufferedPositionProvider);
    final durationAsync = ref.watch(durationProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final position = positionAsync.valueOrNull ?? Duration.zero;
    final bufferedPosition = bufferedPositionAsync.valueOrNull ?? Duration.zero;
    final duration =
        durationAsync.valueOrNull ?? widget.mediaItem?.duration ?? Duration.zero;

    final maxSeconds = duration.inSeconds.toDouble();
    final safeMaxSeconds = maxSeconds > 0 ? maxSeconds : 1.0;
    final bufferedSeconds =
        bufferedPosition.inSeconds.toDouble().clamp(0.0, safeMaxSeconds);
    final displaySeconds = _dragging
        ? _dragValue
        : position.inSeconds.toDouble().clamp(0.0, safeMaxSeconds);

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            secondaryActiveTrackColor:
                colorScheme.onSurfaceVariant.withValues(alpha: 0.28),
            thumbColor: colorScheme.primary,
          ),
          child: Slider(
            value: displaySeconds,
            secondaryTrackValue: bufferedSeconds,
            max: safeMaxSeconds,
            onChangeStart: (value) {
              setState(() {
                _dragging = true;
                _dragValue = value;
              });
            },
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
            },
            onChangeEnd: (value) {
              setState(() {
                _dragging = false;
              });
              ref.read(playerSeekIntentProvider.notifier).state = DateTime.now();
              DiagnosticLogger.instance.log(
                '[OP] seek_bar_change_end: seconds=${value.toInt()}',
              );
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

class _PlaybackControls extends ConsumerWidget {
  const _PlaybackControls({
    required this.audioHandler,
    required this.songId,
    required this.isFavorite,
  });

  final ah.MusicAudioHandler audioHandler;
  final String? songId;
  final bool isFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;

        return Row(
          children: [
            SizedBox(
              width: 48,
              child: Center(
                child: _PlayModeButton(audioHandler: audioHandler),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded),
                    iconSize: 36,
                    color: colorScheme.onSurface,
                    onPressed: () {
                      DiagnosticLogger.instance.log('[OP] next_button_tap');
                      audioHandler.skipToNext();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 48,
              child: Center(
                child: IconButton(
                  onPressed: songId == null
                      ? null
                      : () => ref
                          .read(favoritesNotifierProvider.notifier)
                          .toggleFavorite(songId!),
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                  ),
                  iconSize: 24,
                  color: isFavorite
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  tooltip: isFavorite ? '取消收藏' : '收藏',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlayModeButton extends ConsumerWidget {
  const _PlayModeButton({required this.audioHandler});

  final ah.MusicAudioHandler audioHandler;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final mode = ref.watch(playModeProvider);

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
        final nextMode = switch (mode) {
          PlayMode.sequential => PlayMode.shuffle,
          PlayMode.shuffle => PlayMode.repeatOne,
          PlayMode.repeatOne => PlayMode.repeatAll,
          PlayMode.repeatAll => PlayMode.sequential,
        };
        DiagnosticLogger.instance.log('[OP] play_mode_switch: $mode -> $nextMode');
        ref.read(playModeProvider.notifier).state = nextMode;

        switch (nextMode) {
          case PlayMode.sequential:
            await audioHandler.setPlayMode(ah.PlaybackMode.sequential);
          case PlayMode.shuffle:
            await audioHandler.setPlayMode(ah.PlaybackMode.shuffle);
          case PlayMode.repeatOne:
            await audioHandler.setPlayMode(ah.PlaybackMode.repeatOne);
          case PlayMode.repeatAll:
            await audioHandler.setPlayMode(ah.PlaybackMode.repeatAll);
        }
      },
    );
  }
}

@Preview(name: 'Now Playing / Artwork')
Widget previewNowPlayingArtwork() {
  return MaterialApp(
    home: NowPlayingView(
      title: '我们的歌谣',
      artist: '群星',
      coverUrl: null,
      showLyrics: false,
      mediaPanel: const _ArtworkPanel(),
      seekBar: const _PreviewSeekBar(),
      playbackControls: const _PreviewPlaybackControls(),
      onClose: _noop,
      onToggleLyrics: _noop,
      onSearchLyrics: _noop,
      onShowQueue: _noop,
    ),
  );
}

@Preview(name: 'Now Playing / Lyrics')
Widget previewNowPlayingLyrics() {
  return MaterialApp(
    home: NowPlayingView(
      title: '我们的歌谣',
      artist: '群星',
      coverUrl: null,
      showLyrics: true,
      mediaPanel: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Text('歌词区域预览'),
        ),
      ),
      seekBar: const _PreviewSeekBar(),
      playbackControls: const _PreviewPlaybackControls(),
      onClose: _noop,
      onToggleLyrics: _noop,
      onSearchLyrics: _noop,
      onShowQueue: _noop,
    ),
  );
}

class _PreviewSeekBar extends StatelessWidget {
  const _PreviewSeekBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: 72,
          secondaryTrackValue: 128,
          max: 317,
          onChanged: (_) {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('1:12'),
              Text('5:17'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewPlaybackControls extends StatelessWidget {
  const _PreviewPlaybackControls();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Center(
            child: Icon(
              Icons.shuffle_rounded,
              color: colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.skip_previous_rounded, size: 36),
              const SizedBox(width: 12),
              FloatingActionButton(
                onPressed: _noop,
                elevation: 2,
                child: const Icon(Icons.pause_rounded, size: 36),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.skip_next_rounded, size: 36),
            ],
          ),
        ),
        SizedBox(
          width: 48,
          child: Center(
            child: Icon(
              Icons.favorite_rounded,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

void _noop() {}
