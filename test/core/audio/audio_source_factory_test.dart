import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sonexa/core/audio/audio_source_factory.dart';

void main() {
  group('AudioSourceFactory', () {
    const factory = AudioSourceFactory();

    test('builds remote sources from media item id', () {
      const item = MediaItem(
        id: 'https://music.test/rest/stream.view?id=song-1',
        title: 'Remote Track',
      );

      final source = factory.fromMediaItem(item);

      expect(source, isA<UriAudioSource>());
      expect((source as UriAudioSource).uri.toString(), item.id);
      expect(source.tag, same(item));
    });

    test('builds local sources from file path media items', () {
      const item = MediaItem(
        id: r'C:\Music\song.wav',
        title: 'Local Track',
        extras: {'isLocal': true},
      );

      final source = factory.fromMediaItem(item);

      expect(source, isA<UriAudioSource>());
      expect((source as UriAudioSource).uri, Uri.file(item.id));
      expect(source.tag, same(item));
    });

    test('detects raw stream and mp3 fallback attempts', () {
      const rawItem = MediaItem(
        id: 'https://music.test/rest/stream.view?id=song-1',
        title: 'Raw Track',
      );
      const encodedItem = MediaItem(
        id: 'https://music.test/rest/stream.view?id=song-1&format=mp3',
        title: 'Encoded Track',
      );
      const fallbackItem = MediaItem(
        id: 'https://music.test/rest/stream.view?id=song-1&format=mp3',
        title: 'Fallback Track',
        extras: {'fallbackFormat': 'mp3'},
      );

      expect(factory.isRawStreamItem(rawItem), isTrue);
      expect(factory.isRawStreamItem(encodedItem), isFalse);
      expect(factory.hasMp3FallbackAttempted(rawItem), isFalse);
      expect(factory.hasMp3FallbackAttempted(fallbackItem), isTrue);
    });

    test('requires fresh decoder for wav sources and mp3 streams', () {
      const localWav = MediaItem(
        id: r'C:\Music\song.wav',
        title: 'Local Wav',
        extras: {'isLocal': true, 'sourceSuffix': 'wav'},
      );
      const remoteMp3 = MediaItem(
        id: 'https://music.test/rest/stream.view?id=song-1&format=mp3',
        title: 'Remote Mp3',
        extras: {'streamFormat': 'mp3'},
      );
      const remoteFlac = MediaItem(
        id: 'https://music.test/rest/stream.view?id=song-1',
        title: 'Remote Flac',
        extras: {'sourceSuffix': 'flac', 'streamFormat': 'raw'},
      );

      expect(factory.requiresFreshDecoder(localWav), isTrue);
      expect(factory.requiresFreshDecoder(remoteMp3), isTrue);
      expect(factory.requiresFreshDecoder(remoteFlac), isFalse);
    });

    test('creates mp3 fallback item without dropping extras', () {
      const item = MediaItem(
        id: 'https://music.test/rest/stream.view?id=song-1&maxBitRate=0',
        title: 'Raw Track',
        extras: {'songId': 'song-1', 'artistId': 'artist-1'},
      );

      final fallbackItem = factory.withMp3Fallback(item);
      final uri = Uri.parse(fallbackItem.id);

      expect(uri.queryParameters['id'], 'song-1');
      expect(uri.queryParameters['maxBitRate'], '0');
      expect(uri.queryParameters['format'], 'mp3');
      expect(fallbackItem.extras?['songId'], 'song-1');
      expect(fallbackItem.extras?['artistId'], 'artist-1');
      expect(fallbackItem.extras?['fallbackFormat'], 'mp3');
    });
  });
}
