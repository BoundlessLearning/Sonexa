import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ohmymusic/core/network/dio_client.dart';
import 'package:ohmymusic/core/network/subsonic_api_client.dart';
import 'package:ohmymusic/features/auth/presentation/providers/auth_provider.dart';
import 'package:ohmymusic/features/library/data/models/subsonic_response_models.dart';
import 'package:ohmymusic/features/library/data/repositories/library_repository.dart';
import 'package:ohmymusic/features/library/domain/entities/album.dart';
import 'package:ohmymusic/features/library/domain/entities/artist.dart';
import 'package:ohmymusic/features/library/domain/entities/playlist.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';

/// SubsonicApiClient 依赖活跃服务器配置。
/// 在 activeServerProvider 处于 AsyncLoading 期间（如登录后 invalidate 重新加载），
/// 返回上一次成功创建的 client 实例，避免下游 provider 因 StateError 导致加载失败。
final subsonicApiClientProvider = Provider<SubsonicApiClient>((ref) {
  final serverAsync = ref.watch(activeServerProvider);

  return serverAsync.when(
    data: (server) {
      if (server == null) {
        throw StateError('No active server configured');
      }
      final Dio dio = createDioClient();
      final client = SubsonicApiClient(
        dio,
        baseUrl: server.baseUrl,
        username: server.username,
        password: server.password,
      );
      // 缓存最近一次成功创建的 client，供 loading 态使用
      _lastKnownClient = client;
      return client;
    },
    loading: () {
      // 正在重新加载（如登录/注销后 invalidate），使用上次缓存的 client
      if (_lastKnownClient != null) return _lastKnownClient!;
      throw StateError('Server configuration is loading');
    },
    error: (e, _) {
      throw StateError('Failed to load server configuration: $e');
    },
  );
});

/// 上一次成功创建的 SubsonicApiClient 缓存
SubsonicApiClient? _lastKnownClient;

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.read(subsonicApiClientProvider));
});

final albumListProvider = FutureProvider<List<Album>>((ref) async {
  return ref
      .read(libraryRepositoryProvider)
      .getAlbumList(type: 'newest', size: 50);
});

final artistListProvider = FutureProvider<List<Artist>>((ref) async {
  return ref.read(libraryRepositoryProvider).getArtists();
});

final randomSongsProvider = FutureProvider<List<Song>>((ref) async {
  return ref.read(libraryRepositoryProvider).getRandomSongs(size: 50);
});

/// 分页加载专辑列表的状态管理
class PaginatedAlbumsNotifier extends StateNotifier<AsyncValue<List<Album>>> {
  PaginatedAlbumsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadMore();
  }

  final Ref _ref;
  static const _pageSize = 30;

  int _offset = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  bool get hasMore => _hasMore;

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    try {
      final repo = _ref.read(libraryRepositoryProvider);
      final newAlbums = await repo.getAlbumList(
        type: 'alphabeticalByName',
        size: _pageSize,
        offset: _offset,
      );

      final currentAlbums = state.valueOrNull ?? [];
      state = AsyncValue.data([...currentAlbums, ...newAlbums]);

      _offset += newAlbums.length;
      _hasMore = newAlbums.length >= _pageSize;
    } catch (e, st) {
      if (state.valueOrNull == null) {
        state = AsyncValue.error(e, st);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    _offset = 0;
    _hasMore = true;
    _isLoading = false;
    state = const AsyncValue.loading();
    await loadMore();
  }
}

final paginatedAlbumsProvider =
    StateNotifierProvider<PaginatedAlbumsNotifier, AsyncValue<List<Album>>>(
  (ref) => PaginatedAlbumsNotifier(ref),
);

/// 分页加载歌曲列表的状态管理
class PaginatedSongsNotifier extends StateNotifier<AsyncValue<List<Song>>> {
  PaginatedSongsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadMore();
  }

  final Ref _ref;
  static const _pageSize = 50;

  int _offset = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  bool get hasMore => _hasMore;

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    try {
      final api = _ref.read(subsonicApiClientProvider);
      final response = await api.search3(
        query: '',
        songCount: _pageSize,
        songOffset: _offset,
        albumCount: 0,
        artistCount: 0,
      );
      final body = response.subsonicResponseBody;
      final searchResult = body?['searchResult3'] as Map<String, dynamic>?;
      final songs = (searchResult?['song'] as List<dynamic>? ?? [])
          .map((song) => _parsePaginatedSong(song as Map<String, dynamic>))
          .toList();

      final currentSongs = state.valueOrNull ?? [];
      final mergedSongs = [...currentSongs, ...songs];
      final uniqueSongs = <Song>[];
      final seenIds = <String>{};
      for (final song in mergedSongs) {
        if (seenIds.add(song.id)) {
          uniqueSongs.add(song);
        }
      }

      state = AsyncValue.data(uniqueSongs);
      _offset += songs.length;
      _hasMore = songs.length >= _pageSize;
    } catch (e, st) {
      if (state.valueOrNull == null) {
        state = AsyncValue.error(e, st);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    _offset = 0;
    _hasMore = true;
    _isLoading = false;
    state = const AsyncValue.loading();
    await loadMore();
  }
}

