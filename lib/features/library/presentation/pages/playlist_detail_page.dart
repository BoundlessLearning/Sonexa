import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:ohmymusic/core/audio/media_item_converter.dart';
import 'package:ohmymusic/core/utils/formatters.dart';
import 'package:ohmymusic/core/widgets/app_image.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';
import 'package:ohmymusic/features/library/presentation/providers/playlist_provider.dart';
import 'package:ohmymusic/features/library/presentation/widgets/song_list_tile.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

/// 播放列表详情页 — 展示播放列表封面、元数据、歌曲列表
class PlaylistDetailPage extends ConsumerWidget {
  const PlaylistDetailPage({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistDetailProvider(playlistId));

    return Scaffold(
      body: playlistAsync.when(
        loading: () => _buildShimmerLoading(context),
        error: (error, stack) => _buildError(context, ref, error),
        data: (playlist) {
          final api = ref.read(subsonicApiClientProvider).requireValue;
          final songs = playlist.songs;
          // 播放列表封面 URL（高分辨率）
          final coverUrl = api.getCoverArtUrl(playlist.coverArtId, size: 600);

          return CustomScrollView(
            slivers: [
              // ── 顶部折叠头图 ──────────────────────────────
              SliverAppBar.large(
                pinned: true,
                expandedHeight: 320,
                title: Text(playlist.name),
                actions: [
                  IconButton(
                    tooltip: '编辑名称',
                    onPressed: () => _showRenameDialog(context, ref, playlist.id, playlist.name),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: '删除播放列表',
                    onPressed: () => _confirmDelete(context, ref, playlist.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(url: coverUrl, borderRadius: 0),
                      // 底部渐变遮罩，保证文字可读
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 播放列表信息 ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 播放列表名称
                      Text(
                        playlist.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      // 创建者
                      if (playlist.owner.isNotEmpty)
                        Text(
                          playlist.owner,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      const SizedBox(height: 4),
                      // 歌曲数 · 总时长
                      Text(
                        [
                          '${playlist.songCount} 首歌曲',
                          formatDuration(playlist.duration),
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      // 备注
                      if (playlist.comment != null &&
                          playlist.comment!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          playlist.comment!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── 播放全部按钮 ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton.icon(
                    onPressed: songs.isEmpty
                        ? null
                        : () => _playFromIndex(ref, songs, 0),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('播放全部'),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── 歌曲列表 ──────────────────────────────────
              if (songs.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('暂无歌曲'),
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final songCoverUrl = api.getCoverArtUrl(song.coverArtId);

                    return SongListTile(
                      song: song,
                      coverArtUrl: songCoverUrl,
                      onTap: () => _playFromIndex(ref, songs, index),
                    );
                  },
                ),

              // 底部留白（给迷你播放器让位）
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  // ── 从指定位置开始播放 ────────────────────────────────────
  void _playFromIndex(WidgetRef ref, List<Song> songs, int index) {
    final api = ref.read(subsonicApiClientProvider).requireValue;
    final audioHandler = ref.read(audioHandlerProvider);

    final items = songs.map((song) {
      final streamUrl = api.getStreamUrl(song.id);
      final artUrl = api.getCoverArtUrl(song.coverArtId);
      return song.toMediaItem(streamUrl, artUrl);
    }).toList();

    audioHandler.loadAndPlay(items, initialIndex: index);
  }

  // ── 加载态 — 整页 shimmer ─────────────────────────────────
  Widget _buildShimmerLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            expandedHeight: 320,
            flexibleSpace: FlexibleSpaceBar(
              background:
                  Container(color: colorScheme.surfaceContainerHighest),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: 180,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildSongListShimmer(context),
        ],
      ),
    );
  }

  // ── 歌曲列表 shimmer ──────────────────────────────────────
  SliverList _buildSongListShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverList.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          title: Container(
            height: 14,
            width: 160,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Container(
            height: 12,
            width: 120,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  // ── 错误态 ────────────────────────────────────────────────
  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
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
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () {
              ref.invalidate(playlistDetailProvider(playlistId));
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    String playlistId,
    String initialName,
  ) async {
    final controller = TextEditingController(text: initialName);

    try {
      final name = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('编辑播放列表'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: '播放列表名称',
            ),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('保存'),
            ),
          ],
        ),
      );

      if (name == null || name.isEmpty || name == initialName || !context.mounted) {
        return;
      }

      await ref
          .read(playlistCrudNotifierProvider.notifier)
          .renamePlaylist(playlistId, name);

      final crudState = ref.read(playlistCrudNotifierProvider);
      if (!context.mounted) return;

      if (crudState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败：${crudState.error}')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('播放列表已更新')),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String playlistId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除播放列表'),
        content: const Text('删除后无法恢复，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref.read(playlistCrudNotifierProvider.notifier).deletePlaylist(playlistId);
    final crudState = ref.read(playlistCrudNotifierProvider);
    if (!context.mounted) return;

    if (crudState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：${crudState.error}')),
      );
      return;
    }

    ref.invalidate(playlistDetailProvider(playlistId));
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('播放列表已删除')),
    );
  }
}
