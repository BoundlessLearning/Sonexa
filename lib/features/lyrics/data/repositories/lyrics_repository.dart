import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:sonexa/core/database/app_database.dart';
import 'package:sonexa/core/network/subsonic_api_client.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/features/lyrics/data/lrc_parser.dart';
import 'package:sonexa/features/lyrics/data/lyrics_text_normalizer.dart';
import 'package:sonexa/features/lyrics/data/navidrome_native_lyrics_client.dart';
import 'package:sonexa/features/lyrics/domain/entities/lyrics.dart';

class LyricsRepository {
  LyricsRepository(this._api, this._dio, this._database);

  static const Duration _cacheTtl = Duration(days: 7);
  static const Duration _navidromeTimeout = Duration(seconds: 3);
  static const Duration _publicLyricsTimeout = Duration(seconds: 8);
  static const String _publicLyricsSearchPath = '/jsonapi';

  final SubsonicApiClient _api;
  final Dio _dio;
  final AppDatabase _database;
  late final NavidromeNativeLyricsClient _nativeLyricsClient =
      NavidromeNativeLyricsClient(
        baseUrl: _api.baseUrl,
        username: _api.username,
        password: _api.password,
      );

  void _diag(String message) {
    unawaited(DiagnosticLogger.instance.log(message));
  }

  Future<Lyrics?> getLyrics(String songId, String artist, String title) async {
    _diag(
      '[DIAG][LYRICS] getLyrics: songId=$songId, artist="$artist", title="$title"',
    );

    final cachedLyrics = await _getCachedLyrics(songId);
    final cachedLooksGarbled =
        cachedLyrics != null && _lyricsLooksGarbled(cachedLyrics);
    if (cachedLyrics?.isSynced == true && !cachedLooksGarbled) {
      _diag('[DIAG][LYRICS] getLyrics: hit synced cache');
      return cachedLyrics;
    }
    if (cachedLooksGarbled) {
      _diag(
        '[DIAG][LYRICS] cached lyrics still look garbled; trying remote sources first',
      );
    }

    Lyrics? fallbackLyrics = cachedLyrics;

    final normalizedArtist = artist.trim();
    final normalizedTitle = title.trim();

    var shouldTryNativeLyrics = cachedLooksGarbled;

    final songIdLyrics = await _fetchFromSongId(songId: songId);
    if (songIdLyrics != null) {
      final garbled = _lyricsLooksGarbled(songIdLyrics);
      if (songIdLyrics.isSynced && !garbled) {
        _diag('[DIAG][LYRICS] getLyrics: using songId synced lyrics');
        await _cacheLyrics(songIdLyrics);
        return songIdLyrics;
      }

      if (garbled) {
        _diag(
          '[DIAG][LYRICS] songId lyrics still look garbled; keeping as fallback',
        );
        shouldTryNativeLyrics = true;
      } else {
        _diag(
          '[DIAG][LYRICS] getLyrics: storing songId plain lyrics as fallback candidate',
        );
      }
      fallbackLyrics = songIdLyrics;
    } else {
      shouldTryNativeLyrics = true;
    }

    if (shouldTryNativeLyrics) {
      final nativeLyrics = await _fetchFromNavidromeNative(songId: songId);
      if (nativeLyrics != null) {
        final garbled = _lyricsLooksGarbled(nativeLyrics);
        if (nativeLyrics.isSynced && !garbled) {
          _diag('[DIAG][LYRICS] getLyrics: using Navidrome native lyrics');
          await _cacheLyrics(nativeLyrics);
          return nativeLyrics;
        }

        if (garbled) {
          _diag(
            '[DIAG][LYRICS] Navidrome native lyrics still look garbled; keeping existing fallback',
          );
        } else {
          _diag(
            '[DIAG][LYRICS] getLyrics: storing Navidrome native lyrics as fallback candidate',
          );
          fallbackLyrics = nativeLyrics;
        }
      }
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
    if (navidromeLyrics != null) {
      final garbled = _lyricsLooksGarbled(navidromeLyrics);
      if (navidromeLyrics.isSynced && !garbled) {
        _diag('[DIAG][LYRICS] getLyrics: using synced Navidrome lyrics');
        await _cacheLyrics(navidromeLyrics);
        return navidromeLyrics;
      }

      if (garbled) {
        _diag(
          '[DIAG][LYRICS] Navidrome lyrics still look garbled; keeping as fallback',
        );
      } else {
        _diag(
          '[DIAG][LYRICS] getLyrics: storing plain Navidrome lyrics as fallback candidate',
        );
      }
      fallbackLyrics = navidromeLyrics;
    }

    final publicLyrics = await _fetchFromPublicJsonApi(
      songId: songId,
      artist: normalizedArtist,
      title: normalizedTitle,
    );
    if (publicLyrics != null) {
      _diag(
        '[DIAG][LYRICS] getLyrics: using public synced lyrics, synced=${publicLyrics.isSynced}',
      );
      await _cacheLyrics(publicLyrics);
      return publicLyrics;
    }

    if (fallbackLyrics != null) {
      _diag(
        '[DIAG][LYRICS] getLyrics: returning fallback lyrics, synced=${fallbackLyrics.isSynced}, garbled=${_lyricsLooksGarbled(fallbackLyrics)}',
      );
      await _cacheLyrics(fallbackLyrics);
    }

    _diag(
      '[DIAG][LYRICS] getLyrics: return ${fallbackLyrics == null ? 'null' : 'fallback'}',
    );
    return fallbackLyrics;
  }

  Future<Lyrics?> _getCachedLyrics(String songId) async {
    final cached =
        await (_database.select(_database.cachedLyrics)
          ..where((table) => table.songId.equals(songId))).getSingleOrNull();
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
      final lines =
          decoded
              .map(
                (item) => LyricLine.fromJson(
                  Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
                ),
              )
              .toList();
      final normalizedLines = LyricsTextNormalizer.normalizeLines(lines);

      return Lyrics(
        songId: cached.songId,
        source: _parseLyricsSource(cached.source),
        isSynced: cached.isSynced,
        lines: normalizedLines,
        rawLrc:
            cached.rawLrc == null
                ? null
                : LyricsTextNormalizer.normalize(cached.rawLrc!),
      );
    } catch (_) {
      _diag('[DIAG][LYRICS] cache decode failed');
      return null;
    }
  }

