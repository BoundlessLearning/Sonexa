import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/core/error/app_error.dart';
import 'package:sonexa/core/localization/app_localizations.dart';

void main() {
  group('AppError', () {
    test('restores errors from stable storage values', () {
      final error = AppError.fromStorageValue('download.cancelled');

      expect(error?.code, AppErrorCode.downloadCancelled);
      expect(error?.storageValue, 'download.cancelled');
    });

    test('returns null for unknown storage values', () {
      expect(AppError.fromStorageValue('legacy raw error'), isNull);
    });

    test('localizes known errors', () {
      final zh = AppLocalizations(const Locale('zh'));
      final en = AppLocalizations(const Locale('en'));

      expect(
        zh.appErrorMessage(const AppError(AppErrorCode.downloadCancelled)),
        '下载已取消',
      );
      expect(
        en.appErrorMessage(const AppError(AppErrorCode.downloadCancelled)),
        'Download cancelled',
      );
    });

    test('keeps raw legacy download errors as fallback', () {
      final l10n = AppLocalizations(const Locale('en'));

      expect(
        l10n.errorMessageFromStorageValue('SocketException: failed'),
        'SocketException: failed',
      );
    });
  });
}
