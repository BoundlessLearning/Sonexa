import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/features/lyrics/domain/entities/lyrics.dart';
import 'package:sonexa/features/lyrics/presentation/providers/lyrics_provider.dart';
import 'package:sonexa/features/player/presentation/providers/player_provider.dart';

const double _previewHorizontalPadding = 24;
const double _previewVerticalPadding = 10;
const double _previewTranslationGap = 4;
const double _previewMinLineHeight = 52;
const Duration _previewScrollAnimationDuration = Duration(milliseconds: 260);
const Duration _candidateSwitchAnimationDuration = Duration(milliseconds: 280);
const double _candidateSwitchDragThreshold = 36;
const double _candidateSwitchVelocityThreshold = 280;

/// 歌词联网搜索页面。
/// 接收 songId、artist、title 参数，搜索公共同步歌词候选并供用户选择替换。
class LyricsSearchPage extends ConsumerStatefulWidget {
  const LyricsSearchPage({
    super.key,
    required this.songId,
    required this.artist,
    required this.title,
  });

  final String songId;
  final String artist;
  final String title;

  @override
  ConsumerState<LyricsSearchPage> createState() => _LyricsSearchPageState();
}

class _LyricsSearchPageState extends ConsumerState<LyricsSearchPage> {
  late TextEditingController _artistController;
  late TextEditingController _titleController;
  String? _searchQuery;
  int _searchVersion = 0;

  @override
  void initState() {
    super.initState();
    _artistController = TextEditingController(text: widget.artist);
    _titleController = TextEditingController(text: widget.title);
    _searchQuery = '${widget.songId}|${widget.artist}|${widget.title}';
  }

  @override
  void dispose() {
    _artistController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _doSearch() {
    final artist = _artistController.text.trim();
    final title = _titleController.text.trim();
    if (artist.isEmpty && title.isEmpty) {
      return;
    }

    setState(() {
      _searchQuery = '${widget.songId}|$artist|$title';
      _searchVersion++;
    });
    ref.invalidate(lyricsSearchProvider(_searchQuery!));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchLyrics), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.38,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _artistController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.artist,
                        prefixIcon: const Icon(Icons.person_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _doSearch(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        labelText: l10n.songTitle,
                        prefixIcon: const Icon(Icons.music_note_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _doSearch(),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _doSearch,
                        icon: const Icon(Icons.search_rounded),
                        label: Text(l10n.search),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _searchQuery == null
                    ? Center(
                      child: Text(
                        l10n.lyricsSearchHint,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                    : _LyricsCandidateCarousel(
                      key: ValueKey<String>(
                        '${_searchQuery!}::$_searchVersion',
                      ),
                      searchQuery: _searchQuery!,
                      songId: widget.songId,
                      artist: widget.artist,
                      title: widget.title,
                    ),
          ),
        ],
      ),
    );
  }
}

class _LyricsCandidateCarousel extends ConsumerStatefulWidget {
  const _LyricsCandidateCarousel({
    super.key,
    required this.searchQuery,
    required this.songId,
    required this.artist,
    required this.title,
  });

  final String searchQuery;
  final String songId;
  final String artist;
  final String title;

  @override
  ConsumerState<_LyricsCandidateCarousel> createState() =>
      _LyricsCandidateCarouselState();
}

class _LyricsCandidateCarouselState
    extends ConsumerState<_LyricsCandidateCarousel>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  double _dragOffset = 0;
  int? _dragTargetIndex;
  Animation<double>? _dragOffsetAnimation;
  VoidCallback? _afterSettle;
  late final AnimationController _settleController = AnimationController(
    vsync: this,
    duration: _candidateSwitchAnimationDuration,
  )..addListener(() {
    final animation = _dragOffsetAnimation;
    if (animation == null || !mounted) {
      return;
    }
    setState(() {
      _dragOffset = animation.value;
    });
  });

