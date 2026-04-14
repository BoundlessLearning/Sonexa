import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/features/lyrics/domain/entities/lyrics.dart';
import 'package:sonexa/features/lyrics/presentation/providers/lyrics_provider.dart';
import 'package:sonexa/features/player/presentation/providers/player_provider.dart';

const double _lyricsHorizontalPadding = 24;
const double _lyricsVerticalPadding = 10;
const double _lyricsTranslationGap = 4;
const double _lyricsMinLineHeight = 52;
const Duration _lyricsTextAnimationDuration = Duration(milliseconds: 220);
const Duration _lyricsScrollAnimationDuration = Duration(milliseconds: 280);
const Duration _lyricsScrubAutoReturnDelay = Duration(seconds: 3);

class LyricsDisplay extends ConsumerWidget {
  const LyricsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lyricsRequest = ref.watch(currentLyricsRequestProvider);

    if (lyricsRequest == null) {
      unawaited(
        DiagnosticLogger.instance.log(
          '[DIAG][LYRICS] placeholder: request=null',
        ),
      );
      return _LyricsPlaceholder(text: AppLocalizations.of(context).noLyrics);
    }

    final lyricsAsync = ref.watch(lyricsProvider(lyricsRequest));

    return lyricsAsync.when(
      loading: () {
        unawaited(
          DiagnosticLogger.instance.log(
            '[DIAG][LYRICS] loading: songId=${lyricsRequest.songId}',
          ),
        );
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, _) {
        unawaited(
          DiagnosticLogger.instance.log(
            '[DIAG][LYRICS] placeholder: error for songId=${lyricsRequest.songId}, '
            'error=$error',
          ),
        );
        return _LyricsPlaceholder(text: AppLocalizations.of(context).noLyrics);
      },
      data: (lyrics) {
        if (lyrics == null || lyrics.lines.isEmpty) {
          unawaited(
            DiagnosticLogger.instance.log(
              '[DIAG][LYRICS] placeholder: empty data for songId=${lyricsRequest.songId}',
            ),
          );
          return _LyricsPlaceholder(
            text: AppLocalizations.of(context).noLyrics,
          );
        }

        return _SyncedLyricsView(
          key: ValueKey<String>(lyricsRequest.songId),
          lyrics: lyrics,
        );
      },
    );
  }
}

