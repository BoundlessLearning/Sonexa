import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ohmymusic/core/audio/media_item_converter.dart';
import 'package:ohmymusic/features/home/presentation/providers/home_provider.dart';
import 'package:ohmymusic/features/library/domain/entities/song.dart';
import 'package:ohmymusic/features/library/presentation/widgets/song_list_tile.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

/// 通用歌曲列表页面，根据传入的 provider 和标题显示完整歌曲列表。
/// 用于首页各分区的「查看更多」跳转。
class SongListPage extends ConsumerWidget {
  const SongListPage({
    super.key,
    required this.title,
    required this.provider,
    this.emptyMessage = '暂无歌曲',
  });

  final String title;
  final FutureProvider<List<Song>> provider;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: songsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('加载失败: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(provider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (songs) {
          if (songs.isEmpty) {
            return Center(
              child: Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }

          return ListView.builder(
            itemCount: songs.length,
            padding: const EdgeInsets.only(bottom: 100),
            itemBuilder: (context, index) {
              final song = songs[index];
              final api = ref.read(subsonicApiClientProvider).valueOrNull;
              final coverUrl =
                  api?.getCoverArtUrl(song.coverArtId, size: 300);

              return SongListTile(
                song: song,
                coverArtUrl: coverUrl,
                onTap: () => _playSongs(ref, songs, index),
              );
            },
          );
        },
      ),
    );
  }

  void _playSongs(WidgetRef ref, List<Song> songs, int index) {
    final api = ref.read(subsonicApiClientProvider).valueOrNull;
    if (api == null) return;
    final audioHandler = ref.read(audioHandlerProvider);
    final items = songs
        .map((s) => s.toMediaItem(
              api.getStreamUrl(s.id),
              api.getCoverArtUrl(s.coverArtId, size: 300),
            ))
        .toList();
    audioHandler.loadAndPlay(items, initialIndex: index);
  }
}
