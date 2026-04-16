import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sonexa/core/audio/audio_handler.dart' as ah;
import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/core/utils/formatters.dart';
import 'package:sonexa/features/library/domain/entities/song.dart';
import 'package:sonexa/features/library/presentation/widgets/song_actions_sheet.dart';
import 'package:sonexa/features/lyrics/presentation/providers/lyrics_provider.dart';
import 'package:sonexa/features/lyrics/presentation/widgets/lyrics_display.dart';
import 'package:sonexa/features/player/presentation/providers/favorites_provider.dart';
import 'package:sonexa/features/player/presentation/providers/player_provider.dart';

class NowPlayingPage extends ConsumerStatefulWidget {
  const NowPlayingPage({super.key});

  @override
  ConsumerState<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends ConsumerState<NowPlayingPage> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = ref.read(showLyricsProvider) ? 1 : 0;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _animateToPage(int page) async {
    if (_currentPage == page) {
      return;
    }

    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _showLyricsMenu(Song song) async {
    final l10n = AppLocalizations.of(context);

    final action = await showModalBottomSheet<_LyricsSheetAction>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.tune_rounded),
                title: Text(l10n.adjustLyrics),
                subtitle: Text(l10n.adjustLyricsDescription),
                onTap:
                    () => Navigator.of(context).pop(_LyricsSheetAction.adjust),
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded),
                title: Text(l10n.switchLyrics),
                subtitle: Text(l10n.switchLyricsDescription),
                onTap:
                    () => Navigator.of(
                      context,
                    ).pop(_LyricsSheetAction.switchLyrics),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _LyricsSheetAction.adjust:
        await _showLyricsAdjustSheet(song.id);
        return;
      case _LyricsSheetAction.switchLyrics:
        context.push(
          Uri(
            path: '/lyrics-search',
            queryParameters: {
              'songId': song.id,
              'artist': song.artist,
              'title': song.title,
            },
          ).toString(),
        );
        return;
    }
  }

  Future<void> _showLyricsAdjustSheet(String songId) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final offsetAsync = ref.watch(lyricsOffsetProvider(songId));
            final offsetMs = offsetAsync.valueOrNull ?? 0;
            final notifier = ref.read(lyricsOffsetProvider(songId).notifier);
            final l10n = AppLocalizations.of(context);

            Future<void> updateOffset(int nextOffset) async {
              await notifier.setOffset(nextOffset);
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.lyricsCalibration,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatLyricsOffsetLabel(context, offsetMs),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: offsetMs.toDouble().clamp(-3000, 3000),
                      min: -3000,
                      max: 3000,
                      divisions: 60,
                      label: _formatLyricsOffsetLabel(context, offsetMs),
                      onChanged: (value) => updateOffset(value.round()),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _OffsetChip(
                          label: l10n.delayHalfSecond,
                          onTap: () => updateOffset(offsetMs - 500),
                        ),
                        _OffsetChip(
                          label: l10n.delayTenthSecond,
                          onTap: () => updateOffset(offsetMs - 100),
                        ),
                        _OffsetChip(
                          label: l10n.advanceTenthSecond,
                          onTap: () => updateOffset(offsetMs + 100),
                        ),
                        _OffsetChip(
                          label: l10n.advanceHalfSecond,
                          onTap: () => updateOffset(offsetMs + 500),
                        ),
                        _OffsetChip(label: l10n.reset, onTap: notifier.reset),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final favorites = ref.watch(favoritesNotifierProvider);
    final currentSong = ref.watch(currentSongProvider);
    final currentMediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final songId = currentSong?.id;
    final isFavorite = songId != null && favorites.contains(songId);
    final coverUrl = currentMediaItem?.artUri?.toString();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          iconSize: 32,
          onPressed: () => context.pop(),
        ),
        title: _PageIndicator(currentPage: _currentPage, onTap: _animateToPage),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: () => context.push('/queue'),
          ),
          IconButton(
            icon: const _TwoDotMoreIcon(),
            tooltip: l10n.moreActions,
            onPressed:
                currentSong == null
                    ? null
                    : () => showSongActionsSheet(
                      context,
                      song: currentSong,
                      coverUrl: coverUrl,
                      routeBasePath: '/now-playing',
                    ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                  ref.read(showLyricsProvider.notifier).state = page == 1;
                },
                children: [
                  _ArtworkPage(coverUrl: coverUrl),
                  _LyricsPage(
                    onLongPress:
                        currentSong == null
                            ? null
                            : () => _showLyricsMenu(currentSong),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currentSong?.title ?? l10n.noTrackPlaying,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              currentSong?.artist ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _SeekBar(audioHandler: audioHandler, mediaItem: currentMediaItem),
            const SizedBox(height: 8),
            _PlaybackControls(
              audioHandler: audioHandler,
              songId: songId,
              isFavorite: isFavorite,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ArtworkPage extends StatelessWidget {
  const _ArtworkPage({required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Hero(
          tag: 'now-playing-cover',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child:
                coverUrl != null && coverUrl!.isNotEmpty
                    ? Image.network(
                      coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Icon(Icons.album, size: 180),
                    )
                    : const Icon(Icons.album, size: 180),
          ),
        ),
      ),
    );
  }
}

class _LyricsPage extends ConsumerWidget {
  const _LyricsPage({this.onLongPress});

  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final showLyrics = ref.watch(showLyricsProvider);
    final currentMediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final currentSong = ref.watch(currentSongProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        DiagnosticLogger.instance.log(
          '[DIAG][LYRICS][PAGE] build: showLyrics=$showLyrics, '
          'constraints=w=${constraints.maxWidth.toStringAsFixed(1)}, '
          'h=${constraints.maxHeight.toStringAsFixed(1)}, '
          'currentSong=${currentSong == null ? '<null>' : 'id=${currentSong.id}, title="${currentSong.title}"'}, '
          'mediaItem=${currentMediaItem == null ? '<null>' : 'id=${currentMediaItem.id}, title="${currentMediaItem.title}"'}',
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: onLongPress,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const LyricsDisplay(),
            ),
          ),
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage, required this.onTap});

  final int currentPage;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildMarker(int index) {
      final active = currentPage == index;
      return GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: active ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color:
                active
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [buildMarker(0), buildMarker(1)],
    );
  }
}

