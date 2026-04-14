import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sonexa/core/constants/app_branding.dart';
import 'package:sonexa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sonexa/features/download/presentation/providers/download_provider.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final serverAsync = ref.watch(activeServerProvider);
    final downloadDirectoryAsync = ref.watch(downloadDirectoryInfoProvider);
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          const _SectionHeader(title: '服务器信息'),
          serverAsync.when(
            loading: () => const ListTile(
              leading: Icon(Icons.dns_outlined),
              title: Text('加载中...'),
            ),
            error: (error, _) => ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('服务器信息'),
              subtitle: Text('加载失败: $error'),
            ),
            data: (server) {
              if (server == null) {
                return const ListTile(
                  leading: Icon(Icons.dns_outlined),
                  title: Text('未连接服务器'),
                );
              }

              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dns_outlined),
                    title: const Text('服务器地址'),
                    subtitle: Text(server.baseUrl),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('用户名'),
                    subtitle: Text(server.username),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          const _SectionHeader(title: '外观'),
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
                      '主题模式',
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
                            _ThemeModeOption(
                              width: itemWidth,
                              icon: Icons.settings_suggest_outlined,
                              label: '跟随系统',
                              selected: themeMode == ThemeMode.system,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .state = ThemeMode.system,
                            ),
                            _ThemeModeOption(
                              width: itemWidth,
                              icon: Icons.light_mode_outlined,
                              label: '浅色',
                              selected: themeMode == ThemeMode.light,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .state = ThemeMode.light,
                            ),
                            _ThemeModeOption(
                              width: itemWidth,
                              icon: Icons.dark_mode_outlined,
                              label: '深色',
                              selected: themeMode == ThemeMode.dark,
                              onTap: () => ref
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
          const _SectionHeader(title: '下载与缓存'),
          downloadDirectoryAsync.when(
            loading: () => const ListTile(
              leading: Icon(Icons.folder_open_rounded),
              title: Text('下载目录'),
              subtitle: Text('加载中...'),
            ),
            error: (error, _) => ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('下载目录'),
              subtitle: Text('加载失败: $error'),
            ),
            data: (directoryInfo) => ListTile(
              leading: const Icon(Icons.folder_open_rounded),
              title: const Text('下载目录'),
              subtitle: Text(
                '${directoryInfo.label}\n${directoryInfo.path}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: '复制路径',
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: directoryInfo.path),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('下载目录已复制')),
                    );
                  }
                },
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('清除图片缓存'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('缓存已清除')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('下载管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/downloads'),
          ),
          const Divider(),
          const _SectionHeader(title: '账号'),
          ListTile(
            leading: Icon(Icons.logout, color: errorColor),
            title: Text(
              '退出登录',
              style: TextStyle(color: errorColor),
            ),
            onTap: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          const Divider(),
          const _SectionHeader(title: '关于'),
          const ListTile(
            leading: Icon(Icons.music_note),
            title: Text(AppBranding.name),
            subtitle: Text('${AppBranding.slogan}\n版本 1.0.0-dev'),
            isThreeLine: true,
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('项目信息'),
            subtitle: Text(AppBranding.positioning),
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

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
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
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.28)
                : colorScheme.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
