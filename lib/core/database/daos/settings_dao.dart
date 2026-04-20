import 'package:drift/drift.dart';

import '../app_database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings, ServerConfigs])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getSetting(String key) async {
    final setting =
        await (select(appSettings)
          ..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return setting?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<ServerConfig?> getActiveServer() {
    return (select(serverConfigs)
      ..where((tbl) => tbl.isActive.equals(true))).getSingleOrNull();
  }

  Future<List<ServerConfig>> getAllServers() => select(serverConfigs).get();

  Future<void> insertServer(ServerConfigsCompanion server) async {
    await into(serverConfigs).insertOnConflictUpdate(server);
  }

  Future<void> setActiveServer(String id) async {
    await transaction(() async {
      await update(
        serverConfigs,
      ).write(const ServerConfigsCompanion(isActive: Value(false)));
      await (update(serverConfigs)..where(
        (tbl) => tbl.id.equals(id),
      )).write(const ServerConfigsCompanion(isActive: Value(true)));
    });
  }

  Future<int> deleteServer(String id) {
    return (delete(serverConfigs)..where((tbl) => tbl.id.equals(id))).go();
  }
}
