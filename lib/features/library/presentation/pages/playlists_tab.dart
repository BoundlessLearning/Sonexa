import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/core/widgets/app_image.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';
import 'package:sonexa/features/library/presentation/providers/playlist_provider.dart';

class PlaylistsTab extends ConsumerWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: playlistsAsync.when(
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
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => ref.invalidate(playlistsProvider),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
        data: (playlists) {
          if (playlists.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(playlistsProvider),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(l10n.noPlaylists)),
                ],
              ),
            );
          }

          final api = ref.read(subsonicApiClientProvider).requireValue;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(playlistsProvider),
            child: ListView.separated(
              itemCount: playlists.length,
              padding: const EdgeInsets.only(bottom: 96),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final coverUrl = api.getCoverArtUrl(playlist.coverArtId);

                return ListTile(
                  leading: AppImage(url: coverUrl, size: 52, borderRadius: 10),
                  title: Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(l10n.songCount(playlist.songCount)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/library/playlist/${playlist.id}'),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlaylistDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);

    try {
      final name = await showDialog<String>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: Text(l10n.createPlaylist),
              content: TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.playlistName,
                  hintText: l10n.enterName,
                ),
                onSubmitted: (value) {
                  Navigator.of(dialogContext).pop(value.trim());
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(controller.text.trim());
                  },
                  child: Text(l10n.create),
                ),
              ],
            ),
      );

      if (name == null || name.isEmpty || !context.mounted) {
        return;
      }

      await ref
          .read(playlistCrudNotifierProvider.notifier)
          .createPlaylist(name);

      final crudState = ref.read(playlistCrudNotifierProvider);
      if (!context.mounted) return;

      if (crudState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.createFailed(crudState.error ?? ''))),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.playlistCreated)));
    } finally {
      controller.dispose();
    }
  }
}
