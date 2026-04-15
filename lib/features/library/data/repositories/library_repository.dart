import 'package:sonexa/core/cache/timed_memory_cache.dart';
import 'package:sonexa/core/network/subsonic_api_client.dart';
import 'package:sonexa/features/library/data/mappers/subsonic_mappers.dart';
import 'package:sonexa/features/library/data/models/subsonic_response_models.dart';
import 'package:sonexa/features/library/domain/entities/album.dart';
import 'package:sonexa/features/library/domain/entities/artist.dart';
import 'package:sonexa/features/library/domain/entities/playlist.dart';
import 'package:sonexa/features/library/domain/entities/song.dart';

class SearchResult {
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;

  const SearchResult({
    required this.songs,
    required this.albums,
    required this.artists,
  });
}

class LibraryRepository {
  LibraryRepository(this._api, {TimedMemoryCache? cache})
    : _cache = cache ?? TimedMemoryCache(ttl: const Duration(minutes: 2));

  final SubsonicApiClient _api;
  final TimedMemoryCache _cache;

  void clearCache() {
    _cache.clear();
  }

  Future<List<Artist>> getArtists() async {
    final response = await _api.getArtists();
    final body = response.subsonicResponseBody;
    final artistsData = body?['artists'];
    if (artistsData == null) return [];

    final indices = artistsData['index'] as List<dynamic>? ?? [];
    final results = <Artist>[];

    for (final index in indices) {
      final artists =
          (index as Map<String, dynamic>)['artist'] as List<dynamic>? ?? [];
      for (final a in artists) {
        results.add(SubsonicMappers.artist(a as Map<String, dynamic>));
      }
    }

    return results;
  }

  Future<List<Album>> getAlbumList({
    required String type,
    int size = 20,
    int offset = 0,
  }) async {
    final response = await _api.getAlbumList2(
      type: type,
      size: size,
      offset: offset,
    );
    final body = response.subsonicResponseBody;
    final albumList = body?['albumList2'];
    final albums = albumList?['album'] as List<dynamic>? ?? [];

    return albums
        .map((a) => SubsonicMappers.album(a as Map<String, dynamic>))
        .toList();
  }

  Future<Album> getAlbumDetail(String id, {bool forceRefresh = false}) {
    return _cache.getOrLoad(
      'album-detail:$id',
      () => _fetchAlbumDetail(id),
      forceRefresh: forceRefresh,
    );
  }

  Future<Album> _fetchAlbumDetail(String id) async {
    final response = await _api.getAlbum(id);
    final body = response.subsonicResponseBody;
    final albumData = body?['album'] as Map<String, dynamic>?;
    if (albumData == null) {
      throw StateError('Album not found: $id');
    }

    return SubsonicMappers.album(albumData);
  }

