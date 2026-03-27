import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:ohmymusic/core/database/app_database.dart';
import 'package:ohmymusic/core/network/subsonic_api_client.dart';
import 'package:ohmymusic/features/download/data/download_dao.dart';
import 'package:ohmymusic/features/download/domain/entities/download_task.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';

class DownloadManager {
  DownloadManager(this._apiClient, this._db, this._baseDownloadDirectory)
    : _dao = DownloadDao(_db) {
    _downloadsSubscription = _dao.watchAllDownloads().listen((downloads) {
      _latestDownloads = downloads;
      _scheduleEmit();
    });
  }

  static const int _maxConcurrentDownloads = 3;
  static const Uuid _uuid = Uuid();

  final SubsonicApiClient _apiClient;
  final AppDatabase _db;
  final String _baseDownloadDirectory;
  final DownloadDao _dao;

  final Queue<_QueuedDownload> _pendingQueue = ListQueue<_QueuedDownload>();
  final Map<String, CancelToken> _activeTokens = <String, CancelToken>{};
  final Map<String, Future<void>> _runningTasks = <String, Future<void>>{};
  final Map<String, _ProgressSnapshot> _progressByTaskId =
      <String, _ProgressSnapshot>{};
  final Map<String, String> _errorByTaskId = <String, String>{};
  final Map<String, Song> _songCache = <String, Song>{};
  final Set<String> _deleteRequestedTaskIds = <String>{};
  final StreamController<List<DownloadTask>> _downloadsController =
      StreamController<List<DownloadTask>>.broadcast();

  StreamSubscription<List<Download>>? _downloadsSubscription;
  List<Download> _latestDownloads = <Download>[];
  Future<void> _emitQueue = Future<void>.value();
  bool _isDisposed = false;

  Future<void> enqueueDownload(Song song) async {
    _songCache[song.id] = song;

    final existingDownload = await _dao.getDownloadBySongId(song.id);
    if (existingDownload != null) {
      if (existingDownload.status == DownloadStatus.completed.name &&
          existingDownload.localPath.isNotEmpty &&
          await File(existingDownload.localPath).exists()) {
        return;
      }

      if (existingDownload.status == DownloadStatus.pending.name ||
          existingDownload.status == DownloadStatus.downloading.name) {
        return;
      }

      await _removeFileIfExists(existingDownload.localPath);
      await _clearSongLocalPath(song.id);
      await _queueDownload(song: song, taskId: existingDownload.id);
      return;
    }

    await _queueDownload(song: song, taskId: _uuid.v4());
  }

  void cancel(String taskId) => cancelDownload(taskId);

  Future<void> delete(String taskId) => deleteDownload(taskId);

  Future<void> retry(String taskId) => retryDownload(taskId);

  Future<void> resume(String taskId) => retryDownload(taskId);

  Future<void> deleteAll() async {
    final queuedTaskIds = _pendingQueue.map((task) => task.taskId);
    final activeTaskIds = _activeTokens.keys;
    final persistedTaskIds = _latestDownloads.map((task) => task.id);
    final taskIds = <String>{
      ...queuedTaskIds,
      ...activeTaskIds,
      ...persistedTaskIds,
    };

    for (final taskId in taskIds) {
      await deleteDownload(taskId);
    }
  }

  void cancelDownload(String taskId) {
    final queuedTask = _pendingQueue.firstWhereOrNull(
      (task) => task.taskId == taskId,
    );
    if (queuedTask != null) {
      _pendingQueue.remove(queuedTask);
      _progressByTaskId.remove(taskId);
      _errorByTaskId[taskId] = '下载已取消';
      unawaited(_markDownloadFailed(taskId, queuedTask.song.id, '下载已取消'));
      _scheduleEmit();
      return;
    }

    final token = _activeTokens[taskId];
    if (token == null) return;

    _progressByTaskId[taskId] = _progressByTaskId[taskId]?.copyWith(
          status: DownloadStatus.failed,
        ) ??
        const _ProgressSnapshot(status: DownloadStatus.failed);
    _errorByTaskId[taskId] = '下载已取消';
    token.cancel('Download cancelled');
    unawaited(_dao.updateDownloadStatus(taskId, DownloadStatus.failed.name));
    _scheduleEmit();
  }

  void cancelAllDownloads() {
    final queuedTasks = _pendingQueue.toList(growable: false);
    for (final task in queuedTasks) {
      cancelDownload(task.taskId);
    }

    final activeTaskIds = _activeTokens.keys.toList(growable: false);
    for (final taskId in activeTaskIds) {
      cancelDownload(taskId);
    }
  }

  Stream<List<DownloadTask>> watchDownloads() async* {
    yield await _buildDownloadTasks();
    yield* _downloadsController.stream;
  }

