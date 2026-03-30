import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ohmymusic/core/utils/diagnostic_logger.dart';
import 'package:ohmymusic/core/utils/formatters.dart';
import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

class QueuePage extends ConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('播放队列'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<MediaItem>>(
        stream: audioHandler.queue,
        builder: (context, queueSnapshot) {
          final queue = queueSnapshot.data ?? [];

          if (queue.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '播放队列为空',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, mediaSnapshot) {
              final currentItem = mediaSnapshot.data;

              return ReorderableListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: queue.length,
                onReorder: (oldIndex, newIndex) {
                  // ReorderableListView 向下拖动时需要手动修正索引。
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }

                   DiagnosticLogger.instance.log(
                     '[OP] queue_reorder: oldIndex=$oldIndex, newIndex=$newIndex',
                   );

                   audioHandler.moveQueueItem(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final item = queue[index];
                  final isCurrent = currentItem?.id == item.id &&
                      currentItem?.title == item.title;

                  return Dismissible(
                    key: ValueKey('${item.id}_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      color: colorScheme.errorContainer,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                    onDismissed: (_) {
                      DiagnosticLogger.instance.log(
                        '[OP] queue_remove: index=$index, title=${item.title}',
                      );
                      audioHandler.removeFromQueue(index);
                    },
                    child: ListTile(
                      key: ValueKey('tile_${item.id}_$index'),
                      onTap: () {
                        DiagnosticLogger.instance.log(
                          '[OP] queue_tap: index=$index, title=${item.title}',
                        );
                        audioHandler.skipToQueueItem(index);
                      },
                      leading: isCurrent
                          ? Icon(
                              Icons.equalizer_rounded,
                              color: colorScheme.primary,
                            )
                          : Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: item.artUri != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.artUri.toString(),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.music_note,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.music_note,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                            ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          color: isCurrent ? colorScheme.primary : null,
                          fontWeight: isCurrent ? FontWeight.w600 : null,
                        ),
                      ),
                      subtitle: Text(
                        item.artist ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: isCurrent
                              ? colorScheme.primary.withValues(alpha: 0.7)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.duration != null)
                            Text(
                              formatDuration(item.duration!.inSeconds),
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(width: 8),
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(
                              Icons.drag_handle_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