  @override
  void didUpdateWidget(covariant _LyricsCandidateCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _settleController.stop();
      _currentIndex = 0;
      _dragOffset = 0;
      _dragTargetIndex = null;
      _afterSettle = null;
    }
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _settleController.stop();
    _afterSettle = null;
  }

  void _handleHorizontalDragUpdate(
    DragUpdateDetails details,
    int itemCount,
    double viewportWidth,
  ) {
    final delta = details.primaryDelta ?? 0;
    if (delta == 0 || viewportWidth <= 0) {
      return;
    }

    final tentativeOffset = _dragOffset + delta;
    final isDraggingToPrevious = tentativeOffset > 0;
    final isDraggingToNext = tentativeOffset < 0;
    final hasPrevious = _currentIndex > 0;
    final hasNext = _currentIndex < itemCount - 1;
    final targetIndex =
        tentativeOffset < 0 && hasNext
            ? _currentIndex + 1
            : tentativeOffset > 0 && hasPrevious
            ? _currentIndex - 1
            : null;

    double nextOffset;
    if ((isDraggingToPrevious && !hasPrevious) ||
        (isDraggingToNext && !hasNext)) {
      nextOffset = _dragOffset + (delta * 0.18);
    } else {
      nextOffset = tentativeOffset.clamp(-viewportWidth, viewportWidth);
    }

    setState(() {
      _dragOffset = nextOffset;
      _dragTargetIndex = targetIndex;
    });
  }

  void _handleHorizontalDragEnd(
    DragEndDetails details,
    int itemCount,
    double viewportWidth,
  ) {
    if (viewportWidth <= 0) {
      return;
    }

    final velocity = details.primaryVelocity ?? 0;
    final dragDistance = _dragOffset.abs();
    final direction =
        _dragOffset < 0
            ? 1
            : _dragOffset > 0
            ? -1
            : 0;
    final targetIndex = _dragTargetIndex ?? _currentIndex;
    final shouldSwitch =
        direction != 0 &&
        targetIndex != _currentIndex &&
        (dragDistance >= _candidateSwitchDragThreshold ||
            velocity.abs() >= _candidateSwitchVelocityThreshold);

    if (!shouldSwitch) {
      _animateDragOffsetTo(
        0,
        onCompleted: () {
          if (!mounted) {
            return;
          }
          setState(() {
            _dragOffset = 0;
            _dragTargetIndex = null;
          });
        },
      );
      return;
    }

    final outgoingTarget = direction > 0 ? -viewportWidth : viewportWidth;
    _animateDragOffsetTo(
      outgoingTarget,
      onCompleted: () {
        if (!mounted) {
          return;
        }

        setState(() {
          _currentIndex = targetIndex;
          _dragOffset = 0;
          _dragTargetIndex = null;
        });
      },
    );
  }

  void _animateDragOffsetTo(double target, {VoidCallback? onCompleted}) {
    _dragOffsetAnimation = Tween<double>(
      begin: _dragOffset,
      end: target,
    ).animate(
      CurvedAnimation(parent: _settleController, curve: Curves.easeOutCubic),
    );
    _afterSettle = onCompleted;
    _settleController
      ..stop()
      ..reset()
      ..forward().whenCompleteOrCancel(() {
        final callback = _afterSettle;
        _afterSettle = null;
        callback?.call();
      });
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(lyricsSearchProvider(widget.searchQuery));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.lyricsSearchFailed(error),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            ),
          ),
      data: (results) {
        final syncedResults = results
            .where((lyrics) => lyrics.isSynced && lyrics.lines.isNotEmpty)
            .toList(growable: false);

        if (syncedResults.isEmpty) {
          return Center(
            child: Text(
              l10n.noLyricsFound,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final safeIndex = math.min(_currentIndex, syncedResults.length - 1);
        final selectedLyrics = syncedResults[safeIndex];
        final adjacentIndex = _dragTargetIndex;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewportWidth = constraints.maxWidth;
                    final dragProgress =
                        viewportWidth <= 0
                            ? 0.0
                            : (_dragOffset.abs() / viewportWidth).clamp(
                              0.0,
                              1.0,
                            );
                    final currentOpacity = 1 - (dragProgress * 0.45);
                    final adjacentOpacity = dragProgress.clamp(0.0, 1.0);

                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: _handleHorizontalDragStart,
                      onHorizontalDragUpdate:
                          (details) => _handleHorizontalDragUpdate(
                            details,
                            syncedResults.length,
                            viewportWidth,
                          ),
                      onHorizontalDragEnd:
                          (details) => _handleHorizontalDragEnd(
                            details,
                            syncedResults.length,
                            viewportWidth,
                          ),
                      child: ClipRect(
                        child: Stack(
                          fit: StackFit.expand,
                          children: List.generate(syncedResults.length, (
                            index,
                          ) {
                            final isCurrent = index == safeIndex;
                            final isAdjacent = index == adjacentIndex;
                            final preview = Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: _LyricsCandidatePreview(
                                key: ValueKey<int>(index),
                                lyrics: syncedResults[index],
                                songId: widget.songId,
                                isActive: isCurrent,
                              ),
                            );

                            if (!isCurrent && !isAdjacent) {
                              return Visibility(
                                visible: false,
                                maintainState: true,
                                maintainAnimation: true,
                                maintainSize: false,
                                child: preview,
                              );
                            }

                            final offsetX =
                                isCurrent
                                    ? _dragOffset
                                    : _dragOffset +
                                        (_dragOffset < 0
                                            ? viewportWidth
                                            : -viewportWidth);
                            final opacity =
                                isCurrent ? currentOpacity : adjacentOpacity;

                            return Transform.translate(
                              offset: Offset(offsetX, 0),
                              child: Opacity(opacity: opacity, child: preview),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              _CandidatePageIndicator(
                count: syncedResults.length,
                currentIndex: safeIndex,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _applyLyrics(context, ref, selectedLyrics),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l10n.use),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _applyLyrics(
    BuildContext context,
    WidgetRef ref,
    Lyrics lyrics,
  ) async {
    try {
      final repo = await ref.read(lyricsRepositoryProvider.future);
      await repo.replaceLyrics(lyrics);
      ref.invalidate(
        lyricsProvider(
          LyricsRequestSnapshot(
            songId: widget.songId,
            artist: widget.artist,
            title: widget.title,
          ),
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).lyricsReplaced)),
        );
        context.pop();
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).lyricsReplaceFailed(error),
            ),
          ),
        );
      }
    }
  }
}

