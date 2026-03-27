import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ohmymusic/features/download/presentation/providers/download_provider.dart';
import 'package:ohmymusic/features/library/domain/entities/playlist.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';
import 'package:ohmymusic/features/library/presentation/providers/playlist_provider.dart';
import 'package:ohmymusic/features/player/presentation/providers/favorites_provider.dart';

/// 歌曲右键/长按上下文菜单，包含：添加到播放列表、收藏、下载。
class SongContextMenu {
  SongContextMenu._();

  /// 显示歌曲上下文菜单。
  /// 在桌面端为弹出菜单（通过 [offset] 定位），移动端为底部弹出列表。
  static void show(
    BuildContext context,
    WidgetRef ref, {
    required Song song,
    Offset? tapPosition,
  }) {
    // 桌面端使用 PopupMenu（如果有 tapPosition），移动端使用 BottomSheet
    final isMobile = tapPosition == null;
    if (isMobile) {
      _showBottomSheet(context, ref, song: song);
    } else {
      _showPopupMenu(context, ref, song: song, position: tapPosition);
    }
  }

  /// 桌面端弹出菜单
  static Future<void> _showPopupMenu(
    BuildContext context,
    WidgetRef ref, {
    required Song song,
    required Offset position,
  }) async {
    final favorites = ref.read(favoritesNotifierProvider);
    final isFavorite = favorites.contains(song.id);
    final isDownloaded = ref.read(isDownloadedProvider(song.id));

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu<_MenuAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem(
          value: _MenuAction.addToPlaylist,
          child: ListTile(
            leading: Icon(Icons.playlist_add_rounded),
            title: Text('添加到播放列表'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.toggleFavorite,
          child: ListTile(
            leading: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            title: Text(isFavorite ? '取消收藏' : '收藏'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (!isDownloaded)
          const PopupMenuItem(
            value: _MenuAction.download,
            child: ListTile(
              leading: Icon(Icons.download_rounded),
              title: Text('下载'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );

    if (result != null && context.mounted) {
      _handleAction(context, ref, action: result, song: song);
    }
  }

  /// 移动端底部弹出列表
  static void _showBottomSheet(
    BuildContext context,
    WidgetRef ref, {
    required Song song,
  }) {
    final favorites = ref.read(favoritesNotifierProvider);
    final isFavorite = favorites.contains(song.id);
    final isDownloaded = ref.read(isDownloadedProvider(song.id));

    showModalBottomSheet<_MenuAction>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 歌曲标题
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  song.title,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                song.artist,
                style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: Theme.of(sheetContext)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded),
                title: const Text('添加到播放列表'),
                onTap: () =>
                    Navigator.pop(sheetContext, _MenuAction.addToPlaylist),
              ),
              ListTile(
                leading: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
                title: Text(isFavorite ? '取消收藏' : '收藏'),
                onTap: () =>
                    Navigator.pop(sheetContext, _MenuAction.toggleFavorite),
              ),
              if (!isDownloaded)
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('下载'),
                  onTap: () =>
                      Navigator.pop(sheetContext, _MenuAction.download),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    ).then((result) {
      if (result != null && context.mounted) {
        _handleAction(context, ref, action: result, song: song);
      }
    });
  }

  /// 处理菜单操作
  static void _handleAction(
    BuildContext context,
    WidgetRef ref, {
    required _MenuAction action,
    required Song song,
  }) {
    switch (action) {
      case _MenuAction.addToPlaylist:
        _showPlaylistPicker(context, ref, song: song);
      case _MenuAction.toggleFavorite:
        ref.read(favoritesNotifierProvider.notifier).toggleFavorite(song.id);
      case _MenuAction.download:
        final manager = ref.read(downloadManagerProvider).valueOrNull;
        if (manager == null) return;
        manager.enqueueDownload(song);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已开始下载: ${song.title}')),
        );
    }
  }

  /// 播放列表选择对话框
  static void _showPlaylistPicker(
    BuildContext context,
    WidgetRef ref, {
    required Song song,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _PlaylistPickerDialog(song: song),
    );
  }
}

enum _MenuAction { addToPlaylist, toggleFavorite, download }

/// 播放列表选择对话框，支持选择现有播放列表或新建。
class _PlaylistPickerDialog extends ConsumerWidget {
  const _PlaylistPickerDialog({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('添加到播放列表'),
      content: SizedBox(
        width: 320,
        child: playlistsAsync.when(
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('获取播放列表失败: $e'),
          data: (playlists) {
            if (playlists.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('暂无播放列表，请先创建一个。'),
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
                    subtitle: Text('${playlist.songCount} 首歌曲'),
                    onTap: () => _addToPlaylist(
                      context,
                      ref,
                      playlist: playlist,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => _showNewPlaylistDialog(context, ref),
          child: const Text('新建播放列表'),
        ),
      ],
    );
  }

  Future<void> _addToPlaylist(
    BuildContext context,
    WidgetRef ref, {
    required Playlist playlist,
  }) async {
    Navigator.pop(context);

    try {
      await ref
          .read(playlistCrudNotifierProvider.notifier)
          .addSongToPlaylist(playlist.id, song.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已添加到「${playlist.name}」')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    }
  }

  void _showNewPlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('新建播放列表'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '播放列表名称',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _createAndAdd(dialogContext, ref, controller),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => _createAndAdd(dialogContext, ref, controller),
            child: const Text('创建并添加'),
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
    if (name.isEmpty) return;

    Navigator.pop(context); // 关闭新建对话框
    // 如果播放列表选择对话框还在，也关闭
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    try {
      // 创建播放列表（带初始歌曲）
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.createPlaylist(name: name, songIds: [song.id]);
      ref.invalidate(playlistsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已创建「$name」并添加歌曲')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }
}
