import 'dart:async';
import 'dart:io';

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

  Future<void> init({bool overwrite = true}) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final logDir = Directory('${appDir.path}/logs');
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }

      _logFile = File('${logDir.path}/diagnostic.log');
      if (overwrite && _logFile!.existsSync()) {
        _logFile!.writeAsStringSync('');
      } else if (!_logFile!.existsSync()) {
        _logFile!.createSync(recursive: true);
      }
    } catch (error, stackTrace) {
      stderr.writeln('[DIAG] logger init failed: $error');
      stderr.writeln(stackTrace);
    }
  }

  Future<void> log(String message) async {
    print(message);
  }

  Future<void> captureConsoleLine(String line) async {
    final message = '${DateTime.now().toIso8601String()} $line';

    final file = _logFile;
    if (file == null) {
      return;
    }

    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await file.writeAsString('$message\n',
            mode: FileMode.append, flush: true);
      } catch (error, stackTrace) {
        stderr.writeln('[DIAG] logger write failed: $error');
        stderr.writeln(stackTrace);
      }
    });

    await _pendingWrite;
  }
}
