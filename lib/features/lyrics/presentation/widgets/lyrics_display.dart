import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:ohmymusic/core/utils/diagnostic_logger.dart';
import 'package:ohmymusic/features/lyrics/domain/entities/lyrics.dart';
import 'package:ohmymusic/features/lyrics/presentation/providers/lyrics_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

const double _lyricsHorizontalPadding = 24;
const double _lyricsVerticalPadding = 10;
const double _lyricsTranslationGap = 4;
const double _lyricsMinLineHeight = 52;
const Duration _lyricsTextAnimationDuration = Duration(milliseconds: 220);
const Duration _lyricsScrollAnimationDuration = Duration(milliseconds: 280);

/// 生产级歌词显示组件。
/// 支持同步歌词的自动滚动、高亮和纯文本歌词的舒适阅读。
class LyricsDisplay extends ConsumerWidget {
  const LyricsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lyricsRequest = ref.watch(currentLyricsRequestProvider);

    if (lyricsRequest == null) {
      unawaited(DiagnosticLogger.instance.log(
        '[DIAG][LYRICS] placeholder: request=null',
      ));
      return const _LyricsPlaceholder(text: '暂无歌词');
    }

    final lyricsAsync = ref.watch(lyricsProvider(lyricsRequest));

    return lyricsAsync.when(
      loading: () {
        unawaited(DiagnosticLogger.instance.log(
          '[DIAG][LYRICS] loading: songId=${lyricsRequest.songId}',
        ));
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, _) {
        unawaited(DiagnosticLogger.instance.log(
          '[DIAG][LYRICS] placeholder: error for songId=${lyricsRequest.songId}, '
          'error=$error',
        ));
        return const _LyricsPlaceholder(text: '暂无歌词');
      },
      data: (lyrics) {
        if (lyrics == null || lyrics.lines.isEmpty) {
          unawaited(DiagnosticLogger.instance.log(
            '[DIAG][LYRICS] placeholder: empty data for songId=${lyricsRequest.songId}',
          ));
          return const _LyricsPlaceholder(text: '暂无歌词');
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

/// 同步滚动歌词组件。
/// 采用二分查找当前行，并将激活歌词锚定在视口约 35% 的位置。
class _SyncedLyricsView extends ConsumerStatefulWidget {
  const _SyncedLyricsView({required this.lyrics, super.key});

  final Lyrics lyrics;

  @override
  ConsumerState<_SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends ConsumerState<_SyncedLyricsView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  int _lastHighlightedIndex = -1;

  void _diag(String message) {
    unawaited(DiagnosticLogger.instance.log(message));
  }

  void _scheduleScroll(int index) {
    if (index < 0 || index == _lastHighlightedIndex) {
      return;
    }

    _diag('[DIAG][LYRICS] scheduleScroll: index=$index, '
        'last=$_lastHighlightedIndex, attached=${_itemScrollController.isAttached}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_scrollToLine(index));
    });
  }

  @override
  void didUpdateWidget(covariant _SyncedLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lyrics.songId != widget.lyrics.songId) {
      _diag('[DIAG][LYRICS] song changed: ${oldWidget.lyrics.songId} -> ${widget.lyrics.songId}');
      _lastHighlightedIndex = -1;
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

  Future<void> _scrollToLine(int index) async {
    if (!_itemScrollController.isAttached ||
        index < 0 ||
        index == _lastHighlightedIndex) {
      _diag('[DIAG][LYRICS] scrollTo skipped: '
          'index=$index, last=$_lastHighlightedIndex, '
          'attached=${_itemScrollController.isAttached}');
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
    final position = positionAsync.valueOrNull ?? Duration.zero;
    final currentIndex = widget.lyrics.isSynced
        ? _findCurrentLineIndex(lines, position.inMilliseconds)
        : -1;

    // _diag('[DIAG][LYRICS] build: '
    //     'songId=${widget.lyrics.songId}, '
    //     'isSynced=${widget.lyrics.isSynced}, '
    //     'positionMs=${position.inMilliseconds}, '
    //     'currentIndex=$currentIndex, '
    //     'lines=${lines.length}');

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
    final translationStyle =
        (textTheme.bodySmall ?? const TextStyle()).copyWith(
      fontSize: 13,
      height: 1.3,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.82),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final topPadding = constraints.maxHeight * 0.35;
        final bottomPadding = constraints.maxHeight * 0.65;

        return ScrollablePositionedList.builder(
          itemScrollController: _itemScrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          itemCount: lines.length,
          itemBuilder: (context, index) {
            final line = lines[index];
            final isCurrent = index == currentIndex;
            final hasTranslation =
                line.translation != null && line.translation!.trim().isNotEmpty;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _lyricsHorizontalPadding,
                vertical: _lyricsVerticalPadding,
              ),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: _lyricsMinLineHeight),
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
        );
      },
    );
  }
}
