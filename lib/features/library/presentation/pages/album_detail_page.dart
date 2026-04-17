import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:sonexa/core/audio/media_item_converter.dart';
import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/core/utils/formatters.dart';
import 'package:sonexa/core/widgets/app_image.dart';
import 'package:sonexa/features/library/domain/entities/song.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';
import 'package:sonexa/features/library/presentation/widgets/song_list_tile.dart';
import 'package:sonexa/features/player/presentation/providers/favorites_provider.dart';
import 'package:sonexa/features/player/presentation/providers/player_provider.dart';

final _albumDiag = DiagnosticLogger.instance.module('library');

/// 专辑详情页 — 展示专辑封面、元数据、歌曲列表
class AlbumDetailPage extends ConsumerStatefulWidget {
  const AlbumDetailPage({super.key, required this.albumId});

  final String albumId;

  @override
  ConsumerState<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends ConsumerState<AlbumDetailPage> {
  @override
  Widget build(BuildContext context) {
    final albumAsync = ref.watch(albumDetailProvider(widget.albumId));
    final songsAsync = ref.watch(albumSongsProvider(widget.albumId));
    final favorites = ref.watch(favoritesNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: albumAsync.when(
        loading: () => _buildShimmerLoading(context),
        error: (error, stack) => _buildError(context, error),
        data: (album) {
          final api = ref.read(subsonicApiClientProvider).requireValue;
          // 专辑封面 URL（高分辨率）
          final coverUrl = api.getCoverArtUrl(album.coverArtId, size: 600);

          return CustomScrollView(
            slivers: [
              // ── 顶部折叠头图 ──────────────────────────────────
              SliverAppBar.large(
                pinned: true,
                expandedHeight: 320,
                title: Text(album.name),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(
                        url: coverUrl,
                        borderRadius: 0,
                        heroTag: 'album-cover-${widget.albumId}',
                      ),
                      // 底部渐变遮罩，保证文字可读
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 专辑信息行 ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 艺术家名（可点击跳转）
                      GestureDetector(
                        onTap:
                            () => context.push(
                              '/library/artist/${album.artistId}',
                            ),
                        child: Text(
                          album.artist,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 年份 · 歌曲数 · 总时长
                      Text(
                        [
                          if (album.year != null) '${album.year}',
                          l10n.songCount(album.songCount),
                          formatDuration(album.duration),
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 播放全部按钮 ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: songsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data:
                        (songs) => FilledButton.icon(
                          onPressed:
                              songs.isEmpty ? null : () => _playAll(songs),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(l10n.playAll),
                        ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── 歌曲列表 ──────────────────────────────────
              songsAsync.when(
                loading: () => _buildSongListShimmer(context),
                error:
                    (error, stack) =>
                        SliverToBoxAdapter(child: _buildError(context, error)),
                data: (songs) {
                  if (songs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(l10n.noSongs),
                        ),
                      ),
                    );
                  }

                  return SliverList.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      final songCoverUrl = api.getCoverArtUrl(song.coverArtId);

                      return SongListTile(
                        song: song,
                        coverArtUrl: songCoverUrl,
                        isFavorite: favorites.contains(song.id),
                        onFavoriteToggle:
                            () => ref
                                .read(favoritesNotifierProvider.notifier)
                                .toggleFavorite(song.id),
                        onTap: () => _playFromIndex(songs, index),
                      );
                    },
                  );
                },
              ),

              // 底部留白（给迷你播放器让位）
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  // ── 播放全部歌曲 ──────────────────────────────────────────
  void _playAll(List<Song> songs) {
    _playFromIndex(songs, 0);
  }

  // ── 从指定位置开始播放 ────────────────────────────────────
  void _playFromIndex(List<Song> songs, int index) {
    final api = ref.read(subsonicApiClientProvider).requireValue;
    final audioHandler = ref.read(audioHandlerProvider);
    _albumDiag.event(
      'album_detail_play',
      fields: {
        'albumId': widget.albumId,
        'startIndex': index,
        'totalSongs': songs.length,
      },
    );

    final items =
        songs.map((song) {
          final streamUrl = api.getStreamUrl(
            song.id,
            format: song.preferredPlaybackFormat,
          );
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
                    width: 200,
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
      itemCount: 8,
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
            AppLocalizations.of(context).failedToLoad,
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
              ref.invalidate(albumDetailProvider(widget.albumId));
              ref.invalidate(albumSongsProvider(widget.albumId));
            },
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    );
  }
}
