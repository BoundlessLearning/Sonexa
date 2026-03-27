import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:ohmymusic/core/audio/media_item_converter.dart';
import 'package:ohmymusic/core/widgets/app_image.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';
import 'package:ohmymusic/features/library/presentation/widgets/album_grid_tile.dart';
import 'package:ohmymusic/features/library/presentation/widgets/song_list_tile.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

/// 艺术家详情页 — 展示艺术家封面、热门歌曲、专辑列表
class ArtistDetailPage extends ConsumerStatefulWidget {
  const ArtistDetailPage({super.key, required this.artistId});

  final String artistId;

  @override
  ConsumerState<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends ConsumerState<ArtistDetailPage> {
  @override
  Widget build(BuildContext context) {
    final artistAsync = ref.watch(artistDetailProvider(widget.artistId));
    final albumsAsync = ref.watch(artistAlbumsProvider(widget.artistId));

    return Scaffold(
      body: artistAsync.when(
        loading: () => _buildShimmerLoading(context),
        error: (error, stack) => _buildError(context, error),
        data: (artist) {
          final api = ref.read(subsonicApiClientProvider);
          // 艺术家封面 URL
          final coverUrl = api.getCoverArtUrl(artist.coverArtId, size: 600);

          // 通过艺术家名称获取热门歌曲
          final topSongsAsync =
              ref.watch(artistTopSongsProvider(artist.name));

          return CustomScrollView(
            slivers: [
              // ── 顶部折叠头图 ──────────────────────────────────
              SliverAppBar.large(
                pinned: true,
                expandedHeight: 320,
                title: Text(artist.name),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(
                        url: coverUrl,
                        borderRadius: 0,
                        heroTag: 'artist-cover-${widget.artistId}',
                      ),
                      // 底部渐变遮罩
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 艺术家简介行 ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '${artist.albumCount} 张专辑',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),

              // ── 热门歌曲标题 ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    '热门歌曲',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              // ── 热门歌曲列表（最多 10 首）──────────────────────
              topSongsAsync.when(
                loading: () => _buildSongListShimmer(context),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '无法加载热门歌曲',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                data: (songs) {
                  if (songs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '暂无热门歌曲',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    );
                  }

                  return SliverList.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      final songCoverUrl =
                          api.getCoverArtUrl(song.coverArtId);

                      return SongListTile(
                        song: song,
                        coverArtUrl: songCoverUrl,
                        onTap: () => _playTopSongs(songs, index),
                      );
                    },
                  );
                },
              ),

              // ── 专辑标题 ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    '专辑',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              // ── 专辑网格（2 列）──────────────────────────────
              albumsAsync.when(
                loading: () => _buildAlbumGridShimmer(context),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '无法加载专辑',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                data: (albums) {
                  if (albums.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '暂无专辑',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        final albumCoverUrl =
                            api.getCoverArtUrl(album.coverArtId);

                        return AlbumGridTile(
                          album: album,
                          coverArtUrl: albumCoverUrl,
                          heroTag: 'album-cover-${album.id}',
                          onTap: () => context.push(
                            '/library/album/${album.id}',
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // 底部留白（给迷你播放器让位）
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── 播放热门歌曲，从指定位置开始 ──────────────────────────
  void _playTopSongs(List<Song> songs, int index) {
    final api = ref.read(subsonicApiClientProvider);
    final audioHandler = ref.read(audioHandlerProvider);

    final items = songs.map((song) {
      final streamUrl = api.getStreamUrl(song.id);
      final artUrl = api.getCoverArtUrl(song.coverArtId);
      return song.toMediaItem(streamUrl, artUrl);
    }).toList();

    audioHandler.loadAndPlay(items, initialIndex: index);
  }

  // ── 加载态 — 整页 shimmer ─────────────────────────────────
  Widget _buildShimmerLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            expandedHeight: 320,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: colorScheme.surfaceContainerHighest),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 140,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildSongListShimmer(context),
        ],
      ),
    );
  }

  // ── 歌曲列表 shimmer ──────────────────────────────────────
  SliverList _buildSongListShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverList.builder(
      itemCount: 5,
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
    );
  }

  // ── 专辑网格 shimmer ──────────────────────────────────────
  SliverPadding _buildAlbumGridShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 4,
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

  // ── 错误态 ────────────────────────────────────────────────
  Widget _buildError(BuildContext context, Object error) {
    return Center(
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
            onPressed: () {
              ref.invalidate(artistDetailProvider(widget.artistId));
              ref.invalidate(artistAlbumsProvider(widget.artistId));
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
