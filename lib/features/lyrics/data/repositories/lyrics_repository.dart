import 'dart:convert';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:sonexa/core/database/app_database.dart';
import 'package:sonexa/core/network/subsonic_api_client.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/features/lyrics/data/lrc_parser.dart';
import 'package:sonexa/features/lyrics/domain/entities/lyrics.dart';

class LyricsRepository {
  LyricsRepository(this._api, this._dio, this._database);

  static const Duration _cacheTtl = Duration(days: 7);
  static const Duration _navidromeTimeout = Duration(seconds: 3);
  static const Duration _lrclibTimeout = Duration(seconds: 8);

  final SubsonicApiClient _api;
  final Dio _dio;
  final AppDatabase _database;

  void _diag(String message) {
    unawaited(DiagnosticLogger.instance.log(message));
  }

  /// 先查本地缓存，再依次回退到不同歌词源。
  Future<Lyrics?> getLyrics(String songId, String artist, String title) async {
    _diag('[DIAG][LYRICS] getLyrics: songId=$songId, artist="$artist", title="$title"');
    final cachedLyrics = await _getCachedLyrics(songId);
    if (cachedLyrics?.isSynced == true) {
      _diag('[DIAG][LYRICS] getLyrics: hit synced cache');
      return cachedLyrics;
    }

    Lyrics? fallbackLyrics = cachedLyrics?.isSynced == true ? null : cachedLyrics;

    final normalizedArtist = artist.trim();
    final normalizedTitle = title.trim();

    final songIdLyrics = await _fetchFromSongId(songId: songId);
    if (songIdLyrics?.isSynced == true) {
      final syncedSongIdLyrics = songIdLyrics!;
      _diag('[DIAG][LYRICS] getLyrics: using songId synced lyrics');
      await _cacheLyrics(syncedSongIdLyrics);
      return syncedSongIdLyrics;
    }

    if (songIdLyrics != null && !songIdLyrics.isSynced) {
      _diag('[DIAG][LYRICS] getLyrics: storing songId plain lyrics as fallback candidate');
      fallbackLyrics = songIdLyrics;
    }

    if (normalizedArtist.isEmpty && normalizedTitle.isEmpty) {
      _diag('[DIAG][LYRICS] getLyrics: metadata empty, fallback only');
      return fallbackLyrics;
    }

    final navidromeLyrics = await _fetchFromNavidrome(
      songId: songId,
      artist: normalizedArtist,
      title: normalizedTitle,
    );
    if (navidromeLyrics?.isSynced == true) {
      final syncedNavidromeLyrics = navidromeLyrics!;
      _diag('[DIAG][LYRICS] getLyrics: using synced Navidrome lyrics');
      await _cacheLyrics(syncedNavidromeLyrics);
      return syncedNavidromeLyrics;
    }

    if (navidromeLyrics != null && !navidromeLyrics.isSynced) {
      _diag('[DIAG][LYRICS] getLyrics: storing plain Navidrome lyrics as fallback candidate');
      fallbackLyrics = navidromeLyrics;
    }

    final lrclibLyrics = await _fetchFromLrclib(
      songId: songId,
      artist: normalizedArtist,
      title: normalizedTitle,
    );
    if (lrclibLyrics != null) {
      _diag('[DIAG][LYRICS] getLyrics: using lrclib lyrics, synced=${lrclibLyrics.isSynced}');
      await _cacheLyrics(lrclibLyrics);
      return lrclibLyrics;
    }

    if (fallbackLyrics != null) {
      _diag('[DIAG][LYRICS] getLyrics: returning fallback lyrics, synced=${fallbackLyrics.isSynced}');
      await _cacheLyrics(fallbackLyrics);
    }

    _diag('[DIAG][LYRICS] getLyrics: return ${fallbackLyrics == null ? 'null' : 'fallback'}');
    return fallbackLyrics;
  }