  Future<Lyrics?> _fetchFromSongId({required String songId}) async {
    try {
      final response = await _api
          .getLyricsBySongId(songId)
          .timeout(_navidromeTimeout);
      if (response == null) {
        _diag('[DIAG][LYRICS] getLyricsBySongId returned null');
        return null;
      }

      final syncedLines = response['line'];
      if (syncedLines is List && syncedLines.isNotEmpty) {
        final lyrics = _buildStructuredLyrics(
          songId: songId,
          source: LyricsSource.tag,
          payload: response,
        );

        if (lyrics != null) {
          if (_lyricsLooksGarbled(lyrics)) {
            _diag(
              '[DIAG][LYRICS] getLyricsBySongId structured lyrics still look garbled',
            );
          }

          _diag('[DIAG][LYRICS] getLyricsBySongId returned structured lines');
          return lyrics;
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

  Future<Lyrics?> _fetchFromNavidromeNative({required String songId}) async {
    try {
      final payload = await _nativeLyricsClient
          .getStructuredLyrics(songId)
          .timeout(_navidromeTimeout + const Duration(seconds: 1));
      if (payload == null || payload.isEmpty) {
        _diag('[DIAG][LYRICS] Navidrome native returned empty lyrics');
        return null;
      }

      Lyrics? garbledFallback;
      for (final entry in payload) {
        final lyrics = _buildStructuredLyrics(
          songId: songId,
          source: LyricsSource.tag,
          payload: entry,
        );
        if (lyrics == null) {
          continue;
        }
        if (!_lyricsLooksGarbled(lyrics)) {
          _diag('[DIAG][LYRICS] Navidrome native returned clean lyrics');
          return lyrics;
        }
        garbledFallback ??= lyrics;
      }

      if (garbledFallback != null) {
        _diag('[DIAG][LYRICS] Navidrome native returned garbled lyrics');
      } else {
        _diag('[DIAG][LYRICS] Navidrome native returned unusable lyrics');
      }
      return garbledFallback;
    } on TimeoutException {
      _diag('[DIAG][LYRICS] Navidrome native request timed out');
      return null;
    } catch (_) {
      _diag('[DIAG][LYRICS] Navidrome native request failed');
      return null;
    }
  }

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

  Future<Lyrics?> _fetchFromPublicJsonApi({
    required String songId,
    required String artist,
    required String title,
  }) async {
    final candidates = await _searchPublicJsonApi(
      songId: songId,
      artist: artist,
      title: title,
      limit: 5,
    );
    if (candidates.isEmpty) {
      _diag('[DIAG][LYRICS] public jsonapi returned no usable candidates');
      return null;
    }

    final bestCandidate = candidates.first;
    _diag(
      '[DIAG][LYRICS] public jsonapi selected candidate, '
      'synced=${bestCandidate.isSynced}, lines=${bestCandidate.lines.length}',
    );
    return bestCandidate;
  }

  Future<List<Lyrics>> _searchPublicJsonApi({
    required String songId,
    required String artist,
    required String title,
    int limit = 10,
  }) async {
    try {
      final response = await _dio
          .get<List<dynamic>>(
            _publicLyricsSearchPath,
            queryParameters: {'artist': artist.trim(), 'title': title.trim()},
          )
          .timeout(_publicLyricsTimeout);

      final data = response.data;
      if (data == null || data.isEmpty) {
        return const [];
      }

      final rankedResults = <({int rank, Lyrics lyrics})>[];
      for (final item in data) {
        if (item is! Map) {
          continue;
        }
        final map = Map<String, dynamic>.from(item);
        final lyrics = _buildLyricsFromPublicJsonApiEntry(
          songId: songId,
          payload: map,
        );
        if (lyrics == null) {
          continue;
        }

        rankedResults.add((
          rank: _rankPublicCandidate(
            payload: map,
            expectedArtist: artist,
            expectedTitle: title,
          ),
          lyrics: lyrics,
        ));
      }

      rankedResults.sort((a, b) => b.rank.compareTo(a.rank));
      return rankedResults.take(limit).map((entry) => entry.lyrics).toList();
    } on TimeoutException {
      _diag('[DIAG][LYRICS] public jsonapi request timed out');
      return const [];
    } on DioException {
      _diag('[DIAG][LYRICS] public jsonapi request failed');
      return const [];
    }
  }

  Lyrics? _buildLyricsFromPublicJsonApiEntry({
    required String songId,
    required Map<String, dynamic> payload,
  }) {
    final rawText = (payload['lrc'] as String?)?.trim();
    if (rawText == null || rawText.isEmpty) {
      return null;
    }

    final lyrics = _buildLyrics(
      songId: songId,
      source: LyricsSource.lrclib,
      rawText: rawText,
    );
    if (lyrics == null || !lyrics.isSynced) {
      return null;
    }

    return lyrics;
  }

  int _rankPublicCandidate({
    required Map<String, dynamic> payload,
    required String expectedArtist,
    required String expectedTitle,
  }) {
    final payloadArtist = _normalizedComparable(payload['artist']?.toString());
    final payloadTitle = _normalizedComparable(payload['title']?.toString());
    final wantedArtist = _normalizedComparable(expectedArtist);
    final wantedTitle = _normalizedComparable(expectedTitle);

    var rank = ((payload['score'] as num?)?.toDouble() ?? 0).round();

    if (payloadTitle == wantedTitle) {
      rank += 2000;
    } else if (payloadTitle.contains(wantedTitle) ||
        wantedTitle.contains(payloadTitle)) {
      rank += 800;
    }

    if (payloadArtist == wantedArtist) {
      rank += 3000;
    } else if (payloadArtist.contains(wantedArtist) ||
        wantedArtist.contains(payloadArtist)) {
      rank += 1200;
    }

    final rawText = (payload['lrc'] as String?)?.trim() ?? '';
    if (_containsTimestamp(rawText)) {
      rank += 500;
    }

    return rank;
  }

  String _normalizedComparable(String? value) {
    return (value ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[·・,，./_\-()]'), '');
  }

  Lyrics? _buildLyrics({
    required String songId,
    required LyricsSource source,
    required String rawText,
  }) {
    final normalizedRawText = LyricsTextNormalizer.normalize(rawText);
    final isSynced = _containsTimestamp(normalizedRawText);
    final lines = LyricsTextNormalizer.normalizeLines(
      isSynced
          ? parseLrc(normalizedRawText)
          : _parsePlainLyrics(normalizedRawText),
    );

    if (lines.isEmpty) {
      _diag(
        '[DIAG][LYRICS] buildLyrics rejected empty lyrics: source=${source.name}',
      );
      return null;
    }
    if (LyricsTextNormalizer.linesLookGarbled(lines)) {
      _diag(
        '[DIAG][LYRICS] buildLyrics kept lyrics that still look garbled: source=${source.name}',
      );
    }

    return Lyrics(
      songId: songId,
      source: source,
      isSynced: isSynced,
      lines: lines,
      rawLrc: normalizedRawText,
    );
  }

  Lyrics? _buildStructuredLyrics({
    required String songId,
    required LyricsSource source,
    required Map<String, dynamic> payload,
  }) {
    final rawLines = payload['line'];
    if (rawLines is! List || rawLines.isEmpty) {
      return null;
    }

    var hasExplicitStart = false;
    final lines = rawLines
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .map((entry) {
          final startValue = entry['start'];
          if (startValue != null) {
            hasExplicitStart = true;
          }
          final text =
              LyricsTextNormalizer.normalize(
                entry['value']?.toString() ?? '',
              ).trim();

          return LyricLine(
            timeMs: _startAsMilliseconds(startValue),
            text: text.isEmpty ? '...' : text,
          );
        })
        .toList(growable: false);

    if (lines.isEmpty) {
      return null;
    }

    final isSynced = payload['synced'] == true || hasExplicitStart;

    return Lyrics(
      songId: songId,
      source: source,
      isSynced: isSynced,
      lines: lines,
      rawLrc: isSynced ? null : lines.map((line) => line.text).join('\n'),
    );
  }

  int _startAsMilliseconds(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return 0;
  }

  List<LyricLine> _parsePlainLyrics(String rawText) {
    return rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => LyricLine(timeMs: 0, text: line))
        .toList();
  }

  bool _containsTimestamp(String rawText) {
    return RegExp(r'\[(\d{2}):(\d{2})\.?((?:\d{0,3}))\]').hasMatch(rawText);
  }

  bool _lyricsLooksGarbled(Lyrics lyrics) {
    return LyricsTextNormalizer.linesLookGarbled(lyrics.lines) ||
        (lyrics.rawLrc != null &&
            LyricsTextNormalizer.looksGarbled(lyrics.rawLrc!));
  }

  Future<void> _cacheLyrics(Lyrics lyrics) async {
    await _database
        .into(_database.cachedLyrics)
        .insertOnConflictUpdate(
          CachedLyricsCompanion.insert(
            songId: lyrics.songId,
            source: lyrics.source.name,
            isSynced: lyrics.isSynced,
            rawLrc: Value(lyrics.rawLrc),
            linesJson: jsonEncode(
              lyrics.lines.map((line) => line.toJson()).toList(),
            ),
            cachedAt: DateTime.now(),
          ),
        );
  }

  LyricsSource _parseLyricsSource(String rawSource) {
    return LyricsSource.values.firstWhere(
      (source) => source.name == rawSource,
      orElse: () => LyricsSource.manual,
    );
  }

  Future<List<Lyrics>> searchLrclib({
    required String songId,
    required String artist,
    required String title,
    int limit = 10,
  }) async {
    return _searchPublicJsonApi(
      songId: songId,
      artist: artist,
      title: title,
      limit: limit,
    );
  }

  Future<void> replaceLyrics(Lyrics lyrics) async {
    await _cacheLyrics(lyrics);
  }
}
