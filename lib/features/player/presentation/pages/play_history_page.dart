import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/features/player/presentation/providers/play_history_provider.dart';

class PlayHistoryPage extends ConsumerWidget {
  const PlayHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(playHistoryNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.playHistoryTitle), centerTitle: true),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.playHistoryLoadFailed,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$error',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed:
                          () =>
                              ref
                                  .read(playHistoryNotifierProvider.notifier)
                                  .refresh(),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.playHistoryEmpty,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: history.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = history[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.music_note_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                title: Text(
                  item.songTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatRelativeTime(context, item.playedAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatRelativeTime(BuildContext context, DateTime playedAt) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(playedAt);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    }

    if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    }

    if (difference.inDays < 1) {
      return l10n.hoursAgo(difference.inHours);
    }

    if (difference.inDays == 1) {
      return l10n.yesterday;
    }

    return l10n.daysAgo(difference.inDays);
  }
}
