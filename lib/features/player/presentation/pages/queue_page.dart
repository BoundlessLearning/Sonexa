import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/core/utils/formatters.dart';
import 'package:sonexa/core/widgets/app_image.dart';
import 'package:sonexa/features/player/presentation/providers/player_provider.dart';

final _queueDiag = DiagnosticLogger.instance.module('queue');

class QueuePage extends ConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final currentSong = ref.watch(currentSongProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.queueTitle), centerTitle: true),
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
                    l10n.queueEmpty,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: queue.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }

              _queueDiag.event(
                'reorder',
                fields: {'oldIndex': oldIndex, 'newIndex': newIndex},
              );
              audioHandler.moveQueueItem(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final item = queue[index];
              final itemSongId = item.extras?['songId'] as String? ?? item.id;
              final isCurrent = currentSong?.id == itemSongId;

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
                  _queueDiag.event('remove', fields: {'index': index});
                  audioHandler.removeFromQueue(index);
                },
                child: ListTile(
                  key: ValueKey('tile_${item.id}_$index'),
                  onTap: () {
                    _queueDiag.event('tap', fields: {'index': index});
                    audioHandler.skipToQueueItem(index);
                  },
                  leading:
                      isCurrent
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
                            child: AppImage(
                              url: item.artUri?.toString(),
                              size: 44,
                              borderRadius: 8,
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
                      color:
                          isCurrent
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
      ),
    );
  }
}