  Future<void> deleteDownload(String taskId) async {
    final queuedTask = _pendingQueue.firstWhereOrNull(
      (task) => task.taskId == taskId,
    );
    if (queuedTask != null) {
      _pendingQueue.remove(queuedTask);
      await _dao.deleteDownload(taskId);
      await _clearSongLocalPath(queuedTask.song.id);
      _progressByTaskId.remove(taskId);
      _errorByTaskId.remove(taskId);
      _scheduleEmit();
      return;
    }

    final token = _activeTokens[taskId];
    if (token != null) {
      _deleteRequestedTaskIds.add(taskId);
      token.cancel('Download deleted');
      await _runningTasks[taskId];
      _deleteRequestedTaskIds.remove(taskId);
    }

    final row = _latestDownloads.firstWhereOrNull((download) => download.id == taskId);
    if (row == null) {
      await _dao.deleteDownload(taskId);
      _progressByTaskId.remove(taskId);
      _errorByTaskId.remove(taskId);
      _scheduleEmit();
      return;
    }

    await _removeFileIfExists(row.localPath);
    await _clearSongLocalPath(row.songId);
    await _dao.deleteDownload(taskId);
    _progressByTaskId.remove(taskId);
    _errorByTaskId.remove(taskId);
    _scheduleEmit();
  }

  Future<void> retryDownload(String taskId) async {
    if (_activeTokens.containsKey(taskId) ||
        _pendingQueue.any((task) => task.taskId == taskId)) {
      return;
    }

    final row = _latestDownloads.firstWhereOrNull((download) => download.id == taskId);
    if (row == null || row.status != DownloadStatus.failed.name) {
      return;
    }

    final song = await _getSongById(row.songId);
    if (song == null) {
      throw StateError('Song not found for download retry: ${row.songId}');
    }

    await _removeFileIfExists(row.localPath);
    await _clearSongLocalPath(row.songId);
    _errorByTaskId.remove(taskId);
    await _queueDownload(song: song, taskId: taskId);
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    cancelAllDownloads();
    await _downloadsSubscription?.cancel();
    await _downloadsController.close();
  }

  Future<void> _queueDownload({required Song song, required String taskId}) async {
    final now = DateTime.now();
    _progressByTaskId[taskId] = const _ProgressSnapshot(
      status: DownloadStatus.pending,
      progress: 0,
    );

    await _dao.insertDownload(
      DownloadsCompanion.insert(
        id: taskId,
        songId: song.id,
        localPath: '',
        fileSize: 0,
        status: DownloadStatus.pending.name,
        downloadedAt: now,
      ),
    );

    _pendingQueue.add(_QueuedDownload(taskId: taskId, song: song));
    _scheduleEmit();
    _tryStartNextDownloads();
  }

  void _tryStartNextDownloads() {
    while (_activeTokens.length < _maxConcurrentDownloads && _pendingQueue.isNotEmpty) {
      final nextTask = _pendingQueue.removeFirst();
      final future = _startDownload(nextTask);
      _runningTasks[nextTask.taskId] = future;
      unawaited(
        future.whenComplete(() {
          _runningTasks.remove(nextTask.taskId);
        }),
      );
    }
  }

  Future<void> _startDownload(_QueuedDownload queuedDownload) async {
    final taskId = queuedDownload.taskId;
    final song = queuedDownload.song;
    final cancelToken = CancelToken();
    _activeTokens[taskId] = cancelToken;
    _progressByTaskId[taskId] = const _ProgressSnapshot(
      status: DownloadStatus.downloading,
      progress: 0,
    );
    await _dao.updateDownloadStatus(taskId, DownloadStatus.downloading.name);
    _scheduleEmit();

    final downloadDirectoryPath = await _resolveDownloadDirectory();
    final filePath = p.join(
      downloadDirectoryPath,
      '${song.id}_${_sanitizeFileName(song.title)}.${_resolveFileSuffix(song.suffix)}',
    );

    try {
      await Directory(downloadDirectoryPath).create(recursive: true);

      await _apiClient.downloadSong(
        song.id,
        filePath,
        cancelToken: cancelToken,
        onProgress: (received, total) {
          if (cancelToken.isCancelled) {
            return;
          }

          final progress = total > 0 ? received / total : 0.0;
          _progressByTaskId[taskId] = _ProgressSnapshot(
            status: DownloadStatus.downloading,
            progress: progress.clamp(0, 1),
            downloadedBytes: received,
            totalBytes: total > 0 ? total : null,
          );
          _scheduleEmit();
        },
      );

      final file = File(filePath);
      final fileSize = await file.length();
      final completedAt = DateTime.now();

      await _db.transaction(() async {
        await _dao.insertDownload(
          DownloadsCompanion.insert(
            id: taskId,
            songId: song.id,
            localPath: filePath,
            fileSize: fileSize,
            status: DownloadStatus.completed.name,
            downloadedAt: completedAt,
          ),
        );

        await (_db.update(_db.cachedSongs)..where((tbl) => tbl.id.equals(song.id))).write(
          CachedSongsCompanion(localFilePath: Value(filePath)),
        );
      });

      _progressByTaskId[taskId] = _ProgressSnapshot(
        status: DownloadStatus.completed,
        progress: 1,
        downloadedBytes: fileSize,
        totalBytes: fileSize,
      );
      _errorByTaskId.remove(taskId);
      _scheduleEmit();
    } catch (error) {
      await _removeFileIfExists(filePath);
      if (_deleteRequestedTaskIds.contains(taskId)) {
        return;
      }

      final errorMessage = cancelToken.isCancelled ? '下载已取消' : error.toString();
      _errorByTaskId[taskId] = errorMessage;
      await _markDownloadFailed(taskId, song.id, errorMessage);
    } finally {
      _activeTokens.remove(taskId);
      _tryStartNextDownloads();
    }
  }

