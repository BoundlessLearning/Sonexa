import 'package:sonexa/core/network/subsonic_api_client.dart';
import 'package:sonexa/features/library/data/models/subsonic_response_models.dart';
import 'package:sonexa/features/library/domain/entities/album.dart';
import 'package:sonexa/features/library/domain/entities/artist.dart';
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
  LibraryRepository(this._api);

  final SubsonicApiClient _api;

  Future<List<Artist>> getArtists() async {
    final response = await _api.getArtists();
    final body = response.subsonicResponseBody;
    final artistsData = body?['artists'];
    if (artistsData == null) return [];

    final indices = artistsData['index'] as List<dynamic>? ?? [];
    final results = <Artist>[];

    for (final index in indices) {
      final artists = (index as Map<String, dynamic>)['artist'] as List<dynamic>? ?? [];
      for (final a in artists) {
        results.add(_parseArtist(a as Map<String, dynamic>));
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
        .map((a) => _parseAlbum(a as Map<String, dynamic>))
        .toList();
  }

  Future<Album> getAlbumDetail(String id) async {
    final response = await _api.getAlbum(id);
    final body = response.subsonicResponseBody;
    final albumData = body?['album'] as Map<String, dynamic>?;
    if (albumData == null) {
      throw StateError('Album not found: $id');
    }

    return _parseAlbum(albumData);
  }

  Future<List<Song>> getAlbumSongs(String albumId) async {
    final response = await _api.getAlbum(albumId);
    final body = response.subsonicResponseBody;
    final albumData = body?['album'] as Map<String, dynamic>?;
    if (albumData == null) return [];

    final songs = albumData['song'] as List<dynamic>? ?? [];
    return songs
        .map((s) => _parseSong(s as Map<String, dynamic>))
        .toList();
  }

  Future<List<Song>> getRandomSongs({int size = 20}) async {
    final response = await _api.getRandomSongs(size: size);
    final body = response.subsonicResponseBody;
    final randomSongs = body?['randomSongs'];
    final songs = randomSongs?['song'] as List<dynamic>? ?? [];

    return songs
        .map((s) => _parseSong(s as Map<String, dynamic>))
        .toList();
  }

  Future<SearchResult> search(String query) async {
    final response = await _api.search3(query: query);
    final body = response.subsonicResponseBody;
    final searchResult = body?['searchResult3'];

    final songs = (searchResult?['song'] as List<dynamic>? ?? [])
        .map((s) => _parseSong(s as Map<String, dynamic>))
        .toList();
    final albums = (searchResult?['album'] as List<dynamic>? ?? [])
        .map((a) => _parseAlbum(a as Map<String, dynamic>))
        .toList();
    final artists = (searchResult?['artist'] as List<dynamic>? ?? [])
        .map((a) => _parseArtist(a as Map<String, dynamic>))
        .toList();

    return SearchResult(songs: songs, albums: albums, artists: artists);
  }

  Song _parseSong(Map<String, dynamic> json) => Song(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        artist: json['artist'] as String? ?? 'Unknown',
        artistId: json['artistId'] as String? ?? '',
        album: json['album'] as String? ?? '',
        albumId: json['albumId'] as String? ?? '',
        coverArtId: json['coverArt'] as String?,
        duration: json['duration'] as int? ?? 0,
        track: json['track'] as int?,
        discNumber: json['discNumber'] as int?,
        year: json['year'] as int?,
        genre: json['genre'] as String?,
        bitRate: json['bitRate'] as int?,
        suffix: json['suffix'] as String?,
        size: json['size'] as int?,
        playCount: json['playCount'] as int? ?? 0,
      );

  Album _parseAlbum(Map<String, dynamic> json) => Album(
        id: json['id'] as String,
        name: json['name'] as String? ?? json['title'] as String? ?? '',
        artist: json['artist'] as String? ?? 'Unknown',
        artistId: json['artistId'] as String? ?? '',
        coverArtId: json['coverArt'] as String?,
        songCount: json['songCount'] as int? ?? 0,
        duration: json['duration'] as int? ?? 0,
        year: json['year'] as int?,
        genre: json['genre'] as String?,
        playCount: json['playCount'] as int?,
        created: json['created'] != null
            ? DateTime.tryParse(json['created'] as String)
            : null,
      );

  Artist _parseArtist(Map<String, dynamic> json) => Artist(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Unknown',
        coverArtId: json['coverArt'] as String? ?? json['artistImageUrl'] as String?,
        albumCount: json['albumCount'] as int? ?? 0,
      );
}
