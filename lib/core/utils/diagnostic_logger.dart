import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
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
  bool _enabled = false;
  Future<void> _pendingWrite = Future.value();
  final DiagnosticEventFormatter _eventFormatter =
      const DiagnosticEventFormatter();

  String? get logFilePath => _logFile?.path;
  bool get isEnabled => _enabled;

  Future<void> init({bool overwrite = true, bool enabled = true}) async {
    _enabled = enabled;
    if (!enabled) {
      return;
    }

    await _prepareLogFile(overwrite: overwrite);
  }

  Future<void> setEnabled(bool enabled, {bool overwrite = false}) async {
    _enabled = enabled;
    if (!enabled) {
      return;
    }

    await _prepareLogFile(overwrite: overwrite || _logFile == null);
  }

  Future<File?> exportLog({
    required String targetDirectoryPath,
    String? fileName,
  }) async {
    final sourceFile = await _resolveLogFile(createIfMissing: false);
    if (sourceFile == null || !sourceFile.existsSync()) {
      return null;
    }

    final targetDirectory = Directory(targetDirectoryPath);
    if (!targetDirectory.existsSync()) {
      targetDirectory.createSync(recursive: true);
    }

    final exportName =
        fileName ??
        'sonexa-diagnostic-${DateTime.now().millisecondsSinceEpoch}.log';
    final targetFile = File(p.join(targetDirectory.path, exportName));
    return sourceFile.copy(targetFile.path);
  }

  Future<void> _prepareLogFile({bool overwrite = true}) async {
    try {
      _logFile = await _resolveLogFile(createIfMissing: true);
      if (_logFile == null) {
        return;
      }
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

  Future<File?> _resolveLogFile({required bool createIfMissing}) async {
    final appDir = await getApplicationSupportDirectory();
    final logDir = Directory('${appDir.path}/logs');
    if (!logDir.existsSync()) {
      if (!createIfMissing) {
        return null;
      }
      logDir.createSync(recursive: true);
    }

    return File(p.join(logDir.path, 'diagnostic.log'));
  }

  Future<void> log(String message) async {
    if (!_enabled) {
      return;
    }
    stdout.writeln(message);
    await _writeLine('${DateTime.now().toIso8601String()} $message');
  }

  Future<void> logEvent(
    String category,
    String action, {
    Map<String, Object?> fields = const {},
  }) {
    return log(
      _eventFormatter.format(
        category: category,
        action: action,
        fields: fields,
      ),
    );
  }

  Future<void> captureConsoleLine(String line) async {
    if (!_enabled) {
      return;
    }
    final message = '${DateTime.now().toIso8601String()} $line';
    await _writeLine(message);
  }

  Future<void> _writeLine(String message) async {
    final file = _logFile;
    if (file == null) {
      return;
    }

    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await file.writeAsString(
          '$message\n',
          mode: FileMode.append,
          flush: true,
        );
      } catch (error, stackTrace) {
        stderr.writeln('[DIAG] logger write failed: $error');
        stderr.writeln(stackTrace);
      }
    });

    await _pendingWrite;
  }
}

class DiagnosticEventFormatter {
  const DiagnosticEventFormatter();

  String format({
    required String category,
    required String action,
    Map<String, Object?> fields = const {},
  }) {
    final payload = <String, Object?>{
      'category': category,
      'action': action,
      'fields': _sanitizeFields(fields),
    };
    return '[EVENT] ${jsonEncode(payload)}';
  }

  Map<String, Object?> _sanitizeFields(Map<String, Object?> fields) {
    return fields.map((key, value) {
      if (_isSensitiveKey(key)) {
        return MapEntry(key, '<redacted>');
      }
      return MapEntry(key, _toJsonValue(value));
    });
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('password') ||
        normalized.contains('token') ||
        normalized.contains('secret') ||
        normalized.contains('authorization') ||
        normalized.contains('salt');
  }

  Object? _toJsonValue(Object? value) {
    return switch (value) {
      null => null,
      String() || num() || bool() => value,
      DateTime() => value.toIso8601String(),
      Duration() => value.inMilliseconds,
      Map() => value.map(
        (key, nestedValue) => MapEntry(
          key.toString(),
          _isSensitiveKey(key.toString())
              ? '<redacted>'
              : _toJsonValue(nestedValue),
        ),
      ),
      Iterable() => value.map(_toJsonValue).toList(),
      _ => value.toString(),
    };
  }
}