  Future<List<Song>> getAlbumSongs(
    String albumId, {
    bool forceRefresh = false,
  }) {
    return _cache.getOrLoad(
      'album-songs:$albumId',
      () => _fetchAlbumSongs(albumId),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Song>> _fetchAlbumSongs(String albumId) async {
    final response = await _api.getAlbum(albumId);
    final body = response.subsonicResponseBody;
    final albumData = body?['album'] as Map<String, dynamic>?;
    if (albumData == null) return [];

    final songs = albumData['song'] as List<dynamic>? ?? [];
    return songs
        .map((s) => SubsonicMappers.song(s as Map<String, dynamic>))
        .toList();
  }

  Future<List<Song>> getRandomSongs({int size = 20}) async {
    final response = await _api.getRandomSongs(size: size);
    final body = response.subsonicResponseBody;
    final randomSongs = body?['randomSongs'];
    final songs = randomSongs?['song'] as List<dynamic>? ?? [];

    return songs
        .map((s) => SubsonicMappers.song(s as Map<String, dynamic>))
        .toList();
  }

  Future<List<Song>> getSongsPage({int size = 50, int offset = 0}) async {
    final response = await _api.search3(
      query: '',
      songCount: size,
      songOffset: offset,
      albumCount: 0,
      artistCount: 0,
    );
    final body = response.subsonicResponseBody;
    final searchResult = body?['searchResult3'] as Map<String, dynamic>?;
    final songs = searchResult?['song'] as List<dynamic>? ?? [];

    return songs
        .map((song) => SubsonicMappers.song(song as Map<String, dynamic>))
        .toList();
  }

  Future<SearchResult> search(String query) async {
    final response = await _api.search3(query: query);
    final body = response.subsonicResponseBody;
    final searchResult = body?['searchResult3'];

    final songs =
        (searchResult?['song'] as List<dynamic>? ?? [])
            .map((s) => SubsonicMappers.song(s as Map<String, dynamic>))
            .toList();
    final albums =
        (searchResult?['album'] as List<dynamic>? ?? [])
            .map((a) => SubsonicMappers.album(a as Map<String, dynamic>))
            .toList();
    final artists =
        (searchResult?['artist'] as List<dynamic>? ?? [])
            .map((a) => SubsonicMappers.artist(a as Map<String, dynamic>))
            .toList();

    return SearchResult(songs: songs, albums: albums, artists: artists);
  }

  Future<Artist> getArtistDetail(String id, {bool forceRefresh = false}) {
    return _cache.getOrLoad(
      'artist-detail:$id',
      () => _fetchArtistDetail(id),
      forceRefresh: forceRefresh,
    );
  }

  Future<Artist> _fetchArtistDetail(String id) async {
    final response = await _api.getArtist(id);
    final body = response.subsonicResponseBody;
    final artistData = body?['artist'] as Map<String, dynamic>?;
    if (artistData == null) {
      throw StateError('Artist not found: $id');
    }

    return SubsonicMappers.artist(artistData);
  }

  Future<List<Album>> getArtistAlbums(
    String artistId, {
    bool forceRefresh = false,
  }) {
    return _cache.getOrLoad(
      'artist-albums:$artistId',
      () => _fetchArtistAlbums(artistId),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Album>> _fetchArtistAlbums(String artistId) async {
    final response = await _api.getArtist(artistId);
    final body = response.subsonicResponseBody;
    final artistData = body?['artist'] as Map<String, dynamic>?;
    if (artistData == null) return [];

    final albums = artistData['album'] as List<dynamic>? ?? [];
    return albums
        .map(
          (album) => SubsonicMappers.album(
            album as Map<String, dynamic>,
            fallbackArtistId: artistId,
          ),
        )
        .toList();
  }

  Future<List<Song>> getArtistSongs({
    required String artistId,
    required String artistName,
  }) async {
    final normalizedArtistId = artistId.trim();
    final normalizedArtistName = artistName.trim();

    if (normalizedArtistId.isNotEmpty) {
      try {
        final albums = await getArtistAlbums(normalizedArtistId);
        final albumSongLists = await Future.wait(
          albums.map((album) => getAlbumSongs(album.id)),
        );
        final songs = _dedupeSongs(albumSongLists.expand((songs) => songs));
        if (songs.isNotEmpty) {
          return songs;
        }
      } catch (_) {
        // Song-level artistId can differ from getArtist IDs on some servers.
      }
    }

    if (normalizedArtistName.isEmpty) {
      return const <Song>[];
    }

    return getTopSongs(normalizedArtistName, count: 100);
  }

  Future<Playlist> getPlaylistDetail(String id, {bool forceRefresh = false}) {
    return _cache.getOrLoad(
      'playlist-detail:$id',
      () => _fetchPlaylistDetail(id),
      forceRefresh: forceRefresh,
    );
  }

  Future<Playlist> _fetchPlaylistDetail(String id) async {
    final response = await _api.getPlaylist(id);
    final body = response.subsonicResponseBody;
    final playlistData = body?['playlist'] as Map<String, dynamic>?;
    if (playlistData == null) {
      throw StateError('Playlist not found: $id');
    }

    return SubsonicMappers.playlist(playlistData);
  }

  Future<List<Song>> getTopSongs(
    String artistName, {
    int count = 10,
    bool forceRefresh = false,
  }) {
    final normalizedArtistName = artistName.trim();
    if (normalizedArtistName.isEmpty) {
      return Future.value(const <Song>[]);
    }

    return _cache.getOrLoad(
      'top-songs:$normalizedArtistName:$count',
      () => _fetchTopSongs(normalizedArtistName, count: count),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Song>> _fetchTopSongs(
    String normalizedArtistName, {
    required int count,
  }) async {
    final response = await _api.getTopSongs(normalizedArtistName, count: count);
    final body = response.subsonicResponseBody;
    final topSongs = body?['topSongs'];
    final songs = topSongs?['song'] as List<dynamic>? ?? [];

    return _dedupeSongs(
      songs.map((song) => SubsonicMappers.song(song as Map<String, dynamic>)),
    );
  }

  List<Song> _dedupeSongs(Iterable<Song> songs) {
    final result = <Song>[];
    final seenIds = <String>{};
    for (final song in songs) {
      if (seenIds.add(song.id)) {
        result.add(song);
      }
    }
    return result;
  }
}