  /// 仅在缓存未过期时直接命中。
  Future<Lyrics?> _getCachedLyrics(String songId) async {
    final cached = await (_database.select(_database.cachedLyrics)
          ..where((table) => table.songId.equals(songId)))
        .getSingleOrNull();
    if (cached == null) {
      _diag('[DIAG][LYRICS] cache miss');
      return null;
    }

    if (DateTime.now().difference(cached.cachedAt) >= _cacheTtl) {
      _diag('[DIAG][LYRICS] cache expired');
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
      _diag('[DIAG][LYRICS] cache decode failed');
      return null;
    }
  }

  /// Navidrome 返回的 value 可能是同步 LRC，也可能是纯文本歌词。
  Future<Lyrics?> _fetchFromSongId({required String songId}) async {
    try {
      final response = await _api.getLyricsBySongId(songId).timeout(_navidromeTimeout);
      if (response == null) {
        _diag('[DIAG][LYRICS] getLyricsBySongId returned null');
        return null;
      }

      final syncedLines = response['line'];
      if (syncedLines is List && syncedLines.isNotEmpty) {
        final lines = syncedLines
            .whereType<Map>()
            .map((entry) => Map<String, dynamic>.from(entry))
            .map((entry) {
              final text = (entry['value'] as String? ?? '').trim();
              final start = (entry['start'] as int?) ?? 0;
              return LyricLine(timeMs: start, text: text.isEmpty ? '…' : text);
            })
            .toList();

        if (lines.isNotEmpty) {
          _diag('[DIAG][LYRICS] getLyricsBySongId returned structured lines');
          return Lyrics(
            songId: songId,
            source: LyricsSource.tag,
            isSynced: true,
            lines: lines,
            rawLrc: null,
          );
        }
      }

      final rawText = (response['value'] as String?)?.trim();
      if (rawText == null || rawText.isEmpty) {
        _diag('[DIAG][LYRICS] getLyricsBySongId returned empty value');
        return null;
      }

      _diag('[DIAG][LYRICS] getLyricsBySongId returned text payload');
      return _buildLyrics(
        songId: songId,
        source: LyricsSource.tag,
        rawText: rawText,
      );
    } on TimeoutException {
      _diag('[DIAG][LYRICS] getLyricsBySongId timed out');
      return null;
    } catch (_) {
      _diag('[DIAG][LYRICS] getLyricsBySongId failed');
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
      final response = await _api
          .getLyrics(artist: artist, title: title)
          .timeout(_navidromeTimeout);
      final rawText = (response?['value'] as String?)?.trim();
      if (rawText == null || rawText.isEmpty) {
        _diag('[DIAG][LYRICS] Navidrome returned empty lyrics');
        return null;
      }

      _diag('[DIAG][LYRICS] Navidrome returned lyrics payload');

      return _buildLyrics(
        songId: songId,
        source: LyricsSource.tag,
        rawText: rawText,
      );
    } on TimeoutException {
      _diag('[DIAG][LYRICS] Navidrome request timed out');
      return null;
    } catch (_) {
      _diag('[DIAG][LYRICS] Navidrome request failed');
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
      final response = await _dio
          .get<Map<String, dynamic>>(
            'get',
            queryParameters: {
              'artist_name': artist,
              'track_name': title,
            },
          )
          .timeout(_lrclibTimeout);

      final data = response.data;
      if (data == null) {
        _diag('[DIAG][LYRICS] lrclib returned null data');
        return null;
      }

      final syncedLyrics = (data['syncedLyrics'] as String?)?.trim();
      if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
        _diag('[DIAG][LYRICS] lrclib returned synced lyrics');
        return _buildLyrics(
          songId: songId,
          source: LyricsSource.lrclib,
          rawText: syncedLyrics,
        );
      }

      final plainLyrics = (data['plainLyrics'] as String?)?.trim();
      if (plainLyrics == null || plainLyrics.isEmpty) {
        _diag('[DIAG][LYRICS] lrclib returned no plain lyrics');
        return null;
      }

      _diag('[DIAG][LYRICS] lrclib returned plain lyrics');

      return _buildLyrics(
        songId: songId,
        source: LyricsSource.lrclib,
        rawText: plainLyrics,
      );
    } on TimeoutException {
      _diag('[DIAG][LYRICS] lrclib request timed out');
      return null;
    } on DioException {
      _diag('[DIAG][LYRICS] lrclib request failed');
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