class _TwoDotMoreIcon extends StatelessWidget {
  const _TwoDotMoreIcon();

  @override
  Widget build(BuildContext context) {
    final color =
        IconTheme.of(context).color ?? Theme.of(context).iconTheme.color;
    return SizedBox(
      width: 20,
      height: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Dot(color: color),
          const SizedBox(height: 4),
          _Dot(color: color),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SeekBar extends ConsumerStatefulWidget {
  const _SeekBar({required this.audioHandler, required this.mediaItem});

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
        durationAsync.valueOrNull ??
        widget.mediaItem?.duration ??
        Duration.zero;

    final maxSeconds = duration.inSeconds.toDouble();
    final safeMaxSeconds = maxSeconds > 0 ? maxSeconds : 1.0;
    final bufferedSeconds = bufferedPosition.inSeconds.toDouble().clamp(
      0.0,
      safeMaxSeconds,
    );
    final displaySeconds =
        _dragging
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
            secondaryActiveTrackColor: colorScheme.onSurfaceVariant.withValues(
              alpha: 0.28,
            ),
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
              ref.read(playerSeekIntentProvider.notifier).state =
                  DateTime.now();
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
                formatDuration(
                  _dragging ? _dragValue.toInt() : position.inSeconds,
                ),
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
              child: Center(child: _PlayModeButton(audioHandler: audioHandler)),
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
                      final action =
                          playing ? 'pause_button_tap' : 'play_button_tap';
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
                  onPressed:
                      songId == null
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
                  color:
                      isFavorite
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                  tooltip:
                      isFavorite
                          ? AppLocalizations.of(context).unfavorite
                          : AppLocalizations.of(context).favorite,
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
    final l10n = AppLocalizations.of(context);

    final (icon, color, tooltip) = switch (mode) {
      PlayMode.sequential => (
        Icons.arrow_right_alt_rounded,
        colorScheme.onSurfaceVariant,
        l10n.sequentialPlay,
      ),
      PlayMode.shuffle => (
        Icons.shuffle_rounded,
        colorScheme.primary,
        l10n.shufflePlay,
      ),
      PlayMode.repeatOne => (
        Icons.repeat_one_rounded,
        colorScheme.primary,
        l10n.repeatOne,
      ),
      PlayMode.repeatAll => (
        Icons.repeat_rounded,
        colorScheme.primary,
        l10n.repeatAll,
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
        DiagnosticLogger.instance.log(
          '[OP] play_mode_switch: $mode -> $nextMode',
        );
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

class _OffsetChip extends StatelessWidget {
  const _OffsetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

String _formatLyricsOffsetLabel(BuildContext context, int offsetMs) {
  final l10n = AppLocalizations.of(context);
  if (offsetMs == 0) {
    return l10n.noLyricsOffset;
  }

  final hasFraction = offsetMs.abs() % 1000 != 0;
  final seconds = (offsetMs.abs() / 1000).toStringAsFixed(hasFraction ? 1 : 0);
  return offsetMs > 0
      ? l10n.lyricsAdvanced(seconds)
      : l10n.lyricsDelayed(seconds);
}

enum _LyricsSheetAction { adjust, switchLyrics }

@Preview(name: 'Now Playing / Cover')
Widget previewNowPlayingCover() {
  return const MaterialApp(
    home: _PreviewNowPlayingScaffold(
      currentPage: 0,
      title: '我们的歌谣',
      artist: '群星',
    ),
  );
}

@Preview(name: 'Now Playing / Lyrics')
Widget previewNowPlayingLyrics() {
  return const MaterialApp(
    home: _PreviewNowPlayingScaffold(
      currentPage: 1,
      title: '我们的歌谣',
      artist: '群星',
    ),
  );
}

class _PreviewNowPlayingScaffold extends StatelessWidget {
  const _PreviewNowPlayingScaffold({
    required this.currentPage,
    required this.title,
    required this.artist,
  });

  final int currentPage;
  final String title;
  final String artist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onPressed: _noop,
        ),
        title: _PageIndicator(currentPage: currentPage, onTap: (_) {}),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: _noop,
          ),
          IconButton(icon: const _TwoDotMoreIcon(), onPressed: _noop),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            Expanded(
              child:
                  currentPage == 0
                      ? const _ArtworkPage(coverUrl: null)
                      : const _PreviewLyricsPage(),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              artist,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const _PreviewSeekBar(),
            const SizedBox(height: 8),
            const _PreviewPlaybackControls(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PreviewLyricsPage extends StatelessWidget {
  const _PreviewLyricsPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: const Text('歌词区域预览'),
    );
  }
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('1:12'), Text('5:17')],
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
            child: Icon(Icons.shuffle_rounded, color: colorScheme.primary),
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
            child: Icon(Icons.favorite_rounded, color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

void _noop() {}
