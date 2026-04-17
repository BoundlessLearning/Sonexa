import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';

class AudioDiagnostics {
  const AudioDiagnostics();

  static final DiagnosticModuleLogger _logger = DiagnosticLogger.instance
      .module('audio');

  void log(String message, {Object? error, StackTrace? stackTrace}) {
    if (message.startsWith('[DIAG][')) {
      unawaited(DiagnosticLogger.instance.log(message));
    } else {
      unawaited(_logger.log(message));
    }
    if (error != null || stackTrace != null) {
      unawaited(
        _logger.error(
          'audio diagnostics',
          error ?? 'unknown error',
          stackTrace: stackTrace,
        ),
      );
    }
    if (stackTrace != null) {
      debugPrintStack(
        label: '[DIAG][AUDIO] stackTrace',
        stackTrace: stackTrace,
      );
    }
  }

  String describeStream(MediaItem item) {
    final songId = _songIdOf(item);
    final source = item.id;
    final uri = Uri.tryParse(source);
    final isLocal = item.extras?['isLocal'] == true;
    final format = uri?.queryParameters['format'] ?? '<raw>';
    final maxBitRate = uri?.queryParameters['maxBitRate'] ?? '<none>';
    final host = uri?.host.isNotEmpty == true ? uri!.host : '<local>';
    final path = uri?.path ?? source;

    return 'songId=$songId, title="${item.title}", '
        'isLocal=$isLocal, host=$host, path=$path, '
        'format=$format, maxBitRate=$maxBitRate';
  }

  String _songIdOf(MediaItem item) =>
      item.extras?['songId'] as String? ?? item.id;
}
