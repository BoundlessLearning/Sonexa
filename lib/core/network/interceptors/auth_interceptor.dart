import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'package:sonexa/core/constants/app_branding.dart';

class SubsonicAuthInterceptor extends Interceptor {
  SubsonicAuthInterceptor({
    required String baseUrl,
    required this.username,
    required this.password,
  }) : _baseUri = Uri.parse(baseUrl);

  static const _saltCharacters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const _authParamKeys = {'u', 't', 's', 'v', 'c', 'f'};

  final Uri _baseUri;
  final String username;
  final String password;
  final Random _random = Random.secure();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestUri = options.uri;
    final matchesBaseHost =
        !requestUri.hasScheme ||
        (requestUri.scheme == _baseUri.scheme &&
            requestUri.host == _baseUri.host &&
            requestUri.port == _baseUri.port);

    if (!matchesBaseHost) {
      handler.next(options);
      return;
    }

    final queryParameters = Map<String, dynamic>.from(options.queryParameters);
    final authParams = _buildAuthParams();

    for (final entry in authParams.entries) {
      if (_authParamKeys.contains(entry.key)) {
        queryParameters.putIfAbsent(entry.key, () => entry.value);
      }
    }

    handler.next(options.copyWith(queryParameters: queryParameters));
  }

  Map<String, String> _buildAuthParams() {
    final salt = _generateSalt();
    // Subsonic token auth uses md5(password + salt).
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
}