class _LyricsPlaceholder extends StatelessWidget {
  const _LyricsPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _SyncedLyricsView extends ConsumerStatefulWidget {
  const _SyncedLyricsView({required this.lyrics, super.key});

  final Lyrics lyrics;

  @override
  ConsumerState<_SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends ConsumerState<_SyncedLyricsView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  int _lastHighlightedIndex = -1;
  int? _scrubTargetIndex;
  bool _isScrubbingLyrics = false;
  bool _showScrubGuide = false;
  Timer? _scrubReturnTimer;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_updateScrubTarget);
  }

  @override
  void dispose() {
    _scrubReturnTimer?.cancel();
    _itemPositionsListener.itemPositions.removeListener(_updateScrubTarget);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SyncedLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lyrics.songId != widget.lyrics.songId) {
      _diag(
        '[DIAG][LYRICS] song changed: ${oldWidget.lyrics.songId} -> ${widget.lyrics.songId}',
      );
      _lastHighlightedIndex = -1;
      _scrubReturnTimer?.cancel();
      _scrubTargetIndex = null;
      _isScrubbingLyrics = false;
      _showScrubGuide = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_itemScrollController.isAttached) {
          _diag('[DIAG][LYRICS] jumpTo(0) on song change');
          _itemScrollController.jumpTo(index: 0);
        } else {
          _diag('[DIAG][LYRICS] jumpTo skipped: controller not attached');
        }
      });
    }
  }

  void _diag(String message) {
    unawaited(DiagnosticLogger.instance.log(message));
  }

  void _scheduleScroll(int index) {
    if (_showScrubGuide || index < 0 || index == _lastHighlightedIndex) {
      return;
    }

    _diag(
      '[DIAG][LYRICS] scheduleScroll: index=$index, '
      'last=$_lastHighlightedIndex, attached=${_itemScrollController.isAttached}',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_scrollToLine(index));
    });
  }

  int _findCurrentLineIndex(List<LyricLine> lines, int positionMs) {
    var low = 0;
    var high = lines.length - 1;
    var result = -1;

    while (low <= high) {
      final mid = low + ((high - low) >> 1);
      if (lines[mid].timeMs <= positionMs) {
        result = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return result;
  }

  int? _findLineAtViewportCenter() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) {
      return null;
    }

    ItemPosition? best;
    double bestDistance = double.infinity;
    for (final position in positions) {
      if (position.index < 0 || position.index >= widget.lyrics.lines.length) {
        continue;
      }

      if (position.itemLeadingEdge <= 0.5 && position.itemTrailingEdge >= 0.5) {
        return position.index;
      }

      final center = (position.itemLeadingEdge + position.itemTrailingEdge) / 2;
      final distance = (center - 0.5).abs();
      if (distance < bestDistance) {
        best = position;
        bestDistance = distance;
      }
    }

    return best?.index;
  }

  void _updateScrubTarget() {
    if (!_showScrubGuide || !mounted) {
      return;
    }

    final nextIndex = _findLineAtViewportCenter();
    if (nextIndex == null || nextIndex == _scrubTargetIndex) {
      return;
    }

    setState(() {
      _scrubTargetIndex = nextIndex;
    });
  }

  void _handleScrollStart() {
    if (!widget.lyrics.isSynced) {
      return;
    }

    _scrubReturnTimer?.cancel();
    final targetIndex = _findLineAtViewportCenter();
    setState(() {
      _isScrubbingLyrics = true;
      _showScrubGuide = true;
      _scrubTargetIndex = targetIndex ?? _scrubTargetIndex;
    });
  }

  void _handleScrollEnd() {
    if (!widget.lyrics.isSynced || !_showScrubGuide) {
      return;
    }

    setState(() {
      _isScrubbingLyrics = false;
    });
    _startScrubReturnTimer();
  }

  void _startScrubReturnTimer() {
    _scrubReturnTimer?.cancel();
    _scrubReturnTimer = Timer(_lyricsScrubAutoReturnDelay, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _showScrubGuide = false;
        _isScrubbingLyrics = false;
        _scrubTargetIndex = null;
      });

      final position = ref.read(positionProvider).valueOrNull ?? Duration.zero;
      final offsetMs = ref.read(currentLyricsOffsetProvider);
      final effectivePositionMs =
          (position.inMilliseconds + offsetMs).clamp(0, 1 << 31).toInt();
      final currentIndex = _findCurrentLineIndex(
        widget.lyrics.lines,
        effectivePositionMs,
      );
      if (currentIndex >= 0) {
        _lastHighlightedIndex = -1;
        unawaited(_scrollToLine(currentIndex));
      }
    });
  }

  Future<void> _seekToScrubTarget(int offsetMs) async {
    final targetIndex = _scrubTargetIndex;
    if (targetIndex == null ||
        targetIndex < 0 ||
        targetIndex >= widget.lyrics.lines.length) {
      return;
    }

    _scrubReturnTimer?.cancel();
    final targetLine = widget.lyrics.lines[targetIndex];
    final seekMs = (targetLine.timeMs - offsetMs).clamp(0, 1 << 31).toInt();

    setState(() {
      _showScrubGuide = false;
      _isScrubbingLyrics = false;
    });

    await ref.read(audioHandlerProvider).seek(Duration(milliseconds: seekMs));
    _lastHighlightedIndex = -1;
    if (mounted) {
      unawaited(_scrollToLine(targetIndex));
    }
  }

  Future<void> _scrollToLine(int index) async {
    if (!_itemScrollController.isAttached ||
        index < 0 ||
        index == _lastHighlightedIndex) {
      _diag(
        '[DIAG][LYRICS] scrollTo skipped: '
        'index=$index, last=$_lastHighlightedIndex, '
        'attached=${_itemScrollController.isAttached}',
      );
      return;
    }

    _diag('[DIAG][LYRICS] scrollTo start: index=$index, alignment=0.35');
    await _itemScrollController.scrollTo(
      index: index,
      alignment: 0.35,
      duration: _lyricsScrollAnimationDuration,
      curve: Curves.easeOutCubic,
    );

    if (mounted) {
      _lastHighlightedIndex = index;
      _diag('[DIAG][LYRICS] scrollTo done: index=$index');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final lines = widget.lyrics.lines;
    final positionAsync = ref.watch(positionProvider);
    final offsetMs = ref.watch(currentLyricsOffsetProvider);
    final position = positionAsync.valueOrNull ?? Duration.zero;
    final effectivePositionMs =
        (position.inMilliseconds + offsetMs).clamp(0, 1 << 31).toInt();
    final currentIndex =
        widget.lyrics.isSynced
            ? _findCurrentLineIndex(lines, effectivePositionMs)
            : -1;

    if (widget.lyrics.isSynced && currentIndex >= 0) {
      _scheduleScroll(currentIndex);
    }

    final activeStyle = (textTheme.titleLarge ?? const TextStyle()).copyWith(
      fontSize: 21,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: colorScheme.primary,
    );
    final inactiveStyle = (textTheme.bodyLarge ?? const TextStyle()).copyWith(
      fontSize: 17,
      height: 1.35,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface.withValues(alpha: 0.72),
    );
    final translationStyle = (textTheme.bodySmall ?? const TextStyle())
        .copyWith(
          fontSize: 13,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.82),
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final topPadding = constraints.maxHeight * 0.35;
        final bottomPadding = constraints.maxHeight * 0.65;

        return Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  _handleScrollStart();
                } else if (notification is ScrollEndNotification) {
                  _handleScrollEnd();
                }
                return false;
              },
              child: ScrollablePositionedList.builder(
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: topPadding,
                  bottom: bottomPadding,
                ),
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  final line = lines[index];
                  final isCurrent = index == currentIndex;
                  final hasTranslation =
                      line.translation != null &&
                      line.translation!.trim().isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _lyricsHorizontalPadding,
                      vertical: _lyricsVerticalPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: _lyricsMinLineHeight,
                      ),
                      child: AnimatedContainer(
                        duration: _lyricsTextAnimationDuration,
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isCurrent
                                  ? colorScheme.primary.withValues(alpha: 0.08)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: AnimatedScale(
                            scale: isCurrent ? 1 : 0.97,
                            duration: _lyricsTextAnimationDuration,
                            curve: Curves.easeOutCubic,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: _lyricsTextAnimationDuration,
                                  curve: Curves.easeOutCubic,
                                  style:
                                      isCurrent ? activeStyle : inactiveStyle,
                                  textAlign: TextAlign.center,
                                  child: Text(
                                    line.text.trim().isEmpty ? '♪' : line.text,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (hasTranslation) ...[
                                  const SizedBox(height: _lyricsTranslationGap),
                                  AnimatedOpacity(
                                    duration: _lyricsTextAnimationDuration,
                                    curve: Curves.easeOutCubic,
                                    opacity: isCurrent ? 0.95 : 0.72,
                                    child: Text(
                                      line.translation!,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: translationStyle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _LyricsScrubGuide(
              visible: _showScrubGuide,
              timeLabel: _formatLyricTimestamp(
                _scrubTargetIndex == null
                    ? null
                    : lines[_scrubTargetIndex!].timeMs,
              ),
              isDragging: _isScrubbingLyrics,
              onSeek:
                  _scrubTargetIndex == null
                      ? null
                      : () => unawaited(_seekToScrubTarget(offsetMs)),
            ),
          ],
        );
      },
    );
  }
}

class _LyricsScrubGuide extends StatelessWidget {
  const _LyricsScrubGuide({
    required this.visible,
    required this.timeLabel,
    required this.isDragging,
    required this.onSeek,
  });

  final bool visible;
  final String timeLabel;
  final bool isDragging;
  final VoidCallback? onSeek;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: Padding(
                padding: const EdgeInsets.only(left: 14, right: 62),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        timeLabel,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.2),
                              colorScheme.primary.withValues(alpha: 0.75),
                              colorScheme.primary.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 14,
            child: IgnorePointer(
              ignoring: !visible,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                child: AnimatedScale(
                  scale: isDragging ? 0.92 : 1,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  child: Material(
                    color: colorScheme.primary,
                    shape: const CircleBorder(),
                    elevation: 4,
                    shadowColor: colorScheme.primary.withValues(alpha: 0.35),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onSeek,
                      child: SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: colorScheme.onPrimary,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatLyricTimestamp(int? timeMs) {
  if (timeMs == null) {
    return '--:--';
  }

  final duration = Duration(milliseconds: timeMs);
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
