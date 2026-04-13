import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ohmymusic/app.dart';
import 'package:ohmymusic/core/audio/audio_handler.dart';
import 'package:ohmymusic/core/audio/windows_media_controls.dart';
import 'package:ohmymusic/core/database/app_database.dart';
import 'package:ohmymusic/core/utils/diagnostic_logger.dart';
import 'package:ohmymusic/core/utils/image_cache_config.dart';
import 'package:ohmymusic/features/auth/presentation/providers/auth_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

class _BootstrapData {
  const _BootstrapData({
    required this.database,
    required this.audioHandler,
  });

  final AppDatabase database;
  final MusicAudioHandler audioHandler;
}

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      ImageCacheConfig.configure();
      await DiagnosticLogger.instance.init(overwrite: true);

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        final stack = details.stack?.toString() ?? '<no-stack>';
        unawaited(
          DiagnosticLogger.instance
              .log('[FLUTTER_ERROR] ${details.exceptionAsString()}\n$stack'),
        );
      };

      await DiagnosticLogger.instance.log(
        '[DIAG] logger initialized: path=${DiagnosticLogger.instance.logFilePath}',
      );

      if (Platform.isLinux || Platform.isWindows) {
        JustAudioMediaKit.mpvLogLevel = MPVLogLevel.error;
        JustAudioMediaKit.bufferSize = 64 * 1024 * 1024;

        try {
          final cacheDir = await getTemporaryDirectory();
          final mpvCacheDir = Directory('${cacheDir.path}/mpv_cache');
          if (!mpvCacheDir.existsSync()) {
            mpvCacheDir.createSync(recursive: true);
          }
        } catch (_) {
          // 缓存目录创建失败不影响播放功能，仅会产生控制台警告
        }

        final exeDir = File(Platform.resolvedExecutable).parent.path;
        final bundledMpv = '$exeDir/lib/libmpv.so';
        if (File(bundledMpv).existsSync()) {
          JustAudioMediaKit.ensureInitialized(libmpv: bundledMpv);
        } else {
          JustAudioMediaKit.ensureInitialized();
        }
      }

      runApp(const _BootstrapApp());
    },
    (error, stackTrace) {
      stderr.writeln('[FATAL] $error');
      stderr.writeln(stackTrace);
      unawaited(
        DiagnosticLogger.instance.log('[FATAL] $error\n$stackTrace'),
      );
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        parent.print(zone, line);
        unawaited(DiagnosticLogger.instance.captureConsoleLine(line));
      },
    ),
  );
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late Future<_BootstrapData> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<_BootstrapData> _bootstrap() async {
    final database = AppDatabase();

    final audioHandler = await AudioService.init(
      builder: () => MusicAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ohmymusic.audio',
        androidNotificationChannelName: 'OhMyMusic 音乐播放',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        throw TimeoutException('AudioService.init timed out after 20s');
      },
    );

    if (Platform.isWindows) {
      unawaited(WindowsMediaControls.initialize(audioHandler));
    }

    return _BootstrapData(
      database: database,
      audioHandler: audioHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapData>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _BootstrapLoadingScreen(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          final error = snapshot.error?.toString() ?? 'Unknown startup error';
          unawaited(
            DiagnosticLogger.instance.log('[DIAG] bootstrap failed: $error'),
          );
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _BootstrapErrorScreen(
              error: error,
              onRetry: () {
                setState(() {
                  _bootstrapFuture = _bootstrap();
                });
              },
            ),
          );
        }

        final data = snapshot.data!;
        return ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(data.database),
            audioHandlerProvider.overrideWithValue(data.audioHandler),
          ],
          child: const OhMyMusicApp(),
        );
      },
    );
  }
}

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing OhMyMusic...'),
          ],
        ),
      ),
    );
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  const _BootstrapErrorScreen({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 16),
              const Text(
                'Startup failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
