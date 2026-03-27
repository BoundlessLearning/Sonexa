import 'package:audio_service/audio_service.dart';

import '../../features/library/domain/entities/song.dart';

extension SongToMediaItem on Song {
  /// 构建 MediaItem，优先使用本地文件路径（离线播放），否则使用流媒体 URL。
  MediaItem toMediaItem(String streamUrl, String coverArtUrl) {
    // 优先使用已下载的本地文件
    final audioUrl = (localFilePath != null && localFilePath!.isNotEmpty)
        ? localFilePath!
        : streamUrl;

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
        'isLocal': localFilePath != null && localFilePath!.isNotEmpty,
      },
    );
  }
}
