import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ohmymusic/features/lyrics/domain/entities/lyrics.dart';
import 'package:ohmymusic/features/lyrics/presentation/providers/lyrics_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

/// 同步滚动歌词显示组件。
/// 根据当前播放进度自动高亮并滚动到对应歌词行。
class LyricsDisplay extends ConsumerStatefulWidget {
  const LyricsDisplay({super.key});

  @override
  ConsumerState<LyricsDisplay> createState() => _LyricsDisplayState();
}

class _LyricsDisplayState extends ConsumerState<LyricsDisplay> {
  final ScrollController _scrollController = ScrollController();

  /// 每行歌词的估算高度（含 padding）。
  static const double _itemHeight = 40.0;

  /// 上一次滚动到的行索引，避免重复触发动画。
  int _lastScrolledIndex = -1;

  /// 上一次显示歌词的歌曲 ID，用于检测切歌并重置滚动状态。
  String? _lastSongId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 查找当前应高亮的歌词行索引。
  /// 返回最后一个 timeMs <= 当前播放毫秒数的行。
  int _findCurrentLineIndex(List<LyricLine> lines, int positionMs) {
    int currentIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].timeMs <= positionMs) {
        currentIndex = i;
      } else {
        break;
      }
    }
    return currentIndex;
  }

  /// 自动滚动到指定行，使其尽量居中显示。
  void _scrollToLine(int index, double viewportHeight) {
    if (!_scrollController.hasClients) return;
    if (index == _lastScrolledIndex) return;
    _lastScrolledIndex = index;

    // 目标偏移量：将当前行居中
    final targetOffset =
        (index * _itemHeight) - (viewportHeight / 2) + (_itemHeight / 2);
    final clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 响应式监听当前歌曲 ID（切歌自动重建）
    final songIdAsync = ref.watch(currentSongIdProvider);
    final songId = songIdAsync.valueOrNull;

    // 切歌时重置滚动状态
    if (songId != null && songId != _lastSongId) {
      _lastSongId = songId;
      _lastScrolledIndex = -1;
      // 切歌后异步重置滚动位置到顶部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }

    // 无歌曲 ID 时显示占位
    if (songId == null) {
      return Center(
        child: Text(
          '暂无歌词',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    // 监听歌词数据
    final lyricsAsync = ref.watch(lyricsProvider(songId));

    return lyricsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(
          '暂无歌词',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      data: (lyrics) {
        // 无歌词或歌词行为空
        if (lyrics == null || lyrics.lines.isEmpty) {
          return Center(
            child: Text(
              '暂无歌词',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          );
        }

        final positionAsync = ref.watch(positionProvider);
        final position = positionAsync.valueOrNull ?? Duration.zero;
        final currentIndex = lyrics.isSynced
            ? _findCurrentLineIndex(lyrics.lines, position.inMilliseconds)
            : -1;

        return LayoutBuilder(
          builder: (context, constraints) {
            if (lyrics.isSynced && currentIndex >= 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToLine(currentIndex, constraints.maxHeight);
              });
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: lyrics.lines.length,
              // 强制每行歌词高度一致，确保 _scrollToLine 的偏移计算精确匹配实际布局
              itemExtent: _itemHeight,
              // 上下留白，让首尾歌词行也能居中
              padding: EdgeInsets.symmetric(
                vertical: constraints.maxHeight / 2 - _itemHeight / 2,
              ),
              itemBuilder: (context, index) {
                final line = lyrics.lines[index];
                final isCurrent = index == currentIndex;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Center(
                    child: Text(
                      line.text,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: isCurrent
                          ? textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            )
                          : textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
