import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/core/widgets/app_image.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';

/// 艺术家列表标签页 — 点击进入艺术家详情
class ArtistsTab extends ConsumerWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(artistListProvider);
    final l10n = AppLocalizations.of(context);

    return artistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
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
                  l10n.failedToLoad,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(artistListProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
      data: (artists) {
        if (artists.isEmpty) {
          return Center(child: Text(l10n.noArtists));
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
                  child: AppImage(url: coverUrl, size: 44, borderRadius: 22),
                ),
                title: Text(
                  artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge,
                ),
                subtitle: Text(
                  l10n.albumCount(artist.albumCount),
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