final paginatedSongsProvider =
    StateNotifierProvider<PaginatedSongsNotifier, AsyncValue<List<Song>>>(
  (ref) => PaginatedSongsNotifier(ref),
);

Song _parsePaginatedSong(Map<String, dynamic> json) => Song(
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
      starred: json['starred'] != null
          ? DateTime.tryParse(json['starred'] as String)
          : null,
      lastPlayed: json['played'] != null
          ? DateTime.tryParse(json['played'] as String)
          : null,
    );

// ─── 专辑详情 & 歌曲列表 ───────────────────────────────────

final albumDetailProvider =
    FutureProvider.family<Album, String>((ref, id) async {
  return ref.read(libraryRepositoryProvider).getAlbumDetail(id);
});

final albumSongsProvider =
    FutureProvider.family<List<Song>, String>((ref, albumId) async {
  return ref.read(libraryRepositoryProvider).getAlbumSongs(albumId);
});

// ─── 艺术家详情 ─────────────────────────────────────────────

final artistDetailProvider =
    FutureProvider.family<Artist, String>((ref, id) async {
  final api = ref.read(subsonicApiClientProvider);
  final response = await api.getArtist(id);
  final body = response.subsonicResponseBody;
  final artistData = body?['artist'] as Map<String, dynamic>?;
  if (artistData == null) throw StateError('Artist not found: $id');
  return Artist(
    id: artistData['id'] as String,
    name: artistData['name'] as String? ?? 'Unknown',
    coverArtId: artistData['coverArt'] as String? ??
        artistData['artistImageUrl'] as String?,
    albumCount: artistData['albumCount'] as int? ?? 0,
  );
});

final artistAlbumsProvider =
    FutureProvider.family<List<Album>, String>((ref, artistId) async {
  final api = ref.read(subsonicApiClientProvider);
  final response = await api.getArtist(artistId);
  final body = response.subsonicResponseBody;
  final artistData = body?['artist'] as Map<String, dynamic>?;
  if (artistData == null) return [];
  final albums = artistData['album'] as List<dynamic>? ?? [];
  return albums.map((a) {
    final map = a as Map<String, dynamic>;
    return Album(
      id: map['id'] as String,
      name: map['name'] as String? ?? map['title'] as String? ?? '',
      artist: map['artist'] as String? ?? 'Unknown',
      artistId: map['artistId'] as String? ?? artistId,
      coverArtId: map['coverArt'] as String?,
      songCount: map['songCount'] as int? ?? 0,
      duration: map['duration'] as int? ?? 0,
      year: map['year'] as int?,
      genre: map['genre'] as String?,
    );
  }).toList();
});

// ─── 播放列表详情 ──────────────────────────────────────────

final playlistDetailProvider =
    FutureProvider.family<Playlist, String>((ref, id) async {
  final api = ref.read(subsonicApiClientProvider);
  final response = await api.getPlaylist(id);
  final body = response.subsonicResponseBody;
  final playlistData = body?['playlist'] as Map<String, dynamic>?;
  if (playlistData == null) throw StateError('Playlist not found: $id');

  final songs = (playlistData['entry'] as List<dynamic>? ?? []).map((s) {
    final map = s as Map<String, dynamic>;
    return Song(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      artist: map['artist'] as String? ?? 'Unknown',
      artistId: map['artistId'] as String? ?? '',
      album: map['album'] as String? ?? '',
      albumId: map['albumId'] as String? ?? '',
      coverArtId: map['coverArt'] as String?,
      duration: map['duration'] as int? ?? 0,
      track: map['track'] as int?,
      year: map['year'] as int?,
      genre: map['genre'] as String?,
      bitRate: map['bitRate'] as int?,
      playCount: map['playCount'] as int? ?? 0,
    );
  }).toList();

  return Playlist(
    id: playlistData['id'] as String,
    name: playlistData['name'] as String? ?? '',
    comment: playlistData['comment'] as String?,
    isPublic: playlistData['public'] as bool? ?? false,
    songCount: playlistData['songCount'] as int? ?? songs.length,
    duration: playlistData['duration'] as int? ?? 0,
    coverArtId: playlistData['coverArt'] as String?,
    owner: playlistData['owner'] as String? ?? '',
    created: playlistData['created'] != null
        ? DateTime.tryParse(playlistData['created'] as String)
        : null,
    songs: songs,
  );
});

final artistTopSongsProvider =
    FutureProvider.family<List<Song>, String>((ref, artistName) async {
  final api = ref.read(subsonicApiClientProvider);
  final response = await api.getTopSongs(artistName, count: 10);
  final body = response.subsonicResponseBody;
  final topSongs = body?['topSongs'];
  final songs = topSongs?['song'] as List<dynamic>? ?? [];
  return songs.map((s) {
    final map = s as Map<String, dynamic>;
    return Song(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      artist: map['artist'] as String? ?? 'Unknown',
      artistId: map['artistId'] as String? ?? '',
      album: map['album'] as String? ?? '',
      albumId: map['albumId'] as String? ?? '',
      coverArtId: map['coverArt'] as String?,
      duration: map['duration'] as int? ?? 0,
      track: map['track'] as int?,
      year: map['year'] as int?,
      genre: map['genre'] as String?,
      bitRate: map['bitRate'] as int?,
      playCount: map['playCount'] as int? ?? 0,
    );
  }).toList();
});
