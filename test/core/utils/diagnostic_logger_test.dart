import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';

void main() {
  group('DiagnosticEventFormatter', () {
    const formatter = DiagnosticEventFormatter();

    test('formats structured diagnostic events as json payloads', () {
      final message = formatter.format(
        category: 'player',
        action: 'recover',
        fields: {
          'index': 2,
          'position': const Duration(seconds: 12),
          'time': DateTime.parse('2026-04-15T01:02:03Z'),
        },
      );

      expect(message, startsWith('[EVENT] '));
      final payload =
          jsonDecode(message.substring('[EVENT] '.length))
              as Map<String, Object?>;

      expect(payload['category'], 'player');
      expect(payload['action'], 'recover');
      expect(payload['fields'], isA<Map<String, Object?>>());
      final fields = payload['fields']! as Map<String, Object?>;
      expect(fields['index'], 2);
      expect(fields['position'], 12000);
      expect(fields['time'], '2026-04-15T01:02:03.000Z');
    });

    test('redacts sensitive field names recursively', () {
      final message = formatter.format(
        category: 'auth',
        action: 'login_failed',
        fields: {
          'password': 'plain-text',
          'nested': {'accessToken': 'token-value', 'safe': 'visible'},
        },
      );

      final payload =
          jsonDecode(message.substring('[EVENT] '.length))
              as Map<String, Object?>;
      final fields = payload['fields']! as Map<String, Object?>;
      final nested = fields['nested']! as Map<String, Object?>;

      expect(fields['password'], '<redacted>');
      expect(nested['accessToken'], '<redacted>');
      expect(nested['safe'], 'visible');
    });
  });
}
