import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_task.freezed.dart';
part 'download_task.g.dart';

enum DownloadStatus { pending, downloading, paused, completed, failed }

@freezed
abstract class DownloadTask with _$DownloadTask {
  const factory DownloadTask({
    required String id,
    required String songId,
    required String title,
    required String artist,
    required DownloadStatus status,
    required double progress,
    String? localPath,
    int? totalBytes,
    int? downloadedBytes,
    DateTime? startedAt,
    DateTime? completedAt,
    String? error,
  }) = _DownloadTask;

  factory DownloadTask.fromJson(Map<String, dynamic> json) => _$DownloadTaskFromJson(json);
}
