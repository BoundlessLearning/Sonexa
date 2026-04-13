import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ohmymusic/features/player/presentation/providers/player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final currentSong = ref.watch(currentSongProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: currentSong != null ? 64 : 0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: currentSong == null
          ? const SizedBox.shrink()
          : GestureDetector(
              onTap: () => context.push('/now-playing'),
              child: StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, playbackSnapshot) {
                  final playing = playbackSnapshot.data?.playing ?? false;

                  return Material(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Hero(
                          tag: 'now-playing-cover',
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: currentSong.coverArtId != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      currentSong.coverArtId!,
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (currentSong.artist.isNotEmpty)
                                Text(
                                  currentSong.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          iconSize: 32,
                          color: colorScheme.onSurface,
                          onPressed: () {
                            if (playing) {
                              audioHandler.pause();
                            } else {
                              audioHandler.play();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded),
                          iconSize: 28,
                          color: colorScheme.onSurfaceVariant,
                          onPressed: audioHandler.skipToNext,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
