import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:ohmymusic/core/audio/media_item_converter.dart';
import 'package:ohmymusic/core/database/app_database.dart';
import 'package:ohmymusic/core/widgets/app_image.dart';
import 'package:ohmymusic/features/home/presentation/providers/home_provider.dart';
import 'package:ohmymusic/features/library/domain/entities/album.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';
import 'package:ohmymusic/features/player/presentation/providers/play_history_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: () => _refreshAll(ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshAll(ref),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 随机推荐 ─────────────────────────────────
              _SectionHeader(
                title: '随机推荐',
                onSeeMore: () => context.push('/random-songs'),
              ),
              _RandomSongsSection(ref: ref),

              const SizedBox(height: 24),

              // ─── 我的收藏 ─────────────────────────────────
              _SectionHeader(
                title: '我的收藏',
                onSeeMore: () => context.push('/starred-songs'),
              ),
              _SongSection(
                provider: starredSongsProvider,
                ref: ref,
                emptyMessage: '暂无收藏歌曲',
              ),

              const SizedBox(height: 24),

              // ─── 最新专辑 ─────────────────────────────────
              _SectionHeader(
                title: '最新专辑',
                onSeeMore: () => StatefulNavigationShell.of(context).goBranch(1),
              ),
              _AlbumSection(
                provider: newestAlbumsProvider,
                ref: ref,
              ),

              const SizedBox(height: 24),

              // ─── 最近播放 ─────────────────────────────────
              _SectionHeader(
                title: '最近播放',
                onSeeMore: () => context.push('/history'),
              ),
              const _RecentPlaySection(),

              if (currentSong != null) ...[
                const SizedBox(height: 24),

                // ─── 猜你喜欢 ───────────────────────────────
                _SectionHeader(
                  title: '猜你喜欢',
                  onSeeMore: () => context.push('/similar-songs'),
                ),
                _SongSection(
                  provider: similarSongsProvider,
                  ref: ref,
                  emptyMessage: '暂无相似推荐',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _refreshAll(WidgetRef ref) {
    ref.invalidate(homeRandomSongsProvider);
    ref.invalidate(starredSongsProvider);
    ref.invalidate(similarSongsProvider);
    ref.invalidate(newestAlbumsProvider);
    ref.read(playHistoryNotifierProvider.notifier).refresh();
  }
}

// ─── Section Header ──────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onSeeMore,
  });

  final String title;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onSeeMore,
            child: const Text('查看更多'),
          ),
        ],
      ),
    );
  }
}

// ─── Random Songs Section ────────────────────────────────────

class _RandomSongsSection extends StatelessWidget {
  const _RandomSongsSection({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(homeRandomSongsProvider);

    return songsAsync.when(
      loading: () => _buildHorizontalShimmer(context, cardWidth: 130, cardHeight: 120),
      error: (error, stack) => _SectionError(
        error: error,
        onRetry: () => ref.invalidate(homeRandomSongsProvider),
      ),
      data: (songs) {
        if (songs.isEmpty) {
          return const _SectionEmpty(message: '暂无推荐');
        }
        return SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: songs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final song = songs[index];
              final api = ref.read(subsonicApiClientProvider);
              final coverUrl = api.getCoverArtUrl(song.coverArtId, size: 300);

              return _SongCard(
                song: song,
                coverUrl: coverUrl,
                onTap: () => _playSongs(ref, songs, index),
              );
            },
          ),
        );
      },
    );
  }

  void _playSongs(WidgetRef ref, List<Song> songs, int index) {
    final api = ref.read(subsonicApiClientProvider);
    final audioHandler = ref.read(audioHandlerProvider);
    final items = songs
        .map((s) => s.toMediaItem(
              api.getStreamUrl(s.id),
              api.getCoverArtUrl(s.coverArtId, size: 300),
            ))
        .toList();
    audioHandler.loadAndPlay(items, initialIndex: index);
  }
}

class _SongSection extends StatelessWidget {
  const _SongSection({
    required this.provider,
    required this.ref,
    required this.emptyMessage,
  });

  final FutureProvider<List<Song>> provider;
  final WidgetRef ref;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(provider);

    return songsAsync.when(
      loading: () =>
          _buildHorizontalShimmer(context, cardWidth: 130, cardHeight: 120),
      error: (error, stack) => _SectionError(
        error: error,
        onRetry: () => ref.invalidate(provider),
      ),
      data: (songs) {
        final visibleSongs = songs.take(20).toList();
        if (visibleSongs.isEmpty) {
          return _SectionEmpty(message: emptyMessage);
        }
        return SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: visibleSongs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final song = visibleSongs[index];
              final api = ref.read(subsonicApiClientProvider);
              final coverUrl = api.getCoverArtUrl(song.coverArtId, size: 300);

              return _SongCard(
                song: song,
                coverUrl: coverUrl,
                onTap: () => _playSongs(ref, visibleSongs, index),
              );
            },
          ),
        );
      },
    );
  }

  void _playSongs(WidgetRef ref, List<Song> songs, int index) {
    final api = ref.read(subsonicApiClientProvider);
    final audioHandler = ref.read(audioHandlerProvider);
    final items = songs
        .map((s) => s.toMediaItem(
              api.getStreamUrl(s.id),
              api.getCoverArtUrl(s.coverArtId, size: 300),
            ))
        .toList();
    audioHandler.loadAndPlay(items, initialIndex: index);
  }
}

