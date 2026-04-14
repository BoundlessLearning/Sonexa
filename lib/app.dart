import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonexa/core/localization/app_localizations.dart';
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
    final language = ref.watch(languageModeProvider);
    ref.watch(scrobbleServiceProvider);

    return MaterialApp.router(
      title: AppLocalizations.appTitleFor(language),
      locale: language.locale,
      supportedLocales: const [Locale('zh'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
