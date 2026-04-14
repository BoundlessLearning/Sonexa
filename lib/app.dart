import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonexa/core/constants/app_branding.dart';
import 'package:sonexa/core/router/app_router.dart';
import 'package:sonexa/core/theme/app_theme.dart';
import 'package:sonexa/features/player/presentation/providers/play_history_provider.dart';
import 'package:sonexa/features/settings/presentation/pages/settings_page.dart';

class SonexaApp extends ConsumerWidget {
  const SonexaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(scrobbleServiceProvider);

    return MaterialApp.router(
      title: AppBranding.name,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
