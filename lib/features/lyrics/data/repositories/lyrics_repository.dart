import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:ohmymusic/core/database/app_database.dart';
import 'package:ohmymusic/core/network/subsonic_api_client.dart';
import 'package:ohmymusic/features/lyrics/data/lrc_parser.dart';
import 'package:ohmymusic/features/lyrics/domain/entities/lyrics.dart';

class LyricsRepository {
  LyricsRepository(this._api, this._dio, this._database);

  static const Duration _cacheTtl = Duration(days: 7);

  final SubsonicApiClient _api;
  final Dio _dio;
  final AppDatabase _database;

  /// 先查本地缓存，再依次回退到不同歌词源。
  Future<Lyrics?> getLyrics(String songId, String artist, String title) async {
    final cachedLyrics = await _getCachedLyrics(songId);
    if (cachedLyrics != null) {
      return cachedLyrics;
    }

    final normalizedArtist = artist.trim();
    final normalizedTitle = title.trim();
    if (normalizedArtist.isEmpty && normalizedTitle.isEmpty) {
      return null;
    }

    final navidromeLyrics = await _fetchFromNavidrome(
      songId: songId,
      artist: normalizedArtist,
      title: normalizedTitle,
    );
    if (navidromeLyrics != null) {
      await _cacheLyrics(navidromeLyrics);
      return navidromeLyrics;
    }

    final lrclibLyrics = await _fetchFromLrclib(
      songId: songId,
      artist: normalizedArtist,
      title: normalizedTitle,
    );
    if (lrclibLyrics != null) {
      await _cacheLyrics(lrclibLyrics);
      return lrclibLyrics;
    }

    return null;
  }

  /// 仅在缓存未过期时直接命中。
  Future<Lyrics?> _getCachedLyrics(String songId) async {
    final cached = await (_database.select(_database.cachedLyrics)
          ..where((table) => table.songId.equals(songId)))
        .getSingleOrNull();
    if (cached == null) {
      return null;
    }

    if (DateTime.now().difference(cached.cachedAt) >= _cacheTtl) {
      return null;
    }

    try {
      final decoded = jsonDecode(cached.linesJson) as List<dynamic>;
      final lines = decoded
          .map(
            (item) => LyricLine.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          )
          .toList();

      return Lyrics(
        songId: cached.songId,
        source: _parseLyricsSource(cached.source),
        isSynced: cached.isSynced,
        lines: lines,
        rawLrc: cached.rawLrc,
      );
    } catch (_) {
      return null;
    }
  }

  /// Navidrome 返回的 value 可能是同步 LRC，也可能是纯文本歌词。
  Future<Lyrics?> _fetchFromNavidrome({
    required String songId,
    required String artist,
    required String title,
  }) async {
    try {
      final response = await _api.getLyrics(artist: artist, title: title);
      final rawText = (response?['value'] as String?)?.trim();
      if (rawText == null || rawText.isEmpty) {
        return null;
      }

      return _buildLyrics(
        songId: songId,
        source: LyricsSource.tag,
        rawText: rawText,
      );
    } catch (_) {
      return null;
    }
  }

  /// lrclib 优先使用同步歌词，失败时回退到纯文本歌词。
  Future<Lyrics?> _fetchFromLrclib({
    required String songId,
    required String artist,
    required String title,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'get',
        queryParameters: {
          'artist_name': artist,
          'track_name': title,
        },
      );

      final data = response.data;
      if (data == null) {
        return null;
      }

      final syncedLyrics = (data['syncedLyrics'] as String?)?.trim();
      if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
        return _buildLyrics(
          songId: songId,
          source: LyricsSource.lrclib,
          rawText: syncedLyrics,
        );
      }

      final plainLyrics = (data['plainLyrics'] as String?)?.trim();
      if (plainLyrics == null || plainLyrics.isEmpty) {
        return null;
      }

      return _buildLyrics(
        songId: songId,
        source: LyricsSource.lrclib,
        rawText: plainLyrics,
      );
    } on DioException {
      return null;
    }
  }

  /// 统一构建歌词实体，避免不同来源重复分支。
  Lyrics _buildLyrics({
    required String songId,
    required LyricsSource source,
    required String rawText,
  }) {
    final isSynced = _containsTimestamp(rawText);
    return Lyrics(
      songId: songId,
      source: source,
      isSynced: isSynced,
      lines: isSynced ? parseLrc(rawText) : _parsePlainLyrics(rawText),
      rawLrc: rawText,
    );
  }

  /// 纯文本歌词按行拆分，供非时间轴歌词展示。
  List<LyricLine> _parsePlainLyrics(String rawText) {
    return rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => LyricLine(timeMs: 0, text: line))
        .toList();
  }

  /// 检查文本是否包含标准 LRC 时间戳。
  bool _containsTimestamp(String rawText) {
    return RegExp(r'\[(\d{2}):(\d{2})\.?((?:\d{0,3}))\]').hasMatch(rawText);
  }

  /// 将歌词实体持久化到 Drift 缓存表。
  Future<void> _cacheLyrics(Lyrics lyrics) async {
    await _database.into(_database.cachedLyrics).insertOnConflictUpdate(
      CachedLyricsCompanion.insert(
        songId: lyrics.songId,
        source: lyrics.source.name,
        isSynced: lyrics.isSynced,
        rawLrc: Value(lyrics.rawLrc),
        linesJson: jsonEncode(lyrics.lines.map((line) => line.toJson()).toList()),
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// 将缓存中的字符串枚举安全恢复为实体枚举。
  LyricsSource _parseLyricsSource(String rawSource) {
    return LyricsSource.values.firstWhere(
      (source) => source.name == rawSource,
      orElse: () => LyricsSource.manual,
    );
  }

  /// 从 lrclib 搜索歌词候选列表，返回最多 [limit] 条结果。
  Future<List<Lyrics>> searchLrclib({
    required String songId,
    required String artist,
    required String title,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        'search',
        queryParameters: {
          'artist_name': artist.trim(),
          'track_name': title.trim(),
        },
      );

      final data = response.data;
      if (data == null || data.isEmpty) return [];

      final results = <Lyrics>[];
      for (final item in data.take(limit)) {
        final map = item as Map<String, dynamic>;
        final syncedLyrics = (map['syncedLyrics'] as String?)?.trim();
        final plainLyrics = (map['plainLyrics'] as String?)?.trim();
        final rawText = (syncedLyrics?.isNotEmpty == true)
            ? syncedLyrics!
            : plainLyrics ?? '';
        if (rawText.isEmpty) continue;

        results.add(_buildLyrics(
          songId: songId,
          source: LyricsSource.lrclib,
          rawText: rawText,
        ));
      }
      return results;
    } on DioException {
      return [];
    }
  }

  /// 用新歌词替换当前缓存的歌词（手动选择场景）。
  Future<void> replaceLyrics(Lyrics lyrics) async {
    await _cacheLyrics(lyrics);
  }
}
