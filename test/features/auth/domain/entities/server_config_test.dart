import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/features/auth/domain/entities/server_config.dart';

void main() {
  group('ServerConfig', () {
    test('does not include password in generated toString output', () {
      const config = ServerConfig(
        id: 'server-1',
        baseUrl: 'https://music.test',
        username: 'alice',
        password: 'plain-password',
        isActive: true,
      );

      expect(config.toString(), isNot(contains('plain-password')));
    });
  });
}
