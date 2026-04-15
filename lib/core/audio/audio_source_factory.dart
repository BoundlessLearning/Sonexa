import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioSourceFactory {
  const AudioSourceFactory();

  AudioSource fromMediaItem(MediaItem item) {
    final isLocal = item.extras?['isLocal'] == true;
    final uri = isLocal ? Uri.file(item.id) : Uri.parse(item.id);
    return AudioSource.uri(uri, tag: item);
  }

  bool isRawStreamItem(MediaItem item) {
    final uri = Uri.tryParse(item.id);
    if (uri == null) {
      return false;
    }
    return (uri.queryParameters['format'] ?? '').isEmpty;
  }

  bool hasMp3FallbackAttempted(MediaItem item) {
    return item.extras?['fallbackFormat'] == 'mp3';
  }

  bool requiresFreshDecoder(MediaItem item) {
    if (item.extras?['isLocal'] == true) {
      final suffix = (item.extras?['sourceSuffix'] as String?)?.toLowerCase();
      return suffix == 'wav';
    }

    final sourceSuffix =
        (item.extras?['sourceSuffix'] as String?)?.toLowerCase();
    final streamFormat =
        (item.extras?['streamFormat'] as String?)?.toLowerCase();
    return sourceSuffix == 'wav' || streamFormat == 'mp3';
  }

  MediaItem withMp3Fallback(MediaItem item) {
    final songId = _songIdOf(item);
    final uri = Uri.tryParse(item.id);
    if (songId.isEmpty || uri == null) {
      return item;
    }

    final queryParameters = Map<String, String>.from(uri.queryParameters);
    queryParameters['format'] = 'mp3';
    final fallbackUri =
        uri.replace(queryParameters: queryParameters).toString();

    return item.copyWith(
      id: fallbackUri,
      extras: {...?item.extras, 'fallbackFormat': 'mp3'},
    );
  }

  String _songIdOf(MediaItem item) =>
      item.extras?['songId'] as String? ?? item.id;
}
