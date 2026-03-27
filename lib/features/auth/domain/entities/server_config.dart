import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_config.freezed.dart';
part 'server_config.g.dart';

@freezed
abstract class ServerConfig with _$ServerConfig {
  const factory ServerConfig({
    required String id,
    required String baseUrl,
    required String username,
    required String password,
    @Default(false) bool isActive,
    DateTime? lastConnected,
  }) = _ServerConfig;

  factory ServerConfig.fromJson(Map<String, dynamic> json) => _$ServerConfigFromJson(json);
}
