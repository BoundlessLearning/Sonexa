import 'dart:async';

import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

void _lyricsDiag(String message) {
  unawaited(DiagnosticLogger.instance.log(message));
}

String _constraintsSummary(BoxConstraints constraints) {
  return 'w=${constraints.maxWidth.toStringAsFixed(1)}, '
      'h=${constraints.maxHeight.toStringAsFixed(1)}, '
      'bounded=${constraints.hasBoundedWidth}/${constraints.hasBoundedHeight}';
}

String _mediaItemSummary(MediaItem? item) {
  if (item == null) {
    return '<null>';
  }

  final songId = item.extras?['songId'] as String? ?? item.id;
  return 'id=${item.id}, songId=$songId, title="${item.title}", '
      'artist="${item.artist ?? ''}"';
}

class LyricsDisplay extends ConsumerWidget {
  const LyricsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lyricsRequest = ref.watch(currentLyricsRequestProvider);
        final showLyrics = ref.watch(showLyricsProvider);
        final currentMediaItem =
            ref.watch(currentMediaItemProvider).valueOrNull;
        final currentSong = ref.watch(currentSongProvider);
        _lyricsDiag(
          '[DIAG][LYRICS][UI] build: '
          'showLyrics=$showLyrics, constraints=${_constraintsSummary(constraints)}, '
          'request=$lyricsRequest, mediaItem=${_mediaItemSummary(currentMediaItem)}, '
          'currentSong=${currentSong == null ? '<null>' : 'id=${currentSong.id}, title="${currentSong.title}"'}',
        );

        if (lyricsRequest == null) {
          _lyricsDiag(
            '[DIAG][LYRICS][UI] placeholder: request=null, '
            'constraints=${_constraintsSummary(constraints)}',
          );
          return _LyricsPlaceholder(
            text: AppLocalizations.of(context).noLyrics,
          );
        }

        final lyricsAsync = ref.watch(lyricsProvider(lyricsRequest));

