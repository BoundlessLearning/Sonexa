import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';
import 'package:sonexa/features/library/presentation/widgets/album_grid_tile.dart';
import 'package:shimmer/shimmer.dart';

/// 专辑网格标签页 — 显示分页专辑，点击进入详情
class AlbumsTab extends ConsumerStatefulWidget {
  const AlbumsTab({super.key});

  @override
  ConsumerState<AlbumsTab> createState() => _AlbumsTabState();
}

class _AlbumsTabState extends ConsumerState<AlbumsTab> {
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

    final notifier = ref.read(paginatedAlbumsProvider.notifier);
    if (!notifier.hasMore) return;

    setState(() => _isLoadingMore = true);
    await notifier.loadMore();
    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isLoadingMore = false);
    await ref.read(paginatedAlbumsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(paginatedAlbumsProvider);
    final l10n = AppLocalizations.of(context);

    return albumsAsync.when(
      loading: () => _buildShimmerGrid(context),
      error:
          (error, stack) => Center(
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
                  l10n.failedToLoad,
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
                  onPressed:
                      () =>
                          ref.read(paginatedAlbumsProvider.notifier).refresh(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
      data: (albums) {
        if (albums.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 240),
                Center(child: Text(l10n.noAlbums)),
              ],
            ),
          );
        }

        final api = ref.read(subsonicApiClientProvider).requireValue;
        final hasMore = ref.read(paginatedAlbumsProvider.notifier).hasMore;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final album = albums[index];

                    return AlbumGridTile(
                      album: album,
                      coverArtUrl: api.getCoverArtUrl(album.coverArtId),
                      heroTag: 'album-cover-${album.id}',
                      onTap: () => context.push('/library/album/${album.id}'),
                    );
                  }, childCount: albums.length),
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      _isLoadingMore
                          ? const Padding(
                            padding: EdgeInsets.only(bottom: 24),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          )
                          : hasMore
                          ? const SizedBox(height: 24)
                          : const SizedBox(height: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