// ─── Song Card ───────────────────────────────────────────────

class _SongCard extends StatelessWidget {
  const _SongCard({
    required this.song,
    required this.coverUrl,
    required this.onTap,
  });

  final Song song;
  final String coverUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImage(
              url: coverUrl,
              size: 120,
              borderRadius: 12,
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Play Section (本地播放历史) ──────────────────────

class _RecentPlaySection extends ConsumerWidget {
  const _RecentPlaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(playHistoryNotifierProvider);

    return historyAsync.when(
      loading: () =>
          _buildHorizontalShimmer(context, cardWidth: 130, cardHeight: 120),
      error: (error, _) => _SectionError(
        error: error,
        onRetry: () =>
            ref.read(playHistoryNotifierProvider.notifier).refresh(),
      ),
      data: (history) {
        if (history.isEmpty) {
          return const _SectionEmpty(message: '暂无播放记录');
        }
        // 去重：只取每首歌最近一次播放，最多显示 20 首
        final seen = <String>{};
        final uniqueHistory = <PlayHistoryData>[];
        for (final item in history) {
          if (seen.add(item.songId)) {
            uniqueHistory.add(item);
            if (uniqueHistory.length >= 20) break;
          }
        }
        return SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: uniqueHistory.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = uniqueHistory[index];
              // 使用封面 API — albumId 可用于 coverArt
              final api = ref.read(subsonicApiClientProvider);
              final coverUrl = api.getCoverArtUrl(
                item.albumId.isNotEmpty ? item.albumId : item.songId,
                size: 300,
              );
              return _RecentPlayCard(
                title: item.songTitle,
                artist: item.artist,
                coverUrl: coverUrl,
                onTap: () {
                  // 将这首歌作为单曲播放
                  final song = Song(
                    id: item.songId,
                    title: item.songTitle,
                    artist: item.artist,
                    artistId: '',
                    album: '',
                    albumId: item.albumId,
                    duration: 0,
                  );
                  final mediaItem = song.toMediaItem(
                    api.getStreamUrl(item.songId),
                    coverUrl,
                  );
                  ref.read(audioHandlerProvider).loadAndPlay([mediaItem]);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _RecentPlayCard extends StatelessWidget {
  const _RecentPlayCard({
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.onTap,
  });

  final String title;
  final String artist;
  final String coverUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImage(
              url: coverUrl,
              size: 120,
              borderRadius: 12,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Album Section ───────────────────────────────────────────

class _AlbumSection extends StatelessWidget {
  const _AlbumSection({
    required this.provider,
    required this.ref,
  });

  final FutureProvider<List<Album>> provider;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(provider);

    return albumsAsync.when(
      loading: () => _buildHorizontalShimmer(context, cardWidth: 150, cardHeight: 140),
      error: (error, stack) => _SectionError(
        error: error,
        onRetry: () => ref.invalidate(provider),
      ),
      data: (albums) {
        if (albums.isEmpty) {
          return const _SectionEmpty(message: '暂无专辑');
        }
        return SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: albums.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final album = albums[index];
              final api = ref.read(subsonicApiClientProvider);
              final coverUrl = api.getCoverArtUrl(album.coverArtId, size: 300);

              return _AlbumCard(
                album: album,
                coverUrl: coverUrl,
                onTap: () => context.push('/library/album/${album.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Album Card ──────────────────────────────────────────────

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.album,
    required this.coverUrl,
    required this.onTap,
  });

  final Album album;
  final String coverUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImage(
              url: coverUrl,
              size: 140,
              borderRadius: 12,
            ),
            const SizedBox(height: 8),
            Text(
              album.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              album.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared: Horizontal Shimmer Placeholder ──────────────────

Widget _buildHorizontalShimmer(
  BuildContext context, {
  required double cardWidth,
  required double cardHeight,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Shimmer.fromColors(
    baseColor: colorScheme.surfaceContainerHighest,
    highlightColor: colorScheme.surface,
    child: SizedBox(
      height: cardHeight + 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: cardWidth * 0.8,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  width: cardWidth * 0.5,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

// ─── Shared: Section Error ───────────────────────────────────

class _SectionError extends StatelessWidget {
  const _SectionError({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '加载失败',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

// ─── Shared: Section Empty ───────────────────────────────────

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
