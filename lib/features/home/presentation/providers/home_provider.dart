import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/features/library/data/mappers/subsonic_mappers.dart';
import 'package:sonexa/features/library/data/models/subsonic_response_models.dart';
import 'package:sonexa/features/library/domain/entities/album.dart';
import 'package:sonexa/features/library/domain/entities/song.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';
import 'package:sonexa/features/player/presentation/providers/player_provider.dart';

// Re-export commonly used providers for home page convenience
export 'package:sonexa/features/library/presentation/providers/library_provider.dart'
    show subsonicApiClientProvider, libraryRepositoryProvider;

// ─── 最新专辑 ──────────────────────────────────────────────
final newestAlbumsProvider = FutureProvider<List<Album>>((ref) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getAlbumList(type: 'newest', size: 10);
});

// ─── 最近播放的专辑 ────────────────────────────────────────
final recentAlbumsProvider = FutureProvider<List<Album>>((ref) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getAlbumList(type: 'recent', size: 10);
});

// ─── 随机推荐歌曲 (首页独立于资料库的 randomSongsProvider) ─
final homeRandomSongsProvider = FutureProvider<List<Song>>((ref) async {
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.getRandomSongs(size: 20);
});

// ─── 我的收藏歌曲 ───────────────────────────────────────────
final starredSongsProvider = FutureProvider<List<Song>>((ref) async {
  final client = await ref.watch(subsonicApiClientProvider.future);
  final response = await client.getStarred2();
  final body = response.subsonicResponseBody;
  final starred = body?['starred2'] as Map<String, dynamic>?;
  final songs = starred?['song'] as List<dynamic>? ?? [];

  return songs
      .map((song) => SubsonicMappers.song(song as Map<String, dynamic>))
      .toList();
});

// ─── 猜你喜欢 ───────────────────────────────────────────────
final similarSongsProvider = FutureProvider<List<Song>>((ref) async {
  final currentSong = ref.watch(currentSongProvider);
  if (currentSong == null) {
    return [];
  }

  final client = await ref.watch(subsonicApiClientProvider.future);
  final response = await client.getSimilarSongs2(currentSong.id, count: 20);
  final body = response.subsonicResponseBody;
  final similarSongs = body?['similarSongs2'] as Map<String, dynamic>?;
  final songs = similarSongs?['song'] as List<dynamic>? ?? [];

  return songs
      .map((song) => SubsonicMappers.song(song as Map<String, dynamic>))
      .toList();
});
