// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DownloadTask _$DownloadTaskFromJson(Map<String, dynamic> json) =>
    _DownloadTask(
      id: json['id'] as String,
      songId: json['songId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      status: $enumDecode(_$DownloadStatusEnumMap, json['status']),
      progress: (json['progress'] as num).toDouble(),
      localPath: json['localPath'] as String?,
      totalBytes: (json['totalBytes'] as num?)?.toInt(),
      downloadedBytes: (json['downloadedBytes'] as num?)?.toInt(),
      startedAt:
          json['startedAt'] == null
              ? null
              : DateTime.parse(json['startedAt'] as String),
      completedAt:
          json['completedAt'] == null
              ? null
              : DateTime.parse(json['completedAt'] as String),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$DownloadTaskToJson(_DownloadTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'songId': instance.songId,
      'title': instance.title,
      'artist': instance.artist,
      'status': _$DownloadStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'localPath': instance.localPath,
      'totalBytes': instance.totalBytes,
      'downloadedBytes': instance.downloadedBytes,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'error': instance.error,
    };

const _$DownloadStatusEnumMap = {
  DownloadStatus.pending: 'pending',
  DownloadStatus.downloading: 'downloading',
  DownloadStatus.paused: 'paused',
  DownloadStatus.completed: 'completed',
  DownloadStatus.failed: 'failed',
};
