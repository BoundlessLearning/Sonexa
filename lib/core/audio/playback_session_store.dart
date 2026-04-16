import 'dart:convert';

import 'package:audio_service/audio_service.dart';

import 'package:sonexa/core/audio/playback_mode_controller.dart';
import 'package:sonexa/core/database/daos/settings_dao.dart';

class PlaybackSessionSnapshot {
  const PlaybackSessionSnapshot({
    required this.queue,
    required this.currentIndex,
    required this.position,
    required this.wasPlaying,
    required this.playMode,
  });

  final List<MediaItem> queue;
  final int currentIndex;
  final Duration position;
  final bool wasPlaying;
  final PlaybackMode playMode;

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'currentIndex': currentIndex,
      'positionMs': position.inMilliseconds,
      'wasPlaying': wasPlaying,
      'playMode': playMode.name,
      'queue': queue.map(_mediaItemToJson).toList(),
    };
  }

  static PlaybackSessionSnapshot? fromJson(Map<String, dynamic> json) {
    final rawQueue = json['queue'];
    if (rawQueue is! List) {
      return null;
    }

    final queue =
        rawQueue
            .whereType<Map>()
            .map((item) => _mediaItemFromJson(Map<String, dynamic>.from(item)))
            .whereType<MediaItem>()
            .toList();
    if (queue.isEmpty) {
      return null;
    }

    final rawPlayMode = json['playMode'] as String?;
    final playMode = PlaybackMode.values.cast<PlaybackMode?>().firstWhere(
      (mode) => mode?.name == rawPlayMode,
      orElse: () => null,
    );

    final currentIndex = (json['currentIndex'] as num?)?.toInt() ?? 0;
    final clampedIndex = currentIndex.clamp(0, queue.length - 1);
    final positionMs = (json['positionMs'] as num?)?.toInt() ?? 0;

    return PlaybackSessionSnapshot(
      queue: queue,
      currentIndex: clampedIndex,
      position: Duration(milliseconds: positionMs),
      wasPlaying: json['wasPlaying'] == true,
      playMode: playMode ?? PlaybackMode.sequential,
    );
  }

  static Map<String, dynamic> _mediaItemToJson(MediaItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'artist': item.artist,
      'album': item.album,
      'artUri': item.artUri?.toString(),
      'durationMs': item.duration?.inMilliseconds,
      'extras': item.extras,
    };
  }

  static MediaItem? _mediaItemFromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final title = json['title'] as String?;
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      return null;
    }

    final rawExtras = json['extras'];
    final extras =
        rawExtras is Map ? Map<String, dynamic>.from(rawExtras) : null;

    return MediaItem(
      id: id,
      title: title,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      artUri: Uri.tryParse(json['artUri'] as String? ?? ''),
      duration: Duration(
        milliseconds: (json['durationMs'] as num?)?.toInt() ?? 0,
      ),
      extras: extras,
    );
  }
}

class PlaybackSessionStore {
  PlaybackSessionStore(this._settingsDao);

  static const _storageKey = 'player_session_snapshot_v1';

  final SettingsDao _settingsDao;

  Future<PlaybackSessionSnapshot?> load() async {
    final rawValue = await _settingsDao.getSetting(_storageKey);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return PlaybackSessionSnapshot.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(PlaybackSessionSnapshot snapshot) async {
    if (snapshot.queue.isEmpty) {
      await clear();
      return;
    }
    await _settingsDao.setSetting(_storageKey, jsonEncode(snapshot.toJson()));
  }

  Future<void> clear() async {
    await _settingsDao.setSetting(_storageKey, '');
  }
}
