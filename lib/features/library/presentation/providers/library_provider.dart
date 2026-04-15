import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/network/dio_client.dart';
import 'package:sonexa/core/network/subsonic_api_client.dart';
import 'package:sonexa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sonexa/features/library/data/repositories/library_repository.dart';
import 'package:sonexa/features/library/domain/entities/album.dart';
import 'package:sonexa/features/library/domain/entities/artist.dart';
import 'package:sonexa/features/library/domain/entities/playlist.dart';
import 'package:sonexa/features/library/domain/entities/song.dart';

/// SubsonicApiClient 依赖活跃服务器配置，等待其加载完成后创建。
final subsonicApiClientProvider = FutureProvider<SubsonicApiClient>((
  ref,
) async {
  final server = await ref.watch(activeServerProvider.future);
  if (server == null) {
    throw StateError('No active server configured');
  }
  final Dio dio = createDioClient();
  return SubsonicApiClient(
    dio,
    baseUrl: server.baseUrl,
    username: server.username,
    password: server.password,
  );
});

final libraryRepositoryProvider = FutureProvider<LibraryRepository>((
  ref,
) async {
  final client = await ref.watch(subsonicApiClientProvider.future);
  return LibraryRepository(client);
});

final albumListProvider = FutureProvider<List<Album>>((ref) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getAlbumList(type: 'newest', size: 50);
});

final artistListProvider = FutureProvider<List<Artist>>((ref) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getArtists();
});

final randomSongsProvider = FutureProvider<List<Song>>((ref) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getRandomSongs(size: 50);
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
      final repo = await _ref.read(libraryRepositoryProvider.future);
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
    final repo = await _ref.read(libraryRepositoryProvider.future);
    repo.clearCache();
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
      final repo = await _ref.read(libraryRepositoryProvider.future);
      final songs = await repo.getSongsPage(size: _pageSize, offset: _offset);

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
    final repo = await _ref.read(libraryRepositoryProvider.future);
    repo.clearCache();
    await loadMore();
  }
}

final paginatedSongsProvider =
    StateNotifierProvider<PaginatedSongsNotifier, AsyncValue<List<Song>>>(
      (ref) => PaginatedSongsNotifier(ref),
    );

// ─── 专辑详情 & 歌曲列表 ───────────────────────────────────

final albumDetailProvider = FutureProvider.family<Album, String>((
  ref,
  id,
) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getAlbumDetail(id);
});

final albumSongsProvider = FutureProvider.family<List<Song>, String>((
  ref,
  albumId,
) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getAlbumSongs(albumId);
});

class ArtistSongsRequest {
  const ArtistSongsRequest({required this.artistId, required this.artistName});

  final String artistId;
  final String artistName;

  @override
  bool operator ==(Object other) {
    return other is ArtistSongsRequest &&
        other.artistId == artistId &&
        other.artistName == artistName;
  }

  @override
  int get hashCode => Object.hash(artistId, artistName);
}

final artistSongsProvider =
    FutureProvider.family<List<Song>, ArtistSongsRequest>((ref, request) async {
      final repo = await ref.watch(libraryRepositoryProvider.future);
      return repo.getArtistSongs(
        artistId: request.artistId,
        artistName: request.artistName,
      );
    });

// ─── 艺术家详情 ─────────────────────────────────────────────

final artistDetailProvider = FutureProvider.family<Artist, String>((
  ref,
  id,
) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getArtistDetail(id);
});

final artistAlbumsProvider = FutureProvider.family<List<Album>, String>((
  ref,
  artistId,
) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getArtistAlbums(artistId);
});

// ─── 播放列表详情 ──────────────────────────────────────────

final playlistDetailProvider = FutureProvider.family<Playlist, String>((
  ref,
  id,
) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getPlaylistDetail(id);
});

final artistTopSongsProvider = FutureProvider.family<List<Song>, String>((
  ref,
  artistName,
) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getTopSongs(artistName, count: 10);
});
