import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ohmymusic/core/audio/audio_handler.dart';
import 'package:ohmymusic/core/database/app_database.dart';
import 'package:ohmymusic/core/utils/image_cache_config.dart';
import 'package:ohmymusic/features/auth/data/repositories/auth_repository.dart';
import 'package:ohmymusic/features/auth/presentation/providers/auth_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';
import 'package:ohmymusic/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ImageCacheConfig.configure();

  // Linux/Windows 需要 media_kit 后端来支持 just_audio
  if (Platform.isLinux || Platform.isWindows) {
    // 确保 MPV 磁盘缓存目录存在，避免 lavf "No cache data directory" 错误。
    // media_kit 默认启用 cache-on-disk 但不设置 cache-dir，
    // 需要预先创建目录供 MPV 使用。
    try {
      final cacheDir = await getTemporaryDirectory();
      final mpvCacheDir = Directory('${cacheDir.path}/mpv_cache');
      if (!mpvCacheDir.existsSync()) {
        mpvCacheDir.createSync(recursive: true);
      }
    } catch (_) {
      // 缓存目录创建失败不影响播放功能，仅会产生控制台警告
    }

    // 优先使用与可执行文件同目录下 lib/ 中的 libmpv（打包分发场景）
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final bundledMpv = '$exeDir/lib/libmpv.so';
    if (File(bundledMpv).existsSync()) {
      JustAudioMediaKit.ensureInitialized(libmpv: bundledMpv);
    } else {
      // 回退到系统安装的 libmpv
      JustAudioMediaKit.ensureInitialized();
    }
  }

  // 初始化数据库
  final database = AppDatabase();

  // 预加载已保存的活跃服务器配置，避免 FutureProvider 异步加载时路由重定向到登录页
  final authRepo = AuthRepository(database);
  final savedServer = await authRepo.getActiveServer();

  // 初始化音频服务
  final audioHandler = await AudioService.init(
    builder: () => MusicAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ohmymusic.audio',
      androidNotificationChannelName: 'OhMyMusic 音乐播放',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        audioHandlerProvider.overrideWithValue(audioHandler),
        // 用预加载的服务器配置覆盖 activeServerProvider，
        // Future.value 通过微任务交付结果，首帧仍为 AsyncLoading；
        // 下游 FutureProvider 使用 .future 等待加载完成
        activeServerProvider.overrideWith(
          (_) => Future.value(savedServer),
        ),
      ],
      child: const OhMyMusicApp(),
    ),
  );
}
