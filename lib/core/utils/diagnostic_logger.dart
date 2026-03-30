import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 应用级诊断日志落盘工具。
///
/// 目标：
/// 1. 将关键用户操作与运行时诊断同时写入终端与本地文件
/// 2. 便于后续直接读取日志文件做 RCA，而不是依赖用户口述
class DiagnosticLogger {
  DiagnosticLogger._();

  static final DiagnosticLogger instance = DiagnosticLogger._();

  File? _logFile;
  Future<void> _pendingWrite = Future.value();

  String? get logFilePath => _logFile?.path;

  Future<void> init() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final logDir = Directory('${appDir.path}/logs');
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }

      _logFile = File('${logDir.path}/diagnostic.log');
      if (!_logFile!.existsSync()) {
        _logFile!.createSync(recursive: true);
      }

      await _rotateIfNeeded();
      await log('[DIAG] logger initialized: path=${_logFile!.path}');
    } catch (error, stackTrace) {
      debugPrint('[DIAG] logger init failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> log(String message) async {
    final line = '${DateTime.now().toIso8601String()} $message';
    debugPrint(message);

    final file = _logFile;
    if (file == null) {
      return;
    }

    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await _rotateIfNeeded();
        await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
      } catch (error, stackTrace) {
        debugPrint('[DIAG] logger write failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });

    await _pendingWrite;
  }

  Future<void> _rotateIfNeeded() async {
    final file = _logFile;
    if (file == null || !file.existsSync()) {
      return;
    }

    final length = await file.length();
    const maxBytes = 2 * 1024 * 1024;
    if (length < maxBytes) {
      return;
    }

    final backup = File('${file.path}.1');
    if (backup.existsSync()) {
      backup.deleteSync();
    }
    file.renameSync(backup.path);
    _logFile = File(file.path)..createSync(recursive: true);
  }
}
