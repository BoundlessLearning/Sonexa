import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ohmymusic/features/lyrics/domain/entities/lyrics.dart';
import 'package:ohmymusic/features/lyrics/presentation/providers/lyrics_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

const double _lyricsHorizontalPadding = 24;
const double _lyricsVerticalPadding = 10;
const double _lyricsTranslationGap = 4;
const double _lyricsMinLineHeight = 52;
const Duration _lyricsTextAnimationDuration = Duration(milliseconds: 220);

/// 生产级歌词显示组件。
/// 支持同步歌词的自动滚动、高亮和纯文本歌词的舒适阅读。
class LyricsDisplay extends ConsumerWidget {
  const LyricsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songIdAsync = ref.watch(currentSongIdProvider);
    final songId = songIdAsync.valueOrNull;

    if (songId == null) {
      return const _LyricsPlaceholder(text: '暂无歌词');
    }

    final lyricsAsync = ref.watch(lyricsProvider(songId));

    return lyricsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _LyricsPlaceholder(text: '暂无歌词'),
      data: (lyrics) {
        if (lyrics == null || lyrics.lines.isEmpty) {
          return const _LyricsPlaceholder(text: '暂无歌词');
        }

        return _SyncedLyricsView(
          key: ValueKey<String>(songId),
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

/// 同步滚动歌词组件。
/// 采用二分查找当前行，并将激活歌词锚定在视口约 35% 的位置。
class _SyncedLyricsView extends ConsumerStatefulWidget {
  const _SyncedLyricsView({required this.lyrics, super.key});

  final Lyrics lyrics;

  @override
  ConsumerState<_SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends ConsumerState<_SyncedLyricsView> {
  final ScrollController _scrollController = ScrollController();
  int _lastHighlightedIndex = -1;

  @override
  void didUpdateWidget(covariant _SyncedLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lyrics.songId != widget.lyrics.songId) {
      _lastHighlightedIndex = -1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _scrollToLine({
    required int index,
    required _LyricsLayoutMetrics metrics,
    required double viewportHeight,
  }) {
    if (!_scrollController.hasClients || index < 0) {
      return;
    }
    if (index == _lastHighlightedIndex) {
      return;
    }

    _lastHighlightedIndex = index;

    final anchorOffset = viewportHeight * 0.35;
    final lineCenter =
        anchorOffset + metrics.offsets[index] + (metrics.heights[index] / 2);
    final targetOffset = lineCenter - anchorOffset;
    final clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    ).toDouble();
    final distance = (_scrollController.offset - clampedOffset).abs();
    final duration = Duration(
      milliseconds: (220 + (distance * 0.32).clamp(0, 420)).round(),
    );

    _scrollController.animateTo(
      clampedOffset,
      duration: duration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final lines = widget.lyrics.lines;
    final positionAsync = ref.watch(positionProvider);
    final position = positionAsync.valueOrNull ?? Duration.zero;
    final currentIndex = widget.lyrics.isSynced
        ? _findCurrentLineIndex(lines, position.inMilliseconds)
        : -1;

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
    final translationStyle =
        (textTheme.bodySmall ?? const TextStyle()).copyWith(
      fontSize: 13,
      height: 1.3,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.82),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _LyricsLayoutMetrics.measure(
          context: context,
          lines: lines,
          maxWidth: (constraints.maxWidth - (_lyricsHorizontalPadding * 2)).clamp(
            0.0,
            double.infinity,
          ).toDouble(),
          mainTextStyle: activeStyle,
          translationStyle: translationStyle,
        );

        if (widget.lyrics.isSynced && currentIndex >= 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToLine(
              index: currentIndex,
              metrics: metrics,
              viewportHeight: constraints.maxHeight,
            );
          });
        }

        final topPadding = constraints.maxHeight * 0.35;
        final bottomPadding = constraints.maxHeight * 0.65;

        return ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0, 0.08, 0.92, 1],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
            itemCount: lines.length,
            itemBuilder: (context, index) {
              final line = lines[index];
              final isCurrent = index == currentIndex;
              final hasTranslation =
                  line.translation != null && line.translation!.trim().isNotEmpty;

              return SizedBox(
                height: metrics.heights[index],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _lyricsHorizontalPadding,
                    vertical: _lyricsVerticalPadding,
                  ),
                  child: AnimatedContainer(
                    duration: _lyricsTextAnimationDuration,
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
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
                              style: isCurrent ? activeStyle : inactiveStyle,
                              textAlign: TextAlign.center,
                              child: Text(
                                line.text.trim().isEmpty ? '…' : line.text,
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
        );
      },
    );
  }
}

class _LyricsLayoutMetrics {
  const _LyricsLayoutMetrics({
    required this.offsets,
    required this.heights,
  });

  final List<double> offsets;
  final List<double> heights;

  static _LyricsLayoutMetrics measure({
    required BuildContext context,
    required List<LyricLine> lines,
    required double maxWidth,
    required TextStyle mainTextStyle,
    required TextStyle translationStyle,
  }) {
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final offsets = <double>[];
    final heights = <double>[];

    var runningOffset = 0.0;
    for (final line in lines) {
      offsets.add(runningOffset);
      final measuredHeight = _measureLineHeight(
        line: line,
        maxWidth: maxWidth,
        textDirection: textDirection,
        textScaler: textScaler,
        mainTextStyle: mainTextStyle,
        translationStyle: translationStyle,
      );
      heights.add(measuredHeight);
      runningOffset += measuredHeight;
    }

    return _LyricsLayoutMetrics(offsets: offsets, heights: heights);
  }

  static double _measureLineHeight({
    required LyricLine line,
    required double maxWidth,
    required TextDirection textDirection,
    required TextScaler textScaler,
    required TextStyle mainTextStyle,
    required TextStyle translationStyle,
  }) {
    final mainPainter = TextPainter(
      text: TextSpan(
        text: line.text.trim().isEmpty ? '…' : line.text,
        style: mainTextStyle,
      ),
      textAlign: TextAlign.center,
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 3,
    )..layout(maxWidth: maxWidth);

    var translationHeight = 0.0;
    final translation = line.translation?.trim();
    if (translation != null && translation.isNotEmpty) {
      final translationPainter = TextPainter(
        text: TextSpan(text: translation, style: translationStyle),
        textAlign: TextAlign.center,
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: 2,
      )..layout(maxWidth: maxWidth);
      translationHeight =
          translationPainter.height + _lyricsTranslationGap;
    }

    final contentHeight =
        mainPainter.height + translationHeight + (_lyricsVerticalPadding * 2) + 12;
    return contentHeight < _lyricsMinLineHeight
        ? _lyricsMinLineHeight
        : contentHeight;
  }
}
