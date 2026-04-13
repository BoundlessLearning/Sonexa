import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ohmymusic/features/auth/presentation/providers/auth_provider.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final serverAsync = ref.watch(activeServerProvider);
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('跟随系统'),
                            icon: Icon(Icons.settings_suggest_outlined),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('浅色'),
                            icon: Icon(Icons.light_mode_outlined),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('深色'),
                            icon: Icon(Icons.dark_mode_outlined),
                          ),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (selected) {
                          ref.read(themeModeProvider.notifier).state =
                              selected.first;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          const _SectionHeader(title: '缓存'),
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
            title: Text('OhMyMusic'),
            subtitle: Text('版本 1.0.0-dev'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('项目信息'),
            subtitle: Text('基于 Subsonic API 的开源音乐播放器'),
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
