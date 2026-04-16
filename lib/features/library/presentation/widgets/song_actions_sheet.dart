import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sonexa/core/audio/media_item_converter.dart';
import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/core/network/subsonic_api_client.dart';
import 'package:sonexa/core/widgets/app_image.dart';
import 'package:sonexa/features/download/domain/entities/download_task.dart';
import 'package:sonexa/features/download/presentation/providers/download_provider.dart';
import 'package:sonexa/features/library/domain/entities/playlist.dart';
import 'package:sonexa/features/library/domain/entities/song.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';
import 'package:sonexa/features/library/presentation/providers/playlist_provider.dart';
import 'package:sonexa/features/player/presentation/providers/player_provider.dart';

Future<void> showSongActionsSheet(
  BuildContext context, {
  required Song song,
  String? coverUrl,
  bool showAddToQueueAction = false,
  bool replaceRouteOnNavigate = false,
  String routeBasePath = '/library',
}) async {
  final result = await showModalBottomSheet<_SongActionsResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (sheetContext) => _SongActionsSheet(
          parentContext: context,
          song: song,
          coverUrl: coverUrl,
          showAddToQueueAction: showAddToQueueAction,
        ),
  );

  if (!context.mounted || result == null) {
    return;
  }

  switch (result) {
    case _SongActionsResult.openAlbum:
      final location =
          Uri(
            path: '$routeBasePath/album-songs/${song.albumId}',
            queryParameters: {'title': song.album},
          ).toString();
      if (replaceRouteOnNavigate) {
        context.go(location);
      } else {
        await context.push(location);
      }
      return;
    case _SongActionsResult.openArtist:
      final location =
          Uri(
            path: '$routeBasePath/artist-songs',
            queryParameters: {
              'artistId': song.artistId,
              'artistName': song.artist,
              'title': song.artist,
            },
          ).toString();
      if (replaceRouteOnNavigate) {
        context.go(location);
      } else {
        await context.push(location);
      }
      return;
  }
}

class _SongActionsSheet extends ConsumerStatefulWidget {
  const _SongActionsSheet({
    required this.parentContext,
    required this.song,
    required this.coverUrl,
    required this.showAddToQueueAction,
  });

  final BuildContext parentContext;
  final Song song;
  final String? coverUrl;
  final bool showAddToQueueAction;

  @override
  ConsumerState<_SongActionsSheet> createState() => _SongActionsSheetState();
}

class _SongActionsSheetState extends ConsumerState<_SongActionsSheet> {
  _SongDownloadUiState? _optimisticDownloadState;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<DownloadTask>>>(downloadListProvider, (_, next) {
      final tasks = next.valueOrNull ?? const <DownloadTask>[];
      final downloadedPathAsync = ref.read(
        downloadedSongPathProvider(widget.song.id),
      );
      final currentDownload = _findCurrentDownload(tasks);
      final nextState = _resolveDownloadUiState(
        currentDownload: currentDownload,
        downloadedPath: downloadedPathAsync.valueOrNull,
        isCheckingPath: downloadedPathAsync.isLoading,
      );

      if (_optimisticDownloadState != nextState && mounted) {
        setState(() {
          _optimisticDownloadState = nextState;
        });
      }

      if (currentDownload?.status == DownloadStatus.completed) {
        ref.invalidate(downloadedSongPathProvider(widget.song.id));
      }
    });

    final downloadTasks =
        ref.watch(downloadListProvider).valueOrNull ?? const <DownloadTask>[];
    final downloadedPathAsync = ref.watch(
      downloadedSongPathProvider(widget.song.id),
    );
    final currentDownload = _findCurrentDownload(downloadTasks);
    final downloadUiState =
        _optimisticDownloadState ??
        _resolveDownloadUiState(
          currentDownload: currentDownload,
          downloadedPath: downloadedPathAsync.valueOrNull,
          isCheckingPath: downloadedPathAsync.isLoading,
        );
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    Future<void> startDownload() async {
      setState(() {
        _optimisticDownloadState = _SongDownloadUiState.downloading;
      });
      final manager = await ref.read(downloadManagerProvider.future);
      await manager.enqueueDownload(widget.song);
      ref.invalidate(downloadedSongPathProvider(widget.song.id));
    }

    Future<void> openPlaylistPicker() async {
      Navigator.of(context).pop();
      await showDialog<void>(
        context: widget.parentContext,
        builder: (dialogContext) => _PlaylistPickerDialog(song: widget.song),
      );
    }

