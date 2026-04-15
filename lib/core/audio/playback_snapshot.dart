import 'package:audio_service/audio_service.dart';

class PlaybackSnapshot {
  const PlaybackSnapshot({
    required this.playbackState,
    required this.queue,
    required this.queueIndex,
    required this.currentItem,
    required this.playing,
    required this.processingState,
    required this.position,
    required this.bufferedPosition,
  });

  final PlaybackState playbackState;
  final List<MediaItem> queue;
  final int? queueIndex;
  final MediaItem? currentItem;
  final bool playing;
  final AudioProcessingState processingState;
  final Duration position;
  final Duration bufferedPosition;

  Duration get duration => currentItem?.duration ?? Duration.zero;
}
