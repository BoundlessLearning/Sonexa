import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:ohmymusic/features/auth/presentation/providers/auth_provider.dart';
import 'package:ohmymusic/features/download/data/download_manager.dart';
import 'package:ohmymusic/features/download/domain/entities/download_task.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';

final _downloadDirectoryProvider = FutureProvider<String>((ref) async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  return p.join(documentsDirectory.path, 'downloads');
});

final downloadManagerProvider = FutureProvider<DownloadManager>((ref) async {
  final apiClient = await ref.watch(subsonicApiClientProvider.future);
  final database = ref.read(databaseProvider);
  final downloadDirectory =
      ref.watch(_downloadDirectoryProvider).valueOrNull ??
      p.join(Directory.systemTemp.path, 'ohmymusic_downloads');

  final manager = DownloadManager(apiClient, database, downloadDirectory);
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
  final tasks = ref.watch(downloadListProvider).valueOrNull ?? const <DownloadTask>[];
  return tasks.any(
    (task) => task.songId == songId && task.status == DownloadStatus.completed,
  );
});

final downloadProgressProvider = Provider.family<double?, String>((ref, taskId) {
  final tasks = ref.watch(downloadListProvider).valueOrNull ?? const <DownloadTask>[];
  final task = tasks.where((item) => item.id == taskId).firstOrNull;
  return task?.progress;
});
