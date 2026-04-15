import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/core/database/app_database.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(executor: NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('uses schema version 2 after server password field migration', () {
      expect(database.schemaVersion, 2);
    });

    test('stores server password without encryptedPassword API', () async {
      await database
          .into(database.serverConfigs)
          .insert(
            ServerConfigsCompanion.insert(
              id: 'server-1',
              baseUrl: 'https://music.example.test',
              username: 'alice',
              password: const Value('plain-password'),
            ),
          );

      final row = await database.select(database.serverConfigs).getSingle();

      expect(row.password, 'plain-password');
    });
  });
}