class _LyricsCandidatePreview extends ConsumerStatefulWidget {
  const _LyricsCandidatePreview({
    super.key,
    required this.lyrics,
    required this.songId,
    required this.isActive,
  });

  final Lyrics lyrics;
  final String songId;
  final bool isActive;

  @override
  ConsumerState<_LyricsCandidatePreview> createState() =>
      _LyricsCandidatePreviewState();
}

class _LyricsCandidatePreviewState
    extends ConsumerState<_LyricsCandidatePreview> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _lineKeys = <GlobalKey>[];
  int _lastHighlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    _syncLineKeys(reset: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToPreviewLine());
  }

  @override
  void didUpdateWidget(covariant _LyricsCandidatePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lyrics.rawLrc != widget.lyrics.rawLrc ||
        oldWidget.lyrics.lines.length != widget.lyrics.lines.length) {
      _lastHighlightedIndex = -1;
      _syncLineKeys(reset: true);
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToPreviewLine());
    } else if (!oldWidget.isActive && widget.isActive) {
      _lastHighlightedIndex = -1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToPreviewLine());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _jumpToPreviewLine() {
    if (!mounted || !_scrollController.hasClients || _lineKeys.isEmpty) {
      return;
    }

    final previewIndex = _currentPreviewIndex();
    final targetContext = _lineKeys[previewIndex].currentContext;
    if (targetContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.35,
      duration: Duration.zero,
    );
  }

  int _previewLineIndex(List<LyricLine> lines) {
    final firstMeaningfulLine = lines.indexWhere(
      (line) => line.text.trim().isNotEmpty && line.text.trim() != '...',
    );
    final seedIndex = firstMeaningfulLine >= 0 ? firstMeaningfulLine : 0;
    return math.min(seedIndex + 2, math.max(lines.length - 1, 0));
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

  int _currentPreviewIndex() {
    final lines = widget.lyrics.lines;
    if (lines.isEmpty) {
      return 0;
    }

    final position = ref.read(resolvedPositionProvider);
    final offsetMs =
        ref.read(lyricsOffsetProvider(widget.songId)).valueOrNull ?? 0;
    final effectivePositionMs =
        (position.inMilliseconds + offsetMs).clamp(0, 1 << 31).toInt();
    final currentIndex =
        widget.lyrics.isSynced
            ? _findCurrentLineIndex(lines, effectivePositionMs)
            : -1;
    return currentIndex >= 0 ? currentIndex : _previewLineIndex(lines);
  }

  void _scheduleScroll(int index) {
    if (!widget.isActive ||
        index < 0 ||
        index >= _lineKeys.length ||
        index == _lastHighlightedIndex) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      final targetContext = _lineKeys[index].currentContext;
      if (targetContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.35,
        duration: _previewScrollAnimationDuration,
        curve: Curves.easeOutCubic,
      );
      _lastHighlightedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _syncLineKeys();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final position = ref.watch(resolvedPositionProvider);
    final offsetMs =
        ref.watch(lyricsOffsetProvider(widget.songId)).valueOrNull ?? 0;
    final lines = widget.lyrics.lines;
    final effectivePositionMs =
        (position.inMilliseconds + offsetMs).clamp(0, 1 << 31).toInt();
    final previewIndex =
        widget.lyrics.isSynced
            ? _findCurrentLineIndex(lines, effectivePositionMs)
            : -1;
    final highlightedIndex =
        previewIndex >= 0 ? previewIndex : _previewLineIndex(lines);

    if (widget.isActive) {
      _scheduleScroll(highlightedIndex);
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
        final topPadding = constraints.maxHeight * 0.34;
        final bottomPadding = constraints.maxHeight * 0.56;

        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: const [0, 0.1, 0.9, 1],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
              child: Column(
                children: List.generate(lines.length, (index) {
                  final line = lines[index];
                  final isCurrent = index == highlightedIndex;
                  final hasTranslation =
                      line.translation != null &&
                      line.translation!.trim().isNotEmpty;

                  return Padding(
                    key: _lineKeys[index],
                    padding: const EdgeInsets.symmetric(
                      horizontal: _previewHorizontalPadding,
                      vertical: _previewVerticalPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: _previewMinLineHeight,
                      ),
                      child: Container(
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                line.text.trim().isEmpty ? '...' : line.text,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: isCurrent ? activeStyle : inactiveStyle,
                              ),
                              if (hasTranslation) ...[
                                const SizedBox(height: _previewTranslationGap),
                                Opacity(
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
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CandidatePageIndicator extends StatelessWidget {
  const _CandidatePageIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: isActive ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color:
                isActive
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
