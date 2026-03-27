import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ohmymusic/features/auth/presentation/providers/auth_provider.dart';

// ── 主题模式 Provider（当前本地管理）──────────────────────────
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// 设置页 — 服务器信息、外观、缓存、账号、关于
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final serverAsync = ref.watch(activeServerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // ── 服务器信息 ──────────────────────────────────────
          _SectionHeader(title: '服务器信息'),
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
                  // 服务器地址
                  ListTile(
                    leading: const Icon(Icons.dns_outlined),
                    title: const Text('服务器地址'),
                    subtitle: Text(server.baseUrl),
                  ),
                  // 用户名
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

          // ── 外观设置 ──────────────────────────────────────
          _SectionHeader(title: '外观'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('主题模式'),
            trailing: SegmentedButton<ThemeMode>(
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
                ref.read(themeModeProvider.notifier).state = selected.first;
              },
            ),
          ),

          const Divider(),

          // ── 缓存管理 ──────────────────────────────────────
          _SectionHeader(title: '缓存'),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('清除图片缓存'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 清除内存中的图片缓存
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

          // ── 账号 ──────────────────────────────────────────
          _SectionHeader(title: '账号'),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              '退出登录',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),

          const Divider(),

          // ── 关于 ──────────────────────────────────────────
          _SectionHeader(title: '关于'),
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

          // 底部留白
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// 区域标题组件
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
