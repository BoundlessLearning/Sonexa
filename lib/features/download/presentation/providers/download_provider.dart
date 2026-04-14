import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sonexa/core/constants/app_branding.dart';
import 'package:sonexa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sonexa/features/download/data/download_dao.dart';
import 'package:sonexa/features/download/data/download_manager.dart';
import 'package:sonexa/features/download/domain/entities/download_task.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';

class DownloadDirectoryInfo {
  const DownloadDirectoryInfo({
    required this.path,
    required this.isPublic,
    required this.label,
  });

  final String path;
  final bool isPublic;
  final String label;
}

final downloadDirectoryInfoProvider = FutureProvider<DownloadDirectoryInfo>((
  ref,
) async {
  final publicDirectory = await _resolvePublicDownloadDirectory();
  if (publicDirectory != null) {
    return DownloadDirectoryInfo(
      path: publicDirectory,
      isPublic: true,
      label: '公开下载目录',
    );
  }

  final documentsDirectory = await getApplicationDocumentsDirectory();
  return DownloadDirectoryInfo(
    path: p.join(documentsDirectory.path, 'downloads'),
    isPublic: false,
    label: '应用私有目录',
  );
});

final downloadManagerProvider = FutureProvider<DownloadManager>((ref) async {
  final apiClient = await ref.watch(subsonicApiClientProvider.future);
  final database = ref.read(databaseProvider);
  final directoryInfo = await ref.watch(downloadDirectoryInfoProvider.future);

  final manager = DownloadManager(apiClient, database, directoryInfo.path);
  ref.onDispose(() {
    manager.dispose();
  });
  return manager;
});

final downloadListProvider = StreamProvider<List<DownloadTask>>((ref) async* {
  final manager = await ref.watch(downloadManagerProvider.future);
  yield* manager.watchDownloads();
});

final isDownloadedProvider = Provider.family<bool, String>((ref, songId) {
  final tasks =
      ref.watch(downloadListProvider).valueOrNull ?? const <DownloadTask>[];
  return tasks.any(
    (task) =>
        task.songId == songId &&
        task.status == DownloadStatus.completed &&
        task.localPath != null &&
        task.localPath!.isNotEmpty,
  );
});

final downloadedSongPathProvider = FutureProvider.family<String?, String>((
  ref,
  songId,
) async {
  final database = ref.read(databaseProvider);
  final dao = DownloadDao(database);
  final download = await dao.getDownloadBySongId(songId);
  if (download == null ||
      download.status != DownloadStatus.completed.name ||
      download.localPath.isEmpty) {
    return null;
  }

  final file = File(download.localPath);
  if (!await file.exists()) {
    return null;
  }

  final fileSize = await file.length();
  return fileSize > 0 ? download.localPath : null;
});

final downloadProgressProvider = Provider.family<double?, String>((ref, taskId) {
  final tasks =
      ref.watch(downloadListProvider).valueOrNull ?? const <DownloadTask>[];
  final task = tasks.where((item) => item.id == taskId).firstOrNull;
  return task?.progress;
});

Future<String?> _resolvePublicDownloadDirectory() async {
  try {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) {
        return null;
      }
      final path = p.join(
        downloadsDirectory.path,
        AppBranding.downloadFolderName,
      );
      return await _ensureDirectoryWritable(path) ? path : null;
    }

    if (Platform.isAndroid) {
      const candidates = <String>[
        '/storage/emulated/0/Download/${AppBranding.downloadFolderName}',
        '/sdcard/Download/${AppBranding.downloadFolderName}',
      ];

      for (final candidate in candidates) {
        if (await _ensureDirectoryWritable(candidate)) {
          return candidate;
        }
      }
    }
  } catch (_) {
    return null;
  }

  return null;
}

Future<bool> _ensureDirectoryWritable(String path) async {
  try {
    final directory = Directory(path);
    await directory.create(recursive: true);

    final probeFile = File(
      p.join(directory.path, '.sonexa_write_test'),
    );
    await probeFile.writeAsString('ok', flush: true);
    if (await probeFile.exists()) {
      await probeFile.delete();
    }
    return true;
  } catch (_) {
    return false;
  }
}
