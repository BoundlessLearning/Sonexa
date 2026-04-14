import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ohmymusic/core/audio/media_item_converter.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';
import 'package:ohmymusic/features/library/presentation/widgets/song_list_tile.dart';
import 'package:ohmymusic/features/player/presentation/providers/favorites_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

class FilteredSongListPage extends ConsumerWidget {
  FilteredSongListPage.album({
    super.key,
    required this.title,
    required String albumId,
  })  : songsProvider = albumSongsProvider(albumId),
        onRetry = _retryAlbum(albumId);

  FilteredSongListPage.artist({
    super.key,
    required this.title,
    required String artistId,
    required String artistName,
  })  : songsProvider = artistSongsProvider(
          ArtistSongsRequest(
            artistId: artistId,
            artistName: artistName,
          ),
        ),
        onRetry = _retryArtist(
          artistId: artistId,
          artistName: artistName,
        );

  final String title;
  final ProviderListenable<AsyncValue<List<Song>>> songsProvider;
  final void Function(WidgetRef ref) onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);
    final favorites = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: songsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          error: error,
          onRetry: () => onRetry(ref),
        ),
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(child: Text('暂无歌曲'));
          }

          final api = ref.read(subsonicApiClientProvider).valueOrNull;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongListTile(
                song: song,
                coverArtUrl: api?.getCoverArtUrl(song.coverArtId, size: 300),
                isFavorite: favorites.contains(song.id),
                onFavoriteToggle: () => ref
                    .read(favoritesNotifierProvider.notifier)
                    .toggleFavorite(song.id),
                onTap: () => _playSongs(ref, songs, index),
              );
            },
          );
        },
      ),
    );
  }

  void _playSongs(WidgetRef ref, List<Song> songs, int index) {
    final api = ref.read(subsonicApiClientProvider).valueOrNull;
    if (api == null) {
      return;
    }

    final audioHandler = ref.read(audioHandlerProvider);
    final items = songs
        .map(
          (song) => song.toMediaItem(
            api.getStreamUrl(song.id, format: song.preferredPlaybackFormat),
            api.getCoverArtUrl(song.coverArtId, size: 300),
          ),
        )
        .toList();
    audioHandler.loadAndPlay(items, initialIndex: index);
  }
}

void Function(WidgetRef ref) _retryAlbum(String albumId) {
  return (ref) => ref.invalidate(albumSongsProvider(albumId));
}

void Function(WidgetRef ref) _retryArtist({
  required String artistId,
  required String artistName,
}) {
  final request = ArtistSongsRequest(
    artistId: artistId,
    artistName: artistName,
  );
  return (ref) => ref.invalidate(artistSongsProvider(request));
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              '歌曲加载失败',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
