import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ohmymusic/features/library/data/models/subsonic_response_models.dart';
import 'package:ohmymusic/features/library/domain/entities/album.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

// Re-export commonly used providers for home page convenience
export 'package:ohmymusic/features/library/presentation/providers/library_provider.dart'
    show subsonicApiClientProvider, libraryRepositoryProvider;

// ─── 最新专辑 ──────────────────────────────────────────────
final newestAlbumsProvider = FutureProvider<List<Album>>((ref) async {
  return ref
      .read(libraryRepositoryProvider)
      .getAlbumList(type: 'newest', size: 10);
});

// ─── 最近播放的专辑 ────────────────────────────────────────
final recentAlbumsProvider = FutureProvider<List<Album>>((ref) async {
  return ref
      .read(libraryRepositoryProvider)
      .getAlbumList(type: 'recent', size: 10);
});

// ─── 随机推荐歌曲 (首页独立于资料库的 randomSongsProvider) ─
final homeRandomSongsProvider = FutureProvider<List<Song>>((ref) async {
  return ref.read(libraryRepositoryProvider).getRandomSongs(size: 20);
});

// ─── 我的收藏歌曲 ───────────────────────────────────────────
final starredSongsProvider = FutureProvider<List<Song>>((ref) async {
  final response = await ref.read(subsonicApiClientProvider).getStarred2();
  final body = response.subsonicResponseBody;
  final starred = body?['starred2'] as Map<String, dynamic>?;
  final songs = starred?['song'] as List<dynamic>? ?? [];

  return songs.map((song) => _parseSong(song as Map<String, dynamic>)).toList();
});

// ─── 猜你喜欢 ───────────────────────────────────────────────
final similarSongsProvider = FutureProvider<List<Song>>((ref) async {
  final currentSong = ref.watch(currentSongProvider);
  if (currentSong == null) {
    return [];
  }

  final response = await ref
      .read(subsonicApiClientProvider)
      .getSimilarSongs2(currentSong.id, count: 20);
  final body = response.subsonicResponseBody;
  final similarSongs = body?['similarSongs2'] as Map<String, dynamic>?;
  final songs = similarSongs?['song'] as List<dynamic>? ?? [];

  return songs.map((song) => _parseSong(song as Map<String, dynamic>)).toList();
});

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
      starred: json['starred'] != null
          ? DateTime.tryParse(json['starred'] as String)
          : null,
    );
