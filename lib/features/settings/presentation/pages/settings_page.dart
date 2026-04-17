import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';

import 'package:sonexa/core/audio/song_audio_cache.dart';
import 'package:sonexa/core/database/daos/settings_dao.dart';
import 'package:sonexa/core/database/app_database.dart';
import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sonexa/features/download/presentation/providers/download_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref)..load(),
);
final languageModeProvider =
    StateNotifierProvider<LanguageModeNotifier, AppLanguage>(
      (ref) => LanguageModeNotifier(ref)..load(),
    );
final diagnosticLoggingProvider =
    StateNotifierProvider<DiagnosticLoggingNotifier, bool>(
      (ref) => DiagnosticLoggingNotifier(
        ref,
        initial: DiagnosticLoggingNotifier.defaultValue,
      )..load(),
    );

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._ref, {ThemeMode initial = ThemeMode.system})
    : super(initial);

  static const _settingKey = 'app_theme_mode';

  final Ref _ref;

  static ThemeMode fromStorageValue(String? rawValue) {
    return switch (rawValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String toStorageValue(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  static Future<ThemeMode> loadStoredThemeMode(AppDatabase database) async {
    final rawValue = await SettingsDao(database).getSetting(_settingKey);
    return fromStorageValue(rawValue);
  }

  Future<void> load() async {
    final themeMode = await loadStoredThemeMode(_ref.read(databaseProvider));
    if (mounted) {
      state = themeMode;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    await SettingsDao(
      _ref.read(databaseProvider),
    ).setSetting(_settingKey, toStorageValue(themeMode));
  }
}

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

class DiagnosticLoggingNotifier extends StateNotifier<bool> {
  DiagnosticLoggingNotifier(this._ref, {required bool initial})
    : super(initial);

  static const _settingKey = 'diagnostic_logging_enabled';

  final Ref _ref;

  static bool get defaultValue => false;

  static bool fromStorageValue(String? rawValue) {
    return switch (rawValue) {
      '1' || 'true' => true,
      '0' || 'false' => false,
      _ => defaultValue,
    };
  }

  static String toStorageValue(bool enabled) => enabled ? '1' : '0';

  static Future<bool> loadStoredValue(AppDatabase database) async {
    final rawValue = await SettingsDao(database).getSetting(_settingKey);
    return fromStorageValue(rawValue);
  }

  Future<void> load() async {
    final enabled = await loadStoredValue(_ref.read(databaseProvider));
    if (mounted) {
      state = enabled;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await SettingsDao(
      _ref.read(databaseProvider),
    ).setSetting(_settingKey, toStorageValue(enabled));
    await DiagnosticLogger.instance.setEnabled(enabled, overwrite: enabled);
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final languageMode = ref.watch(languageModeProvider);
    final diagnosticLoggingEnabled = ref.watch(diagnosticLoggingProvider);
    final serverAsync = ref.watch(activeServerProvider);
    final downloadDirectoryAsync = ref.watch(downloadDirectoryInfoProvider);
    final errorColor = Theme.of(context).colorScheme.error;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.serverInfo),
          _SectionCard(
            child: serverAsync.when(
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
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(l10n.username),
                      subtitle: Text(server.username),
                    ),
                  ],
                );
              },
            ),
          ),
          _SectionHeader(title: l10n.appearance),
          _SectionCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.translate_rounded),
                    title: Text(l10n.appLanguage),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            _languageLabel(l10n, languageMode),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                    onTap:
                        () => _showLanguageDialog(context, ref, languageMode),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
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
                                () => ref
                                    .read(themeModeProvider.notifier)
                                    .setThemeMode(ThemeMode.system),
                          ),
                          _SettingChoiceOption(
                            width: itemWidth,
                            icon: Icons.light_mode_outlined,
                            label: l10n.lightTheme,
                            selected: themeMode == ThemeMode.light,
                            onTap:
                                () => ref
                                    .read(themeModeProvider.notifier)
                                    .setThemeMode(ThemeMode.light),
                          ),
                          _SettingChoiceOption(
                            width: itemWidth,
                            icon: Icons.dark_mode_outlined,
                            label: l10n.darkTheme,
                            selected: themeMode == ThemeMode.dark,
                            onTap:
                                () => ref
                                    .read(themeModeProvider.notifier)
                                    .setThemeMode(ThemeMode.dark),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _SectionHeader(title: l10n.downloadsAndCache),
          _SectionCard(
            child: Column(
              children: [
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
                                SnackBar(
                                  content: Text(l10n.downloadDirectoryCopied),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.pie_chart_outline_rounded),
                  title: Text(l10n.cacheUsage),
                  subtitle: Text(l10n.cacheUsageDescription),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCacheUsageDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: Text(l10n.downloadManager),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/downloads'),
                ),
              ],
            ),
          ),
          _SectionHeader(title: l10n.diagnostics),
          _SectionCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.bug_report_outlined),
                  title: Text(l10n.diagnosticLogging),
                  subtitle: Text(l10n.diagnosticLoggingDescription),
                  value: diagnosticLoggingEnabled,
                  onChanged:
                      (value) => ref
                          .read(diagnosticLoggingProvider.notifier)
                          .setEnabled(value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: Text(l10n.exportDiagnosticLog),
                  subtitle: Text(l10n.exportDiagnosticLogDescription),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _exportDiagnosticLog(context, ref),
                ),
              ],
            ),
          ),
          _SectionHeader(title: l10n.account),
          _SectionCard(
            child: ListTile(
              leading: Icon(Icons.logout, color: errorColor),
              title: Text(l10n.logout, style: TextStyle(color: errorColor)),
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ),
          _SectionHeader(title: l10n.about),
          _SectionCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(l10n.appName),
                  subtitle: Text('${l10n.slogan}\n${l10n.version}'),
                  isThreeLine: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.projectInfo),
                  subtitle: Text(l10n.positioning),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLanguage currentLanguage,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selectedLanguage = await showDialog<AppLanguage>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.appLanguage),
            contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
            content: RadioGroup<AppLanguage>(
              groupValue: currentLanguage,
              onChanged: (value) => Navigator.of(context).pop(value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    AppLanguage.values
                        .map(
                          (language) => RadioListTile<AppLanguage>(
                            value: language,
                            title: Text(_languageLabel(l10n, language)),
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
    );

    if (selectedLanguage == null || selectedLanguage == currentLanguage) {
      return;
    }

    await ref.read(languageModeProvider.notifier).setLanguage(selectedLanguage);
  }

  String _languageLabel(AppLocalizations l10n, AppLanguage language) {
    return switch (language) {
      AppLanguage.system => l10n.followSystem,
      AppLanguage.zh => l10n.chinese,
      AppLanguage.en => l10n.english,
    };
  }

  Future<void> _exportDiagnosticLog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    try {
      final directoryInfo = await ref.read(
        downloadDirectoryInfoProvider.future,
      );
      final exportedFile = await DiagnosticLogger.instance.exportLog(
        targetDirectoryPath: directoryInfo.path,
        fileName: 'sonexa-diagnostic.log',
      );

      if (!context.mounted) {
        return;
      }

      if (exportedFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noDiagnosticLogToExport)));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.diagnosticLogExported(exportedFile.path))),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.diagnosticLogExportFailed(error))),
      );
    }
  }

  Future<void> _showCacheUsageDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      final usage = await _loadCacheUsageSnapshot();
      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder:
            (context) => _CacheUsageDialog(initialUsage: usage, l10n: l10n),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loadFailed(error))));
    }
  }
}

