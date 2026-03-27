import 'dart:io';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 3});

  static const _attemptHeader = 'x-retry-attempt';

  final Dio _dio;
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final attempt = _parseAttempt(err.requestOptions.headers[_attemptHeader]);
    if (attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(Duration(seconds: (attempt + 1) * 2));

    final headers = Map<String, dynamic>.from(err.requestOptions.headers)
      ..[_attemptHeader] = attempt + 1;

    final requestOptions = err.requestOptions.copyWith(headers: headers);

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.error is SocketException;
  }

  int _parseAttempt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}
