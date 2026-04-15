import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';

class AudioDiagnostics {
  const AudioDiagnostics();

  void log(String message, {Object? error, StackTrace? stackTrace}) {
    unawaited(DiagnosticLogger.instance.log(message));
    if (error != null) {
      unawaited(DiagnosticLogger.instance.log('[DIAG] error=$error'));
    }
    if (stackTrace != null) {
      debugPrintStack(label: '[DIAG] stackTrace', stackTrace: stackTrace);
      unawaited(DiagnosticLogger.instance.log('[DIAG] stackTrace=$stackTrace'));
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
