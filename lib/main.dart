import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sonexa/app.dart';
import 'package:sonexa/core/audio/audio_handler.dart';
import 'package:sonexa/core/audio/playback_session_store.dart';
import 'package:sonexa/core/audio/windows_media_controls.dart';
import 'package:sonexa/core/constants/app_branding.dart';
import 'package:sonexa/core/database/app_database.dart';
import 'package:sonexa/core/database/daos/settings_dao.dart';
import 'package:sonexa/core/theme/app_theme.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/core/utils/image_cache_config.dart';
import 'package:sonexa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sonexa/features/player/presentation/providers/player_provider.dart';
import 'package:sonexa/features/settings/presentation/pages/settings_page.dart';

class _BootstrapData {
  const _BootstrapData({
    required this.database,
    required this.audioHandler,
    required this.themeMode,
  });

  final AppDatabase database;
  final MusicAudioHandler audioHandler;
  final ThemeMode themeMode;
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
          DiagnosticLogger.instance.log(
            '[FLUTTER_ERROR] ${details.exceptionAsString()}\n$stack',
          ),
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
      unawaited(DiagnosticLogger.instance.log('[FATAL] $error\n$stackTrace'));
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
  static const Duration _minimumSplashDuration = Duration(milliseconds: 1500);

  late final AppDatabase _database;
  late Future<_BootstrapData> _bootstrapFuture;
  ThemeMode _startupThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
    unawaited(_loadStartupThemeMode());
    _bootstrapFuture = _bootstrapWithSplash();
  }

  Future<void> _loadStartupThemeMode() async {
    try {
      final themeMode = await ThemeModeNotifier.loadStoredThemeMode(_database);
      if (mounted && themeMode != _startupThemeMode) {
        setState(() {
          _startupThemeMode = themeMode;
        });
      }
    } catch (error, stackTrace) {
      unawaited(
        DiagnosticLogger.instance.log(
          '[DIAG] failed to load startup theme: $error\n$stackTrace',
        ),
      );
    }
  }

  Future<_BootstrapData> _bootstrapWithSplash() async {
    final bootstrapFuture = _bootstrap();
    await Future.wait<Object?>([
      bootstrapFuture,
      Future<void>.delayed(_minimumSplashDuration),
    ]);
    return bootstrapFuture;
  }

  Future<_BootstrapData> _bootstrap() async {
    final themeMode = await ThemeModeNotifier.loadStoredThemeMode(_database);

    final audioHandler = await AudioService.init(
      builder:
          () => MusicAudioHandler(
            playbackSessionStore: PlaybackSessionStore(SettingsDao(_database)),
          ),
      config: const AudioServiceConfig(
        androidNotificationChannelId: AppBranding.audioNotificationChannelId,
        androidNotificationChannelName:
            AppBranding.audioNotificationChannelName,
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
      database: _database,
      audioHandler: audioHandler,
      themeMode: themeMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapData>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _startupThemeMode,
            home: const _BootstrapLoadingScreen(),
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
                  _bootstrapFuture = _bootstrapWithSplash();
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
            themeModeProvider.overrideWith(
              (ref) => ThemeModeNotifier(ref, initial: data.themeMode)..load(),
            ),
          ],
          child: const SonexaApp(),
        );
      },
    );
  }
}

class _BootstrapLoadingScreen extends StatefulWidget {
  const _BootstrapLoadingScreen();

  @override
  State<_BootstrapLoadingScreen> createState() =>
      _BootstrapLoadingScreenState();
}

class _BootstrapLoadingScreenState extends State<_BootstrapLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF090B12) : const Color(0xFFDDE7FF),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shortestSide = math.min(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final splashSize = math.min(shortestSide * 0.94, 640.0);

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return SizedBox.square(
                    dimension: splashSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: _SplashWavePainter(
                            progress: _controller.value,
                            isDark: isDark,
                          ),
                        ),
                        Image.asset(
                          'assets/branding/splash_foreground.png',
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                        _BreathingPlayMark(
                          progress: _controller.value,
                          size: splashSize,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BreathingPlayMark extends StatelessWidget {
  const _BreathingPlayMark({
    required this.progress,
    required this.size,
    required this.isDark,
  });

  final double progress;
  final double size;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final pulse = (math.sin(progress * math.pi * 2) + 1) / 2;
    final markSize = size * 0.056;
    final scale = 0.96 + pulse * 0.10;
    final fillOpacity = 0.72 + pulse * 0.18;
    final glowOpacity = (isDark ? 0.22 : 0.10) + pulse * 0.18;
    final fillColor =
        isDark ? const Color(0xFF91A9FF) : const Color(0xFF7F9DF6);
    final glowColor =
        isDark ? const Color(0xFF8EA7FF) : const Color(0xFF6C8EF6);

    return Positioned(
      left: size * 0.378 - markSize / 2,
      top: size * 0.743 - markSize / 2,
      width: markSize,
      height: markSize,
      child: Transform.scale(
        scale: scale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor.withValues(alpha: fillOpacity),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: glowOpacity),
                blurRadius: 18 + pulse * 16,
                spreadRadius: 1 + pulse * 4,
              ),
            ],
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white.withValues(alpha: 0.72 + pulse * 0.22),
            size: markSize * 0.62,
          ),
        ),
      ),
    );
  }
}

class _SplashWavePainter extends CustomPainter {
  const _SplashWavePainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.49;
    final phase = progress * math.pi * 2;
    final waveColor =
        isDark ? const Color(0xFF8EA7FF) : const Color(0xFF6C8EF6);

    _paintWaveGroup(
      canvas: canvas,
      size: size,
      centerY: centerY,
      startX: size.width * 0.03,
      endX: size.width * 0.41,
      phase: phase,
      reverseEnvelope: false,
      color: waveColor,
    );
    _paintWaveGroup(
      canvas: canvas,
      size: size,
      centerY: centerY,
      startX: size.width * 0.61,
      endX: size.width * 0.97,
      phase: phase + math.pi * 0.35,
      reverseEnvelope: true,
      color: waveColor,
    );
  }

  void _paintWaveGroup({
    required Canvas canvas,
    required Size size,
    required double centerY,
    required double startX,
    required double endX,
    required double phase,
    required bool reverseEnvelope,
    required Color color,
  }) {
    const barCount = 24;
    final spacing = (endX - startX) / (barCount - 1);

    for (var i = 0; i < barCount; i++) {
      final t = i / (barCount - 1);
      final envelope =
          reverseEnvelope ? math.sin((1 - t) * math.pi) : math.sin(t * math.pi);
      final wave = (math.sin(phase * 1.35 + i * 0.72) + 1) / 2;
      final secondary = (math.sin(phase * 0.72 + i * 1.41) + 1) / 2;
      final height =
          size.height *
          (0.005 + envelope * (0.030 + wave * 0.044 + secondary * 0.018));
      final x = startX + i * spacing;
      final alpha =
          (isDark ? 0.18 : 0.12) +
          envelope * ((isDark ? 0.18 : 0.10) + wave * 0.18);
      final strokeWidth = size.width * (0.0034 + wave * 0.002);
      final paint =
          Paint()
            ..color = color.withValues(alpha: alpha.clamp(0.0, 0.72))
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x, centerY - height),
        Offset(x, centerY + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplashWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  const _BootstrapErrorScreen({required this.error, required this.onRetry});

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
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
