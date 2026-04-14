import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sonexa/features/lyrics/domain/entities/lyrics.dart';
import 'package:sonexa/features/lyrics/presentation/providers/lyrics_provider.dart';

/// 歌词联网搜索页面。
/// 接收 songId、artist、title 参数，搜索 lrclib 并展示候选歌词供用户选择替换。
class LyricsSearchPage extends ConsumerStatefulWidget {
  const LyricsSearchPage({
    super.key,
    required this.songId,
    required this.artist,
    required this.title,
  });

  final String songId;
  final String artist;
  final String title;

  @override
  ConsumerState<LyricsSearchPage> createState() => _LyricsSearchPageState();
}

class _LyricsSearchPageState extends ConsumerState<LyricsSearchPage> {
  late TextEditingController _artistController;
  late TextEditingController _titleController;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _artistController = TextEditingController(text: widget.artist);
    _titleController = TextEditingController(text: widget.title);
    // 自动触发首次搜索
    _searchQuery = '${widget.songId}|${widget.artist}|${widget.title}';
  }

  @override
  void dispose() {
    _artistController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _doSearch() {
    final artist = _artistController.text.trim();
    final title = _titleController.text.trim();
    if (artist.isEmpty && title.isEmpty) return;

    setState(() {
      _searchQuery = '${widget.songId}|$artist|$title';
    });
    // 使搜索结果失效以触发重新拉取
    ref.invalidate(lyricsSearchProvider(_searchQuery!));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索歌词'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 搜索表单
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _artistController,
                  decoration: const InputDecoration(
                    labelText: '歌手',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _doSearch(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '歌曲名',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _doSearch(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _doSearch,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('搜索'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 搜索结果列表
          Expanded(
            child: _searchQuery == null
                ? Center(
                    child: Text(
                      '输入歌手和歌曲名进行搜索',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : _SearchResultList(
                    searchQuery: _searchQuery!,
                    songId: widget.songId,
                    artist: widget.artist,
                    title: widget.title,
                  ),
          ),
        ],
      ),
    );
  }
}

/// 搜索结果列表组件
class _SearchResultList extends ConsumerWidget {
  const _SearchResultList({
    required this.searchQuery,
    required this.songId,
    required this.artist,
    required this.title,
  });

  final String searchQuery;
  final String songId;
  final String artist;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(lyricsSearchProvider(searchQuery));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('搜索失败: $e',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Text(
              '未找到歌词',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final lyrics = results[index];
            // 预览前 3 行歌词
            final preview = lyrics.lines
                .take(3)
                .map((l) => l.text)
                .join('\n');

            return ListTile(
              title: Text(
                '${lyrics.isSynced ? "[同步] " : "[纯文本] "}'
                '${lyrics.lines.length} 行',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              trailing: FilledButton.tonal(
                onPressed: () => _applyLyrics(context, ref, lyrics),
                child: const Text('使用'),
              ),
              isThreeLine: true,
            );
          },
        );
      },
    );
  }

  /// 应用选中的歌词：写入缓存并刷新当前歌词 provider
  Future<void> _applyLyrics(
    BuildContext context,
    WidgetRef ref,
    Lyrics lyrics,
  ) async {
    try {
      final repo = await ref.read(lyricsRepositoryProvider.future);
      await repo.replaceLyrics(lyrics);
      // 刷新歌词 provider 使当前页面更新
      ref.invalidate(
        lyricsProvider(
          LyricsRequestSnapshot(
            songId: songId,
            artist: artist,
            title: title,
          ),
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('歌词已替换')),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('替换失败: $e')),
        );
      }
    }
  }
}