        return lyricsAsync.when(
          loading: () {
            _lyricsDiag(
              '[DIAG][LYRICS][UI] loading: songId=${lyricsRequest.songId}, '
              'constraints=${_constraintsSummary(constraints)}',
            );
            return const Center(child: CircularProgressIndicator());
          },
          error: (error, _) {
            _lyricsDiag(
              '[DIAG][LYRICS][UI] placeholder: error for songId=${lyricsRequest.songId}, '
              'error=$error, constraints=${_constraintsSummary(constraints)}',
            );
            return _LyricsPlaceholder(
              text: AppLocalizations.of(context).noLyrics,
            );
          },
          data: (lyrics) {
            if (lyrics == null || lyrics.lines.isEmpty) {
              _lyricsDiag(
                '[DIAG][LYRICS][UI] placeholder: empty data for songId=${lyricsRequest.songId}, '
                'result=${lyrics == null ? '<null>' : 'lines=${lyrics.lines.length}'}, '
                'constraints=${_constraintsSummary(constraints)}',
              );
              return _LyricsPlaceholder(
                text: AppLocalizations.of(context).noLyrics,
              );
            }

            _lyricsDiag(
              '[DIAG][LYRICS][UI] data: songId=${lyricsRequest.songId}, '
              'source=${lyrics.source.name}, synced=${lyrics.isSynced}, '
              'lines=${lyrics.lines.length}, constraints=${_constraintsSummary(constraints)}',
            );
            return _SyncedLyricsView(
              key: ValueKey<String>(lyricsRequest.songId),
              lyrics: lyrics,
            );
          },
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();
  final List<GlobalKey> _lineKeys = <GlobalKey>[];

  int _lastHighlightedIndex = -1;
  int? _scrubTargetIndex;
  bool _isScrubbingLyrics = false;
  bool _showScrubGuide = false;
  Timer? _scrubReturnTimer;
  DateTime? _lastViewDiagAt;
  int? _lastViewDiagIndex;
  int _scrollRequestId = 0;

  @override
  void initState() {
    super.initState();
    _syncLineKeys(reset: true);
    _scrollController.addListener(_updateScrubTarget);
  }

  @override
  void dispose() {
    _scrubReturnTimer?.cancel();
    _scrollController.removeListener(_updateScrubTarget);
    _scrollController.dispose();
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
      _scrollRequestId++;
      _syncLineKeys(reset: true);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _diag('[DIAG][LYRICS] jumpTo(0) on song change');
          _scrollController.jumpTo(0);
        } else {
          _diag('[DIAG][LYRICS] jumpTo skipped: controller has no clients');
        }
      });
    } else if (oldWidget.lyrics.lines.length != widget.lyrics.lines.length) {
      _syncLineKeys(reset: true);
    }
  }

  void _syncLineKeys({bool reset = false}) {
    if (reset) {
      _lineKeys
        ..clear()
        ..addAll(
          List<GlobalKey>.generate(
            widget.lyrics.lines.length,
            (_) => GlobalKey(),
          ),
        );
      return;
    }

    final targetLength = widget.lyrics.lines.length;
    if (_lineKeys.length == targetLength) {
      return;
    }

    if (_lineKeys.length < targetLength) {
      _lineKeys.addAll(
        List<GlobalKey>.generate(
          targetLength - _lineKeys.length,
          (_) => GlobalKey(),
        ),
      );
    } else {
      _lineKeys.removeRange(targetLength, _lineKeys.length);
    }
  }

  void _diag(String message) {
    unawaited(DiagnosticLogger.instance.log(message));
  }

  void _diagViewBuild({
    required BoxConstraints constraints,
    required int currentIndex,
    required Duration position,
    required int offsetMs,
  }) {
    final now = DateTime.now();
    final shouldLog =
        _lastViewDiagIndex != currentIndex ||
        _lastViewDiagAt == null ||
        now.difference(_lastViewDiagAt!) >= const Duration(seconds: 2);
    if (!shouldLog) {
      return;
    }

    _lastViewDiagIndex = currentIndex;
    _lastViewDiagAt = now;
    _diag(
      '[DIAG][LYRICS][VIEW] build: songId=${widget.lyrics.songId}, '
      'source=${widget.lyrics.source.name}, synced=${widget.lyrics.isSynced}, '
      'lines=${widget.lyrics.lines.length}, currentIndex=$currentIndex, '
      'lastHighlighted=$_lastHighlightedIndex, offsetMs=$offsetMs, '
      'position=$position, hasClients=${_scrollController.hasClients}, '
      'constraints=${_constraintsSummary(constraints)}',
    );
  }

  void _scheduleScroll(int index) {
    if (_showScrubGuide || index < 0 || index == _lastHighlightedIndex) {
      return;
    }

    _diag(
      '[DIAG][LYRICS] scheduleScroll: index=$index, '
      'last=$_lastHighlightedIndex, hasClients=${_scrollController.hasClients}',
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
    final viewportContext = _viewportKey.currentContext;
    final viewportBox = viewportContext?.findRenderObject() as RenderBox?;
    if (viewportBox == null || !viewportBox.hasSize) {
      return null;
    }

    final viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
    final centerY = viewportTop + viewportBox.size.height / 2;
    int? bestIndex;
    double bestDistance = double.infinity;
    for (var index = 0; index < _lineKeys.length; index++) {
      final lineContext = _lineKeys[index].currentContext;
      final lineBox = lineContext?.findRenderObject() as RenderBox?;
      if (lineBox == null || !lineBox.hasSize) {
        continue;
      }

      final lineTop = lineBox.localToGlobal(Offset.zero).dy;
      final lineBottom = lineTop + lineBox.size.height;
      if (lineTop <= centerY && lineBottom >= centerY) {
        return index;
      }

      final lineCenter = (lineTop + lineBottom) / 2;
      final distance = (lineCenter - centerY).abs();
      if (distance < bestDistance) {
        bestIndex = index;
        bestDistance = distance;
      }
    }

    return bestIndex;
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
    if (!_scrollController.hasClients ||
        index < 0 ||
        index >= _lineKeys.length ||
        index == _lastHighlightedIndex) {
      _diag(
        '[DIAG][LYRICS] scrollTo skipped: '
        'index=$index, last=$_lastHighlightedIndex, '
        'hasClients=${_scrollController.hasClients}, '
        'lineKeys=${_lineKeys.length}',
      );
      return;
    }

    final lineContext = _lineKeys[index].currentContext;
    if (lineContext == null) {
      _diag(
        '[DIAG][LYRICS] scrollTo skipped: index=$index has no line context',
      );
      return;
    }

    final requestId = ++_scrollRequestId;
    _diag('[DIAG][LYRICS] scrollTo start: index=$index, alignment=0.35');
    await Scrollable.ensureVisible(
      lineContext,
      alignment: 0.35,
      duration: _lyricsScrollAnimationDuration,
      curve: Curves.easeOutCubic,
    );

    if (mounted && requestId == _scrollRequestId) {
      _lastHighlightedIndex = index;
      _diag('[DIAG][LYRICS] scrollTo done: index=$index');
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncLineKeys();
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
        _diagViewBuild(
          constraints: constraints,
          currentIndex: currentIndex,
          position: position,
          offsetMs: offsetMs,
        );
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
                } else if (notification is ScrollUpdateNotification) {
                  _updateScrubTarget();
                }
                return false;
              },
              child: SingleChildScrollView(
                key: _viewportKey,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: topPadding,
                    bottom: bottomPadding,
                  ),
                  child: Column(
                    children: List.generate(lines.length, (index) {
                      final line = lines[index];
                      final isCurrent = index == currentIndex;
                      final hasTranslation =
                          line.translation != null &&
                          line.translation!.trim().isNotEmpty;

                      return Padding(
                        key: _lineKeys[index],
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
                                      ? colorScheme.primary.withValues(
                                        alpha: 0.08,
                                      )
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
                                          isCurrent
                                              ? activeStyle
                                              : inactiveStyle,
                                      textAlign: TextAlign.center,
                                      child: Text(
                                        line.text.trim().isEmpty
                                            ? '♪'
                                            : line.text,
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (hasTranslation) ...[
                                      const SizedBox(
                                        height: _lyricsTranslationGap,
                                      ),
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
                    }),
                  ),
                ),
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
