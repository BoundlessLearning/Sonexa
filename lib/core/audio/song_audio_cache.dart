import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:crypto/crypto.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SongAudioCache {
  SongAudioCache._();

  static final SongAudioCache instance = SongAudioCache._();
  static const _cacheFolderName = 'song_audio_cache';

  Directory? _cacheDirectory;
  Future<Directory>? _pendingInitialization;

  Future<void> ensureInitialized() async {
    await _resolveCacheDirectory();
  }

  bool get isInitialized => _cacheDirectory != null;

  AudioSource buildAudioSource(MediaItem item) {
    final uri = Uri.parse(item.id);
    final cacheFile = _cacheFileForItem(item);
    if (cacheFile == null) {
      return AudioSource.uri(uri, tag: item);
    }

    if (_isUsableCacheFile(cacheFile)) {
      return AudioSource.uri(Uri.file(cacheFile.path), tag: item);
    }

    // ignore: experimental_member_use
    return LockCachingAudioSource(uri, cacheFile: cacheFile, tag: item);
  }

  Future<int> usageBytes() async {
    final directory = await _resolveCacheDirectory();
    return _directorySize(directory);
  }

  Future<void> clear() async {
    final directory = await _resolveCacheDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      return;
    }

    await for (final entity in directory.list(followLinks: false)) {
      try {
        await entity.delete(recursive: true);
      } catch (_) {
        // 某些平台上正在播放的缓存文件可能被占用，忽略单个失败项。
      }
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<Directory> _resolveCacheDirectory() {
    if (_cacheDirectory != null) {
      return Future.value(_cacheDirectory!);
    }

    final pending = _pendingInitialization;
    if (pending != null) {
      return pending;
    }

    final future = _createCacheDirectory();
    _pendingInitialization = future;
    return future.whenComplete(() {
      if (identical(_pendingInitialization, future)) {
        _pendingInitialization = null;
      }
    });
  }

  Future<Directory> _createCacheDirectory() async {
    final baseDirectory = await getTemporaryDirectory();
    final directory = Directory(p.join(baseDirectory.path, _cacheFolderName));
    await directory.create(recursive: true);
    _cacheDirectory = directory;
    return directory;
  }

  File? _cacheFileForItem(MediaItem item) {
    final directory = _cacheDirectory;
    if (directory == null || item.extras?['isLocal'] == true) {
      return null;
    }

    final songId = (item.extras?['songId'] as String?)?.trim();
    final cacheKey = _cacheKey(item, songId);
    final extension = _fileExtensionFor(item);
    return File(p.join(directory.path, '$cacheKey.$extension'));
  }

  String _cacheKey(MediaItem item, String? songId) {
    final variant = _cacheVariant(item);
    final sourceId = (songId == null || songId.isEmpty) ? item.id : songId;
    return sha1.convert('$sourceId|$variant'.codeUnits).toString();
  }

  String _cacheVariant(MediaItem item) {
    final extras = item.extras;
    final fallbackFormat = (extras?['fallbackFormat'] as String?)?.trim();
    if (fallbackFormat != null &&
        fallbackFormat.isNotEmpty &&
        fallbackFormat != 'raw') {
      return fallbackFormat.toLowerCase();
    }

    final streamFormat = (extras?['streamFormat'] as String?)?.trim();
    if (streamFormat != null &&
        streamFormat.isNotEmpty &&
        streamFormat != 'raw') {
      return streamFormat.toLowerCase();
    }

    final sourceSuffix = (extras?['sourceSuffix'] as String?)?.trim();
    if (sourceSuffix != null && sourceSuffix.isNotEmpty) {
      return sourceSuffix.toLowerCase();
    }

    final uri = Uri.tryParse(item.id);
    final uriExtension = p.extension(uri?.path ?? '').replaceFirst('.', '');
    if (uriExtension.isNotEmpty) {
      return uriExtension.toLowerCase();
    }

    return 'audio';
  }

  String _fileExtensionFor(MediaItem item) {
    final variant = _cacheVariant(item);
    return variant == 'raw' ? 'audio' : variant;
  }

  bool _isUsableCacheFile(File file) {
    try {
      return file.existsSync() && file.lengthSync() > 0;
    } catch (_) {
      return false;
    }
  }

  Future<int> _directorySize(Directory directory) async {
    if (!await directory.exists()) {
      return 0;
    }

    var total = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is! File) {
        continue;
      }
      try {
        total += await entity.length();
      } catch (_) {
        // 文件可能被系统回收或占用，跳过即可。
      }
    }
    return total;
  }
}
