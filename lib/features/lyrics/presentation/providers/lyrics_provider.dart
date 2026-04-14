import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ohmymusic/core/database/daos/settings_dao.dart';
import 'package:ohmymusic/features/auth/presentation/providers/auth_provider.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';
import 'package:ohmymusic/features/lyrics/data/repositories/lyrics_repository.dart';
import 'package:ohmymusic/features/lyrics/domain/entities/lyrics.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

class LyricsRequestSnapshot {
  const LyricsRequestSnapshot({
    required this.songId,
    required this.artist,
    required this.title,
  });

  final String songId;
  final String artist;
  final String title;

  @override
  bool operator ==(Object other) {
    return other is LyricsRequestSnapshot &&
        other.songId == songId &&
        other.artist == artist &&
        other.title == title;
  }

  @override
  int get hashCode => Object.hash(songId, artist, title);
}

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

final currentLyricsRequestProvider = Provider<LyricsRequestSnapshot?>((ref) {
  final currentMediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
  if (currentMediaItem == null) {
    return null;
  }

  final songId =
      (currentMediaItem.extras?['songId'] as String? ?? currentMediaItem.id)
          .trim();
  if (songId.isEmpty) {
    return null;
  }

  return LyricsRequestSnapshot(
    songId: songId,
    artist: (currentMediaItem.artist ?? '').trim(),
    title: currentMediaItem.title.trim(),
  );
});

/// 使用同一条 mediaItem emission 里的 songId/artist/title 生成歌词请求快照。
/// 这样可以避免 songId 与元信息来自不同时刻，导致歌词短暂显示后又回退到空白。
final lyricsProvider = FutureProvider.family<Lyrics?, LyricsRequestSnapshot>((
  ref,
  request,
) async {
  final repo = await ref.watch(lyricsRepositoryProvider.future);
  return repo.getLyrics(request.songId, request.artist, request.title);
});

/// 控制歌词区域显示与隐藏。
final showLyricsProvider = StateProvider<bool>((ref) => true);

/// 联网搜索歌词候选列表（lrclib）。
/// 参数格式: "songId|artist|title"
final lyricsSearchProvider = FutureProvider.family<List<Lyrics>, String>((
  ref,
  query,
) async {
  final parts = query.split('|');
  if (parts.length < 3) return [];
  final songId = parts[0];
  final artist = parts[1];
  final title = parts.sublist(2).join('|'); // title 中可能包含 |
  final repo = await ref.watch(lyricsRepositoryProvider.future);

  return repo.searchLrclib(songId: songId, artist: artist, title: title);
});

final currentLyricsOffsetProvider = Provider<int>((ref) {
  final request = ref.watch(currentLyricsRequestProvider);
  if (request == null) {
    return 0;
  }

  return ref.watch(lyricsOffsetProvider(request.songId)).valueOrNull ?? 0;
});

final lyricsOffsetProvider =
    AsyncNotifierProvider.family<LyricsOffsetNotifier, int, String>(
      LyricsOffsetNotifier.new,
    );

class LyricsOffsetNotifier extends FamilyAsyncNotifier<int, String> {
  static const _settingPrefix = 'lyrics_offset_ms_';

  late final SettingsDao _settingsDao = SettingsDao(ref.read(databaseProvider));

  @override
  Future<int> build(String arg) async {
    final rawValue = await _settingsDao.getSetting('$_settingPrefix$arg');
    return int.tryParse(rawValue ?? '') ?? 0;
  }

  Future<void> setOffset(int offsetMs) async {
    final normalized = offsetMs.clamp(-5000, 5000);
    state = AsyncData(normalized);
    await _settingsDao.setSetting('$_settingPrefix$arg', normalized.toString());
  }

  Future<void> adjustBy(int deltaMs) async {
    final current = state.valueOrNull ?? await future;
    await setOffset(current + deltaMs);
  }

  Future<void> reset() => setOffset(0);
}
