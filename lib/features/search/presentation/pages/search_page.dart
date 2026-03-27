import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ohmymusic/core/audio/media_item_converter.dart';
import 'package:ohmymusic/features/library/data/repositories/library_repository.dart';
import 'package:ohmymusic/features/library/domain/entities/album.dart';
import 'package:ohmymusic/features/library/domain/entities/artist.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';
import 'package:ohmymusic/features/library/presentation/widgets/album_grid_tile.dart';
import 'package:ohmymusic/features/library/presentation/widgets/song_list_tile.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';
import 'package:ohmymusic/features/search/presentation/providers/search_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final searchAsync = ref.watch(searchResultProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: '搜索歌曲、专辑、艺术家...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: query.trim().isEmpty
          ? _buildEmptyHint(context)
          : searchAsync.when(
              data: (result) {
                if (result == null) return _buildEmptyHint(context);
                return _buildResults(context, result);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  '搜索出错: $error',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyHint(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '输入关键词搜索音乐',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
      BuildContext context, SearchResult result) {
    final songs = result.songs;
    final albums = result.albums;
    final artists = result.artists;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: '歌曲 (${songs.length})'),
              Tab(text: '专辑 (${albums.length})'),
              Tab(text: '艺术家 (${artists.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSongsTab(songs),
                _buildAlbumsTab(albums),
                _buildArtistsTab(artists),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsTab(List<Song> songs) {
    if (songs.isEmpty) return _buildNoResults();
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final api = ref.read(subsonicApiClientProvider).requireValue;
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
    );
  }

  Widget _buildAlbumsTab(List<Album> albums) {
    if (albums.isEmpty) return _buildNoResults();
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        final api = ref.read(subsonicApiClientProvider).requireValue;
        return AlbumGridTile(
          album: album,
          coverArtUrl: api.getCoverArtUrl(album.coverArtId),
          onTap: () => context.push('/library/album/${album.id}'),
        );
      },
    );
  }

  Widget _buildArtistsTab(List<Artist> artists) {
    if (artists.isEmpty) return _buildNoResults();
    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              artist.name.isNotEmpty ? artist.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          title: Text(
            artist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${artist.albumCount} 张专辑',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          onTap: () => context.push('/library/artist/${artist.id}'),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Text(
        '未找到相关结果',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