class _CacheUsageSnapshot {
  const _CacheUsageSnapshot({
    required this.imageCacheBytes,
    required this.songCacheBytes,
  });

  final int imageCacheBytes;
  final int songCacheBytes;
}

Future<_CacheUsageSnapshot> _loadCacheUsageSnapshot() async {
  await SongAudioCache.instance.ensureInitialized();
  final imageCacheBytes = await DefaultCacheManager().store.getCacheSize();
  final songCacheBytes = await SongAudioCache.instance.usageBytes();
  return _CacheUsageSnapshot(
    imageCacheBytes: imageCacheBytes,
    songCacheBytes: songCacheBytes,
  );
}

class _CacheUsageDialog extends StatefulWidget {
  const _CacheUsageDialog({required this.initialUsage, required this.l10n});

  final _CacheUsageSnapshot initialUsage;
  final AppLocalizations l10n;

  @override
  State<_CacheUsageDialog> createState() => _CacheUsageDialogState();
}

class _CacheUsageDialogState extends State<_CacheUsageDialog> {
  late _CacheUsageSnapshot _usage;
  _CacheTarget? _clearingTarget;

  @override
  void initState() {
    super.initState();
    _usage = widget.initialUsage;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return AlertDialog(
      title: Text(l10n.cacheUsage),
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320, maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CacheUsageRow(
                icon: Icons.image_outlined,
                title: l10n.imageCacheUsage,
                usage: _formatBytes(_usage.imageCacheBytes),
                actionLabel: l10n.clearImageCache,
                busy: _clearingTarget == _CacheTarget.image,
                onPressed: () => _clearImageCache(context),
              ),
              const SizedBox(height: 12),
              _CacheUsageRow(
                icon: Icons.audio_file_outlined,
                title: l10n.songCacheUsage,
                usage: _formatBytes(_usage.songCacheBytes),
                actionLabel: l10n.clearSongCache,
                busy: _clearingTarget == _CacheTarget.song,
                onPressed: () => _clearSongCache(context),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Future<void> _clearImageCache(BuildContext context) async {
    await _runClearAction(
      context,
      target: _CacheTarget.image,
      action: () async {
        await DefaultCacheManager().emptyCache();
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      },
      successMessage: widget.l10n.imageCacheCleared,
    );
  }

  Future<void> _clearSongCache(BuildContext context) async {
    await _runClearAction(
      context,
      target: _CacheTarget.song,
      action: () => SongAudioCache.instance.clear(),
      successMessage: widget.l10n.songCacheCleared,
    );
  }

  Future<void> _runClearAction(
    BuildContext context, {
    required _CacheTarget target,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    final l10n = widget.l10n;
    final messenger = ScaffoldMessenger.of(context);

    if (_clearingTarget != null) {
      return;
    }

    setState(() {
      _clearingTarget = target;
    });

    try {
      await action();
      if (!mounted) {
        return;
      }
      final updatedUsage = await _loadCacheUsageSnapshot();
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      setState(() {
        _usage = updatedUsage;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.loadFailed(error))));
    } finally {
      if (mounted) {
        setState(() {
          _clearingTarget = null;
        });
      }
    }
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    final precision = unitIndex == 0 ? 0 : 1;
    return '${value.toStringAsFixed(precision)} ${units[unitIndex]}';
  }
}

enum _CacheTarget { image, song }

class _CacheUsageRow extends StatelessWidget {
  const _CacheUsageRow({
    required this.icon,
    required this.title,
    required this.usage,
    required this.actionLabel,
    required this.busy,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String usage;
  final String actionLabel;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      usage,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: busy ? null : onPressed,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child:
                  busy
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(actionLabel),
            ),
          ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(margin: EdgeInsets.zero, child: child),
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
