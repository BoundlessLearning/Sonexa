import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ohmymusic/features/auth/presentation/providers/auth_provider.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';
import 'package:ohmymusic/features/lyrics/data/repositories/lyrics_repository.dart';
import 'package:ohmymusic/features/lyrics/domain/entities/lyrics.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

/// 为歌词仓库创建独立的 lrclib 客户端，避免复用 Subsonic 配置。
final lyricsRepositoryProvider = FutureProvider<LyricsRepository>((ref) async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://lrclib.net/api',
      headers: const {'Lrclib-UserAgent': 'OhMyMusic/1.0'},
    ),
  );
  ref.onDispose(() => dio.close(force: true));

  return LyricsRepository(
    await ref.watch(subsonicApiClientProvider.future),
    dio,
    ref.read(databaseProvider),
  );
});

/// 根据当前播放中的媒体信息拉取对应歌词。
final lyricsProvider = FutureProvider.family<Lyrics?, String>((ref, songId) async {
  final audioHandler = ref.read(audioHandlerProvider);
  final mediaItem = audioHandler.mediaItem.valueOrNull;
  if (mediaItem == null) {
    return null;
  }

  final currentSongId = mediaItem.extras?['songId'] as String? ?? mediaItem.id;
  if (currentSongId != songId) {
    return null;
  }

  final artist = (mediaItem.artist ?? '').trim();
  final title = mediaItem.title.trim();

  // 超过 8 秒未获取到歌词则放弃，UI 会显示"暂无歌词"。
  try {
    final repo = await ref.watch(lyricsRepositoryProvider.future);
    return await repo
        .getLyrics(songId, artist, title)
        .timeout(const Duration(seconds: 8));
  } on TimeoutException {
    return null;
  }
});

/// 控制歌词区域显示与隐藏。
final showLyricsProvider = StateProvider<bool>((ref) => true);

/// 联网搜索歌词候选列表（lrclib）。
/// 参数格式: "songId|artist|title"
final lyricsSearchProvider =
    FutureProvider.family<List<Lyrics>, String>((ref, query) async {
  final parts = query.split('|');
  if (parts.length < 3) return [];
  final songId = parts[0];
  final artist = parts[1];
  final title = parts.sublist(2).join('|'); // title 中可能包含 |
  final repo = await ref.watch(lyricsRepositoryProvider.future);

  return repo.searchLrclib(
        songId: songId,
        artist: artist,
        title: title,
      );
});
