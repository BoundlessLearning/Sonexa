import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sonexa/core/database/daos/settings_dao.dart';
import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sonexa/features/download/presentation/providers/download_provider.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final languageModeProvider =
    StateNotifierProvider<LanguageModeNotifier, AppLanguage>(
      (ref) => LanguageModeNotifier(ref)..load(),
    );

class LanguageModeNotifier extends StateNotifier<AppLanguage> {
  LanguageModeNotifier(this._ref) : super(AppLanguage.system);

  static const _settingKey = 'app_language';

  final Ref _ref;

  Future<void> load() async {
    final rawValue = await SettingsDao(
      _ref.read(databaseProvider),
    ).getSetting(_settingKey);
    if (mounted) {
      state = AppLanguage.fromStorageValue(rawValue);
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await SettingsDao(
      _ref.read(databaseProvider),
    ).setSetting(_settingKey, language.storageValue);
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final languageMode = ref.watch(languageModeProvider);
    final serverAsync = ref.watch(activeServerProvider);
    final downloadDirectoryAsync = ref.watch(downloadDirectoryInfoProvider);
    final errorColor = Theme.of(context).colorScheme.error;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.serverInfo),
          serverAsync.when(
            loading:
                () => ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: Text(l10n.loading),
                ),
            error:
                (error, _) => ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(l10n.serverInfo),
                  subtitle: Text(l10n.loadFailed(error)),
                ),
            data: (server) {
              if (server == null) {
                return ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: Text(l10n.noServer),
                );
              }

              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dns_outlined),
                    title: Text(l10n.serverAddress),
                    subtitle: Text(server.baseUrl),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(l10n.username),
                    subtitle: Text(server.username),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          _SectionHeader(title: l10n.appearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appLanguage,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 8.0;
                        final itemWidth =
                            (constraints.maxWidth - spacing * 2) / 3;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            _SettingChoiceOption(
                              width: itemWidth,
                              icon: Icons.settings_suggest_outlined,
                              label: l10n.followSystem,
                              selected: languageMode == AppLanguage.system,
                              onTap:
                                  () => ref
                                      .read(languageModeProvider.notifier)
                                      .setLanguage(AppLanguage.system),
                            ),
                            _SettingChoiceOption(
                              width: itemWidth,
                              icon: Icons.translate_rounded,
                              label: l10n.chinese,
                              selected: languageMode == AppLanguage.zh,
                              onTap:
                                  () => ref
                                      .read(languageModeProvider.notifier)
                                      .setLanguage(AppLanguage.zh),
                            ),
                            _SettingChoiceOption(
                              width: itemWidth,
                              icon: Icons.language_rounded,
                              label: l10n.english,
                              selected: languageMode == AppLanguage.en,
                              onTap:
                                  () => ref
                                      .read(languageModeProvider.notifier)
                                      .setLanguage(AppLanguage.en),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.themeMode,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 8.0;
                        final itemWidth =
                            (constraints.maxWidth - spacing * 2) / 3;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            _SettingChoiceOption(
                              width: itemWidth,
                              icon: Icons.settings_suggest_outlined,
                              label: l10n.followSystem,
                              selected: themeMode == ThemeMode.system,
                              onTap:
                                  () =>
                                      ref
                                          .read(themeModeProvider.notifier)
                                          .state = ThemeMode.system,
                            ),
                            _SettingChoiceOption(
                              width: itemWidth,
                              icon: Icons.light_mode_outlined,
                              label: l10n.lightTheme,
                              selected: themeMode == ThemeMode.light,
                              onTap:
                                  () =>
                                      ref
                                          .read(themeModeProvider.notifier)
                                          .state = ThemeMode.light,
                            ),
                            _SettingChoiceOption(
                              width: itemWidth,
                              icon: Icons.dark_mode_outlined,
                              label: l10n.darkTheme,
                              selected: themeMode == ThemeMode.dark,
                              onTap:
                                  () =>
                                      ref
                                          .read(themeModeProvider.notifier)
                                          .state = ThemeMode.dark,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          _SectionHeader(title: l10n.downloadsAndCache),
          downloadDirectoryAsync.when(
            loading:
                () => ListTile(
                  leading: const Icon(Icons.folder_open_rounded),
                  title: Text(l10n.downloadDirectory),
                  subtitle: Text(l10n.loading),
                ),
            error:
                (error, _) => ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(l10n.downloadDirectory),
                  subtitle: Text(l10n.loadFailed(error)),
                ),
            data:
                (directoryInfo) => ListTile(
                  leading: const Icon(Icons.folder_open_rounded),
                  title: Text(l10n.downloadDirectory),
                  subtitle: Text(
                    '${directoryInfo.isPublic ? l10n.publicDownloadDirectory : l10n.privateAppDirectory}\n${directoryInfo.path}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    tooltip: l10n.copyPath,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: directoryInfo.path),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.downloadDirectoryCopied)),
                        );
                      }
                    },
                  ),
                ),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(l10n.clearImageCache),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: Text(l10n.downloadManager),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/downloads'),
          ),
          const Divider(),
          _SectionHeader(title: l10n.account),
          ListTile(
            leading: Icon(Icons.logout, color: errorColor),
            title: Text(l10n.logout, style: TextStyle(color: errorColor)),
            onTap: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          const Divider(),
          _SectionHeader(title: l10n.about),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(l10n.appName),
            subtitle: Text('${l10n.slogan}\n${l10n.version}'),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.projectInfo),
            subtitle: Text(l10n.positioning),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SettingChoiceOption extends StatelessWidget {
  const _SettingChoiceOption({
    required this.width,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: FilledButton.tonalIcon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          backgroundColor:
              selected ? colorScheme.primaryContainer : colorScheme.surface,
          foregroundColor:
              selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
          side: BorderSide(
            color:
                selected
                    ? colorScheme.primary.withValues(alpha: 0.28)
                    : colorScheme.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
