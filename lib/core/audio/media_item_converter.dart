import 'package:audio_service/audio_service.dart';

import '../../features/library/domain/entities/song.dart';

extension SongToMediaItem on Song {
  String? get preferredPlaybackFormat {
    final normalizedSuffix = suffix?.trim().toLowerCase().replaceFirst('.', '');
    return switch (normalizedSuffix) {
      'wav' => 'mp3',
      _ => null,
    };
  }

  MediaItem toMediaItem(String streamUrl, String coverArtUrl) {
    final hasLocalFile = localFilePath != null && localFilePath!.isNotEmpty;
    final normalizedSuffix = suffix?.trim().toLowerCase().replaceFirst('.', '');
    final streamFormat = preferredPlaybackFormat ?? 'raw';
    final useLocalFile = hasLocalFile && preferredPlaybackFormat == null;
    final audioUrl = useLocalFile ? localFilePath! : streamUrl;

    return MediaItem(
      id: audioUrl,
      title: title,
      artist: artist,
      album: album,
      artUri: Uri.tryParse(coverArtUrl),
      duration: Duration(seconds: duration),
      extras: {
        'songId': id,
        'albumId': albumId,
        'artistId': artistId,
        'hasLocalFile': hasLocalFile,
        'isLocal': useLocalFile,
        'sourceSuffix': normalizedSuffix,
        'streamFormat': streamFormat,
        'fallbackFormat': streamFormat,
      },
    );
  }
}
