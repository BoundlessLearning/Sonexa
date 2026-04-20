import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:sonexa/core/constants/app_branding.dart';
import 'package:sonexa/core/error/exceptions.dart';
import 'package:sonexa/core/network/interceptors/auth_interceptor.dart';
import 'package:sonexa/core/network/interceptors/retry_interceptor.dart';
import 'package:sonexa/features/library/data/models/subsonic_response_models.dart';

class SubsonicApiClient {
  SubsonicApiClient(
    Dio dio, {
    required String baseUrl,
    required this.username,
    required this.password,
  }) : _dio = dio,
       baseUrl = _normalizeBaseUrl(baseUrl),
       _restBaseUrl = '${_normalizeBaseUrl(baseUrl)}/rest/' {
    // baseUrl 必须以 / 结尾，否则 Dio 会按 URI 规范替换最后一段路径
    _dio.options = _dio.options.copyWith(baseUrl: _restBaseUrl);
    _dio.interceptors.removeWhere(
      (interceptor) =>
          interceptor is SubsonicAuthInterceptor ||
          interceptor is RetryInterceptor,
    );
    _dio.interceptors.insert(0, RetryInterceptor(_dio));
    _dio.interceptors.insert(
      0,
      SubsonicAuthInterceptor(
        baseUrl: this.baseUrl,
        username: username,
        password: password,
      ),
    );
  }

  static const _saltCharacters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  final Dio _dio;
  final String baseUrl;
  final String username;
  final String password;
  final String _restBaseUrl;
  final Random _random = Random.secure();

  /// 验证服务器连接和凭据，失败时抛出具体的 AppException
  Future<void> ping() async {
    await _get('ping');
  }

  Future<Map<String, dynamic>> getArtists() => _get('getArtists');

  Future<Map<String, dynamic>> getArtist(String id) =>
      _get('getArtist', params: {'id': id});

  Future<Map<String, dynamic>> getAlbum(String id) =>
      _get('getAlbum', params: {'id': id});

  Future<Map<String, dynamic>> getSong(String id) =>
      _get('getSong', params: {'id': id});

  Future<Map<String, dynamic>> getGenres() => _get('getGenres');

  Future<Map<String, dynamic>> getArtistInfo2(String id, {int count = 20}) =>
      _get('getArtistInfo2', params: {'id': id, 'count': count});

  Future<Map<String, dynamic>> getAlbumList2({
    required String type,
    int size = 20,
    int offset = 0,
    String? genre,
    int? fromYear,
    int? toYear,
  }) {
    final params = <String, dynamic>{
      'type': type,
      'size': size,
      'offset': offset,
    };

    if (genre != null) {
      params['genre'] = genre;
    }
    if (fromYear != null) {
      params['fromYear'] = fromYear;
    }
    if (toYear != null) {
      params['toYear'] = toYear;
    }

    return _get('getAlbumList2', params: params);
  }

  Future<Map<String, dynamic>> getRandomSongs({int size = 20, String? genre}) {
    final params = <String, dynamic>{'size': size};
    if (genre != null) {
      params['genre'] = genre;
    }

    return _get('getRandomSongs', params: params);
  }

  Future<Map<String, dynamic>> getStarred2() => _get('getStarred2');

  Future<Map<String, dynamic>> getSimilarSongs2(String id, {int count = 50}) =>
      _get('getSimilarSongs2', params: {'id': id, 'count': count});

  Future<Map<String, dynamic>> getTopSongs(
    String artistName, {
    int count = 50,
  }) => _get('getTopSongs', params: {'artist': artistName, 'count': count});

  Future<Map<String, dynamic>> search3({
    required String query,
    int songCount = 20,
    int albumCount = 20,
    int artistCount = 20,
    int songOffset = 0,
    int albumOffset = 0,
    int artistOffset = 0,
  }) {
    return _get(
      'search3',
      params: {
        'query': query,
        'songCount': songCount,
        'albumCount': albumCount,
        'artistCount': artistCount,
        'songOffset': songOffset,
        'albumOffset': albumOffset,
        'artistOffset': artistOffset,
      },
    );
  }

  Future<Map<String, dynamic>> getPlaylists() => _get('getPlaylists');

  Future<Map<String, dynamic>> getPlaylist(String id) =>
      _get('getPlaylist', params: {'id': id});

  Future<void> createPlaylist({
    required String name,
    List<String>? songIds,
  }) async {
    final params = <String, dynamic>{'name': name};
    if (songIds != null && songIds.isNotEmpty) {
      params['songId'] = songIds;
    }

    await _get('createPlaylist', params: params);
  }

  Future<void> updatePlaylist({
    required String playlistId,
    String? name,
    List<String>? songIdsToAdd,
    List<int>? songIndexesToRemove,
  }) async {
    final params = <String, dynamic>{'playlistId': playlistId};
    if (name != null) {
      params['name'] = name;
    }
    if (songIdsToAdd != null && songIdsToAdd.isNotEmpty) {
      params['songIdToAdd'] = songIdsToAdd;
    }
    if (songIndexesToRemove != null && songIndexesToRemove.isNotEmpty) {
      params['songIndexToRemove'] = songIndexesToRemove;
    }

    await _get('updatePlaylist', params: params);
  }

  Future<void> deletePlaylist(String id) async {
    await _get('deletePlaylist', params: {'id': id});
  }

  String getStreamUrl(String songId, {int? maxBitRate, String? format}) {
    final queryParameters = <String, String>{
      ..._buildAuthParams(),
      'id': songId,
    };

    if (maxBitRate != null) {
      queryParameters['maxBitRate'] = '$maxBitRate';
    }
    if (format != null) {
      queryParameters['format'] = format;
    }

    return Uri.parse(
      '${_restBaseUrl}stream.view',
    ).replace(queryParameters: queryParameters).toString();
  }