    Future<void> playNext() async {
      final navigator = Navigator.of(context);
      final cachedApi = ref.read(subsonicApiClientProvider).valueOrNull;
      final SubsonicApiClient api;
      if (cachedApi != null) {
        api = cachedApi;
      } else {
        api = await ref.read(subsonicApiClientProvider.future);
      }
      final coverArtUrl = api.getCoverArtUrl(widget.song.coverArtId, size: 300);
      final streamUrl = api.getStreamUrl(
        widget.song.id,
        format: widget.song.preferredPlaybackFormat,
      );
      final resolvedCoverUrl =
          widget.coverUrl == null || widget.coverUrl!.isEmpty
              ? coverArtUrl
              : widget.coverUrl!;
      final item = widget.song.toMediaItem(streamUrl, resolvedCoverUrl);
      await ref.read(audioHandlerProvider).playNext(item);
      navigator.pop();
      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(content: Text(_playNextFeedbackLabel(widget.parentContext))),
        );
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: AppImage(
                    url: widget.coverUrl,
                    size: 72,
                    borderRadius: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.song.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showAddToQueueAction)
                  Expanded(
                    child: _QuickActionItem(
                      icon: Icons.queue_music_rounded,
                      label: _playNextActionLabel(context),
                      onTap: playNext,
                    ),
                  ),
                if (widget.showAddToQueueAction) const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionItem(
                    icon:
                        downloadUiState == _SongDownloadUiState.downloaded
                            ? Icons.check_circle_rounded
                            : downloadUiState ==
                                _SongDownloadUiState.downloading
                            ? Icons.downloading_rounded
                            : Icons.download_rounded,
                    label:
                        downloadUiState == _SongDownloadUiState.checking
                            ? l10n.checking
                            : downloadUiState == _SongDownloadUiState.downloaded
                            ? l10n.downloaded
                            : downloadUiState ==
                                _SongDownloadUiState.downloading
                            ? l10n.downloading
                            : _downloadActionLabel(context),
                    onTap:
                        downloadUiState != _SongDownloadUiState.idle
                            ? null
                            : startDownload,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionItem(
                    icon: Icons.playlist_add_rounded,
                    label: _playlistActionLabel(context),
                    onTap: openPlaylistPicker,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.42,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.album_rounded,
                    label: l10n.album,
                    value:
                        widget.song.album.isEmpty
                            ? l10n.unknownAlbum
                            : widget.song.album,
                    onTap:
                        widget.song.albumId.isEmpty
                            ? null
                            : () => Navigator.of(
                              context,
                            ).pop(_SongActionsResult.openAlbum),
                  ),
                  _InfoTile(
                    icon: Icons.person_rounded,
                    label: l10n.artist,
                    value:
                        widget.song.artist.isEmpty
                            ? l10n.unknownArtist
                            : widget.song.artist,
                    onTap:
                        widget.song.artistId.isEmpty &&
                                widget.song.artist.isEmpty
                            ? null
                            : () => Navigator.of(
                              context,
                            ).pop(_SongActionsResult.openArtist),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DownloadTask? _findCurrentDownload(List<DownloadTask> tasks) {
    return tasks.cast<DownloadTask?>().firstWhere(
      (task) => task?.songId == widget.song.id,
      orElse: () => null,
    );
  }

  _SongDownloadUiState _resolveDownloadUiState({
    required DownloadTask? currentDownload,
    required String? downloadedPath,
    required bool isCheckingPath,
  }) {
    final status = currentDownload?.status;
    if (status == DownloadStatus.completed || downloadedPath != null) {
      return _SongDownloadUiState.downloaded;
    }
    if (status == DownloadStatus.pending ||
        status == DownloadStatus.downloading ||
        status == DownloadStatus.paused) {
      return _SongDownloadUiState.downloading;
    }
    if (isCheckingPath && currentDownload == null) {
      return _SongDownloadUiState.checking;
    }
    return _SongDownloadUiState.idle;
  }
}

enum _SongDownloadUiState { idle, checking, downloading, downloaded }

enum _SongActionsResult { openAlbum, openArtist }

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(label),
      subtitle: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color:
                    enabled
                        ? colorScheme.surfaceContainer.withValues(alpha: 0.96)
                        : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 24,
                color:
                    enabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    enabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _playNextActionLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale.startsWith('zh') ? '下一首播放' : 'Play next';
}

String _downloadActionLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale.startsWith('zh') ? '下载' : 'Download';
}

String _playlistActionLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale.startsWith('zh') ? '加到歌单' : 'Playlist';
}

String _playNextFeedbackLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale.startsWith('zh') ? '已加入下一首播放' : 'Added as next track';
}

class _PlaylistPickerDialog extends ConsumerWidget {
  const _PlaylistPickerDialog({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.addToPlaylistShort),
      content: SizedBox(
        width: 320,
        child: playlistsAsync.when(
          loading:
              () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
          error: (error, _) => Text(l10n.getPlaylistFailed(error)),
          data: (playlists) {
            if (playlists.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n.noSongListCreateFirst),
              );
            }

            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return ListTile(
                    leading: Icon(
                      Icons.queue_music_rounded,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(l10n.songCount(playlist.songCount)),
                    onTap: () => _addToPlaylist(context, ref, playlist),
                  );
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => _showNewPlaylistDialog(context, ref),
          child: Text(l10n.createPlaylist),
        ),
      ],
    );
  }

  Future<void> _addToPlaylist(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    Navigator.of(context).pop();

    try {
      await ref
          .read(playlistCrudNotifierProvider.notifier)
          .addSongToPlaylist(playlist.id, song.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).addedToPlaylist(playlist.name),
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).addFailed(error)),
          ),
        );
      }
    }
  }

  void _showNewPlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n.createPlaylist),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.playlistName,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _createAndAdd(dialogContext, ref, controller),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => _createAndAdd(dialogContext, ref, controller),
                child: Text(l10n.createAndAdd),
              ),
            ],
          ),
    );
  }

  Future<void> _createAndAdd(
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller,
  ) async {
    final name = controller.text.trim();
    if (name.isEmpty) {
      return;
    }

    Navigator.of(context).pop();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    try {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.createPlaylist(name: name, songIds: [song.id]);
      ref.invalidate(playlistsProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).createFailed(error)),
          ),
        );
      }
    }
  }
}