  Future<void> _markDownloadFailed(
    String taskId,
    String songId,
    String errorMessage,
  ) async {
    await _db.transaction(() async {
      await _dao.insertDownload(
        DownloadsCompanion.insert(
          id: taskId,
          songId: songId,
          localPath: '',
          fileSize: 0,
          status: DownloadStatus.failed.name,
          downloadedAt: DateTime.now(),
        ),
      );

      await (_db.update(_db.cachedSongs)..where((tbl) => tbl.id.equals(songId))).write(
        const CachedSongsCompanion(localFilePath: Value(null)),
      );
    });

    _progressByTaskId[taskId] = _progressByTaskId[taskId]?.copyWith(
          status: DownloadStatus.failed,
          progress: 0,
        ) ??
        const _ProgressSnapshot(status: DownloadStatus.failed);
    _errorByTaskId[taskId] = errorMessage;
    _scheduleEmit();
  }

  Future<Song?> _getSongById(String songId) async {
    final cachedSong = _songCache[songId];
    if (cachedSong != null) {
      return cachedSong;
    }

    final row = await (_db.select(_db.cachedSongs)..where((tbl) => tbl.id.equals(songId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }

    final song = Song(
      id: row.id,
      title: row.title,
      artist: row.artist,
      artistId: row.artistId,
      album: row.album,
      albumId: row.albumId,
      coverArtId: row.coverArtId,
      duration: row.duration,
      track: row.track,
      discNumber: row.discNumber,
      year: row.year,
      genre: row.genre,
      bitRate: row.bitRate,
      suffix: row.suffix,
      size: row.size,
      playCount: row.playCount,
      starred: row.starred,
      lastPlayed: row.lastPlayed,
      localFilePath: row.localFilePath,
    );
    _songCache[songId] = song;
    return song;
  }

  Future<void> _clearSongLocalPath(String songId) async {
    await (_db.update(_db.cachedSongs)..where((tbl) => tbl.id.equals(songId))).write(
      const CachedSongsCompanion(localFilePath: Value(null)),
    );
  }

  Future<String> _resolveDownloadDirectory() async {
    if (_baseDownloadDirectory.isNotEmpty) {
      return _baseDownloadDirectory;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    return p.join(documentsDirectory.path, 'downloads');
  }

  Future<void> _removeFileIfExists(String filePath) async {
    if (filePath.isEmpty) {
      return;
    }

    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void _scheduleEmit() {
    _emitQueue = _emitQueue.then((_) async {
      if (_isDisposed || _downloadsController.isClosed) {
        return;
      }

      final tasks = await _buildDownloadTasks();

      if (!_downloadsController.isClosed) {
        _downloadsController.add(tasks);
      }
    });
  }

  Future<List<DownloadTask>> _buildDownloadTasks() {
    return Future.wait(_latestDownloads.map(_mapDownloadToTask));
  }

  Future<DownloadTask> _mapDownloadToTask(Download download) async {
    final song = await _getSongById(download.songId);
    final progress = _progressByTaskId[download.id];
    final status = progress?.status ?? _parseStatus(download.status);

    return DownloadTask(
      id: download.id,
      songId: download.songId,
      title: song?.title ?? 'Unknown',
      artist: song?.artist ?? 'Unknown',
      status: status,
      progress: progress?.progress ?? (status == DownloadStatus.completed ? 1 : 0),
      localPath: download.localPath.isEmpty ? null : download.localPath,
      totalBytes: progress?.totalBytes ?? (download.fileSize > 0 ? download.fileSize : null),
      downloadedBytes: progress?.downloadedBytes ??
          (status == DownloadStatus.completed && download.fileSize > 0 ? download.fileSize : null),
      startedAt: download.downloadedAt,
      completedAt: status == DownloadStatus.completed ? download.downloadedAt : null,
      error: _errorByTaskId[download.id],
    );
  }

  DownloadStatus _parseStatus(String value) {
    return DownloadStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => DownloadStatus.failed,
    );
  }

  String _sanitizeFileName(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return sanitized.isEmpty ? 'song' : sanitized;
  }

  String _resolveFileSuffix(String? suffix) {
    final normalized = suffix?.trim().replaceFirst('.', '');
    return (normalized == null || normalized.isEmpty) ? 'mp3' : normalized;
  }
}

class _QueuedDownload {
  const _QueuedDownload({required this.taskId, required this.song});

  final String taskId;
  final Song song;
}

class _ProgressSnapshot {
  const _ProgressSnapshot({
    required this.status,
    this.progress = 0,
    this.downloadedBytes,
    this.totalBytes,
  });

  final DownloadStatus status;
  final double progress;
  final int? downloadedBytes;
  final int? totalBytes;

  _ProgressSnapshot copyWith({
    DownloadStatus? status,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
  }) {
    return _ProgressSnapshot(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }
}