  String getCoverArtUrl(String? coverArtId, {int size = 300}) {
    if (coverArtId == null || coverArtId.isEmpty) {
      return '';
    }

    final queryParameters = <String, String>{
      ..._buildAuthParams(),
      'id': coverArtId,
      'size': '$size',
    };

    return Uri.parse(
      '${_restBaseUrl}getCoverArt.view',
    ).replace(queryParameters: queryParameters).toString();
  }

  Future<Response> downloadSong(
    String id,
    String savePath, {
    CancelToken? cancelToken,
    void Function(int, int)? onProgress,
  }) async {
    try {
      return await _dio.download(
        'stream.view',
        savePath,
        queryParameters: {'id': id},
        cancelToken: cancelToken,
        onReceiveProgress: onProgress,
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<void> star({String? songId, String? albumId, String? artistId}) async {
    await _get(
      'star',
      params: _buildAnnotationParams(
        songId: songId,
        albumId: albumId,
        artistId: artistId,
      ),
    );
  }

  Future<void> unstar({
    String? songId,
    String? albumId,
    String? artistId,
  }) async {
    await _get(
      'unstar',
      params: _buildAnnotationParams(
        songId: songId,
        albumId: albumId,
        artistId: artistId,
      ),
    );
  }

  Future<void> scrobble(String songId, {bool submission = true}) async {
    await _get('scrobble', params: {'id': songId, 'submission': submission});
  }

  Future<Map<String, dynamic>?> getLyrics({
    String? artist,
    String? title,
  }) async {
    if ((artist == null || artist.isEmpty) &&
        (title == null || title.isEmpty)) {
      return null;
    }

    final params = <String, dynamic>{};
    if (artist != null && artist.isNotEmpty) {
      params['artist'] = artist;
    }
    if (title != null && title.isNotEmpty) {
      params['title'] = title;
    }

    final response = await _get('getLyrics', params: params);
    return response.payloadFor('lyrics');
  }

  Future<Map<String, dynamic>?> getLyricsBySongId(String songId) async {
    if (songId.isEmpty) {
      return null;
    }

    final response = await _get('getLyricsBySongId', params: {'id': songId});

    final payload = response.payloadFor('lyricsList');
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    final structuredLyrics = payload['structuredLyrics'];
    if (structuredLyrics is List && structuredLyrics.isNotEmpty) {
      final first = structuredLyrics.first;
      if (first is Map<String, dynamic>) {
        return first;
      }
      if (first is Map) {
        return Map<String, dynamic>.from(first);
      }
    }

    final lyrics = payload['lyrics'];
    if (lyrics is List && lyrics.isNotEmpty) {
      final first = lyrics.first;
      if (first is Map<String, dynamic>) {
        return first;
      }
      if (first is Map) {
        return Map<String, dynamic>.from(first);
      }
    }

    return null;
  }

  Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$endpoint.view',
        queryParameters: params,
      );
      final data = _asJsonMap(response.data);
      final subsonicResponse = data.subsonicResponseBody;

      if (subsonicResponse == null) {
        throw const ServerException('Invalid Subsonic response');
      }

      if (data.subsonicStatus != 'ok') {
        final error = data.subsonicErrorBody;
        throw ServerException(
          (error?['message'] as String?) ?? 'Subsonic request failed',
          code: error?['code'] as int?,
        );
      }

      return data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Map<String, dynamic> _buildAnnotationParams({
    String? songId,
    String? albumId,
    String? artistId,
  }) {
    if (songId == null && albumId == null && artistId == null) {
      throw ArgumentError('At least one annotation target must be provided.');
    }

    return {
      if (songId != null) 'id': songId,
      if (albumId != null) 'albumId': albumId,
      if (artistId != null) 'artistId': artistId,
    };
  }

  Map<String, String> _buildAuthParams() {
    final salt = _generateSalt();
    final token = md5.convert(utf8.encode('$password$salt')).toString();

    return {
      'u': username,
      't': token,
      's': salt,
      'v': '1.16.1',
      'c': AppBranding.clientId,
      'f': 'json',
    };
  }

  String _generateSalt() {
    return List.generate(
      12,
      (_) => _saltCharacters[_random.nextInt(_saltCharacters.length)],
    ).join();
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return const NetworkException('Connection timeout');
    }

    if (error.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('Receive timeout');
    }

    if (error.error is SocketException) {
      return const NetworkException('Network connectivity issue');
    }

    // SSL/TLS 证书错误（自签名、过期等）
    if (error.error is HandshakeException) {
      return const NetworkException('SSL certificate error');
    }

    final responseData = error.response?.data;
    if (responseData is Map) {
      final errorBody = responseData.cast<String, dynamic>().subsonicErrorBody;
      if (errorBody != null) {
        return ServerException(
          (errorBody['message'] as String?) ?? 'Subsonic request failed',
          code: errorBody['code'] as int?,
        );
      }
    }

    return ServerException(
      error.message ?? 'Unexpected server error',
      code: error.response?.statusCode,
    );
  }

  /// 规范化 URL：去除尾部斜杠，自动去除用户误加的 /rest 后缀
  static String _normalizeBaseUrl(String baseUrl) {
    var url = baseUrl.trim();
    // 去除尾部斜杠
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    // 去除用户误加的 /rest 后缀（app 会自动拼接 /rest）
    if (url.endsWith('/rest')) {
      url = url.substring(0, url.length - 5);
    }
    return url;
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.cast<String, dynamic>();
    }

    throw const ServerException('Invalid response payload');
  }
}
