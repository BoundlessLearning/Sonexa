import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ohmymusic/core/router/app_router.dart';
import 'package:ohmymusic/core/theme/app_theme.dart';
import 'package:ohmymusic/features/player/presentation/providers/play_history_provider.dart';
import 'package:ohmymusic/features/settings/presentation/pages/settings_page.dart';

class OhMyMusicApp extends ConsumerWidget {
  const OhMyMusicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(scrobbleServiceProvider);

    return MaterialApp.router(
      title: 'OhMyMusic',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
