import 'dart:convert';

import 'package:dio/dio.dart';

class NavidromeNativeLyricsClient {
  NavidromeNativeLyricsClient({
    required String baseUrl,
    required String username,
    required String password,
  }) : _baseUrl = _normalizeBaseUrl(baseUrl),
       _username = username,
       _password = password;

  static const Duration _timeout = Duration(seconds: 3);
  static const String _authorizationHeader = 'X-ND-Authorization';

  final String _baseUrl;
  final String _username;
  final String _password;

  Future<List<Map<String, dynamic>>?> getStructuredLyrics(String songId) async {
    if (songId.trim().isEmpty) {
      return null;
    }

    final dio = Dio(
      BaseOptions(
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        responseType: ResponseType.json,
      ),
    );

    try {
      final token = await _login(dio);
      if (token == null || token.isEmpty) {
        return null;
      }

      final response = await dio.get<Map<String, dynamic>>(
        _uri(['api', 'song', songId]).toString(),
        options: Options(headers: {_authorizationHeader: 'Bearer $token'}),
      );
      final lyricsJson = response.data?['lyrics'];
      if (lyricsJson is! String || lyricsJson.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(lyricsJson);
      if (decoded is! List) {
        return null;
      }

      return decoded
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList(growable: false);
    } on DioException {
      return null;
    } on FormatException {
      return null;
    } finally {
      dio.close(force: true);
    }
  }

  Future<String?> _login(Dio dio) async {
    final response = await dio.post<Map<String, dynamic>>(
      _uri(['auth', 'login']).toString(),
      data: {'username': _username, 'password': _password},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return response.data?['token'] as String?;
  }

  Uri _uri(List<String> pathSegments) {
    final base = Uri.parse(_baseUrl);
    final segments = <String>[
      ...base.pathSegments.where((segment) => segment.isNotEmpty),
      ...pathSegments,
    ];

    return base.replace(pathSegments: segments, query: null);
  }

  static String _normalizeBaseUrl(String baseUrl) {
    var url = baseUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (url.endsWith('/rest')) {
      url = url.substring(0, url.length - 5);
    }
    return url;
  }
}
