import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sonexa/core/widgets/app_image.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';

/// 艺术家列表标签页 — 点击进入艺术家详情
class ArtistsTab extends ConsumerWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(artistListProvider);

    return artistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => ref.invalidate(artistListProvider),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (artists) {
        if (artists.isEmpty) {
          return const Center(child: Text('暂无艺术家'));
        }

        // 获取 API 客户端用于封面 URL
        final api = ref.read(subsonicApiClientProvider).requireValue;

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(artistListProvider),
          child: ListView.builder(
            itemCount: artists.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final artist = artists[index];
              final textTheme = Theme.of(context).textTheme;
              final colorScheme = Theme.of(context).colorScheme;
              final coverUrl = api.getCoverArtUrl(artist.coverArtId);

              return ListTile(
                leading: ClipOval(
                  child: AppImage(
                    url: coverUrl,
                    size: 44,
                    borderRadius: 22,
                  ),
                ),
                title: Text(
                  artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge,
                ),
                subtitle: Text(
                  '${artist.albumCount} 张专辑',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () => context.push('/library/artist/${artist.id}'),
              );
            },
          ),
        );
      },
    );
  }
}
