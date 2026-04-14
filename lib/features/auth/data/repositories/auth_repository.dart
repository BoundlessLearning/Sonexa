import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:sonexa/core/database/app_database.dart';
import 'package:sonexa/core/network/dio_client.dart';
import 'package:sonexa/core/network/subsonic_api_client.dart';
import 'package:sonexa/features/auth/domain/entities/server_config.dart'
    as entity;

class AuthRepository {
  AuthRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// 登录并验证服务器连接。成功返回 null，失败返回具体错误信息。
  Future<String?> login(String baseUrl, String username, String password) async {
    final dio = createDioClient();
    final client = SubsonicApiClient(
      dio,
      baseUrl: baseUrl,
      username: username,
      password: password,
    );

    // ping() 会抛出具体的 AppException，这里直接让它传播
    await client.ping();

    // ping 成功，保存服务器配置
    final id = _uuid.v4();
    await _db.transaction(() async {
      await _db.update(_db.serverConfigs).write(
            const ServerConfigsCompanion(isActive: Value(false)),
          );

      await _db.into(_db.serverConfigs).insertOnConflictUpdate(
            ServerConfigsCompanion.insert(
              id: id,
              baseUrl: baseUrl,
              username: username,
              encryptedPassword: password,
              isActive: const Value(true),
              lastConnected: Value(DateTime.now()),
            ),
          );
    });

    return null;
  }

  Future<void> logout() async {
    await _db.update(_db.serverConfigs).write(
          const ServerConfigsCompanion(isActive: Value(false)),
        );
  }

  Future<entity.ServerConfig?> getActiveServer() async {
    final row = await (_db.select(_db.serverConfigs)
          ..where((tbl) => tbl.isActive.equals(true)))
        .getSingleOrNull();

    if (row == null) return null;
    return _toEntity(row);
  }

  Future<List<entity.ServerConfig>> getAllServers() async {
    final rows = await _db.select(_db.serverConfigs).get();
    return rows.map(_toEntity).toList();
  }

  Future<void> deleteServer(String id) async {
    await (_db.delete(_db.serverConfigs)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  entity.ServerConfig _toEntity(ServerConfig row) {
    return entity.ServerConfig(
      id: row.id,
      baseUrl: row.baseUrl,
      username: row.username,
      password: row.encryptedPassword,
      isActive: row.isActive,
      lastConnected: row.lastConnected,
    );
  }
}
