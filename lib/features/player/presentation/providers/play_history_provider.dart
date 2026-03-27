import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ohmymusic/core/audio/audio_handler.dart';
import 'package:ohmymusic/core/database/app_database.dart';
import 'package:ohmymusic/features/auth/presentation/providers/auth_provider.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

class PlayHistoryNotifier extends AsyncNotifier<List<PlayHistoryData>> {
  late final AppDatabase _database;
  late final StreamSubscription<int?> _indexSubscription;
  DateTime? _lastSongStartTime;
  MediaItem? _lastPlayedItem;

  @override
  Future<List<PlayHistoryData>> build() async {
    _database = ref.read(databaseProvider);

    final audioHandler = ref.read(audioHandlerProvider);
    _lastPlayedItem = audioHandler.mediaItem.valueOrNull;
    _lastSongStartTime = _lastPlayedItem == null ? null : DateTime.now();

    _indexSubscription = audioHandler.currentIndexStream.listen(
      (index) => _handleSongChanged(audioHandler, index),
    );
    ref.onDispose(_indexSubscription.cancel);

    return getHistory();
  }

  Future<void> onSongPlayed(
    String songId,
    String title,
    String artist,
    String albumId,
    int listenDurationSec,
  ) async {
    // 先记录播放历史，再根据播放时长决定是否 scrobble。
    await _database.into(_database.playHistory).insert(
      PlayHistoryCompanion.insert(
        songId: songId,
        songTitle: title,
        artist: artist,
        albumId: albumId,
        playedAt: DateTime.now(),
        listenDurationSec: listenDurationSec,
      ),
    );

    if (listenDurationSec >= 30) {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.scrobble(songId);
    }

    state = AsyncData(await getHistory());
  }

  Future<List<PlayHistoryData>> getHistory() {
    return (_database.select(_database.playHistory)
          ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
          ..limit(100))
        .get();
  }

  Future<void> refresh() async {
    state = AsyncData(await getHistory());
  }

  Future<void> _handleSongChanged(
    MusicAudioHandler audioHandler,
    int? index,
  ) async {
    // 使用 audioHandler.mediaItem 获取当前播放的曲目，
    // 而非 queue[index]，因为在随机播放模式下 currentIndex 对应的是
    // shuffle 后的逻辑顺序，直接用它作为原始 queue 的下标会取到错误的歌曲。
    final nextItem = audioHandler.mediaItem.valueOrNull;

    final previousItem = _lastPlayedItem;
    final previousStartTime = _lastSongStartTime;

    if (previousItem != null && previousStartTime != null) {
      final listenedSeconds = DateTime.now().difference(previousStartTime).inSeconds;
      final previousSongId = previousItem.extras?['songId'] as String? ?? previousItem.id;
      final previousAlbumId = previousItem.extras?['albumId'] as String? ?? '';

      if (previousSongId.isNotEmpty && listenedSeconds > 0) {
        await onSongPlayed(
          previousSongId,
          previousItem.title,
          previousItem.artist ?? '',
          previousAlbumId,
          listenedSeconds,
        );
      }
    }

    _lastPlayedItem = nextItem;
    _lastSongStartTime = nextItem == null ? null : DateTime.now();
  }
}

final playHistoryNotifierProvider =
    AsyncNotifierProvider<PlayHistoryNotifier, List<PlayHistoryData>>(
      PlayHistoryNotifier.new,
    );

final scrobbleServiceProvider = Provider<void>((ref) {
  // 通过 watch 保证服务在应用生命周期内持续监听歌曲切换。
  ref.watch(playHistoryNotifierProvider);
});
