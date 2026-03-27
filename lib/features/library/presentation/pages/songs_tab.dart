import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ohmymusic/core/audio/media_item_converter.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';
import 'package:ohmymusic/features/library/presentation/widgets/song_list_tile.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';
import 'package:shimmer/shimmer.dart';

/// 歌曲列表标签页 — 显示分页歌曲，点击播放
class SongsTab extends ConsumerStatefulWidget {
  const SongsTab({super.key});

  @override
  ConsumerState<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends ConsumerState<SongsTab> {
  late final ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    final notifier = ref.read(paginatedSongsProvider.notifier);
    if (!notifier.hasMore) return;

    setState(() => _isLoadingMore = true);
    await notifier.loadMore();
    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isLoadingMore = false);
    await ref.read(paginatedSongsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(paginatedSongsProvider);

    return songsAsync.when(
      loading: () => _buildShimmerList(context),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => ref.read(paginatedSongsProvider.notifier).refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (songs) {
        if (songs.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 240),
                Center(child: Text('暂无歌曲')),
              ],
            ),
          );
        }

        final api = ref.read(subsonicApiClientProvider);
        final hasMore = ref.read(paginatedSongsProvider.notifier).hasMore;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: songs.length + 1,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              if (index == songs.length) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        )
                      : hasMore
                          ? const SizedBox(height: 24)
                          : const SizedBox(height: 12),
                );
              }

              final song = songs[index];

              return SongListTile(
                song: song,
                coverArtUrl: api.getCoverArtUrl(song.coverArtId),
                onTap: () {
                  final audioHandler = ref.read(audioHandlerProvider);
                  final items = songs
                      .map((s) => s.toMediaItem(
                            api.getStreamUrl(s.id),
                            api.getCoverArtUrl(s.coverArtId),
                          ))
                      .toList();
                  audioHandler.loadAndPlay(items, initialIndex: index);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: ListView.builder(
        itemCount: 10,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            title: Container(
              height: 14,
              width: 160,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              height: 12,
              width: 120,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }
}
