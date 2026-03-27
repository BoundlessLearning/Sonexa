// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServerConfig _$ServerConfigFromJson(Map<String, dynamic> json) =>
    _ServerConfig(
      id: json['id'] as String,
      baseUrl: json['baseUrl'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      isActive: json['isActive'] as bool? ?? false,
      lastConnected:
          json['lastConnected'] == null
              ? null
              : DateTime.parse(json['lastConnected'] as String),
    );

Map<String, dynamic> _$ServerConfigToJson(_ServerConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'baseUrl': instance.baseUrl,
      'username': instance.username,
      'password': instance.password,
      'isActive': instance.isActive,
      'lastConnected': instance.lastConnected?.toIso8601String(),
    };
