import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/core/audio/audio_diagnostics.dart';

void main() {
  group('AudioDiagnostics', () {
    const diagnostics = AudioDiagnostics();

    test('describes remote stream without leaking query noise', () {
      const item = MediaItem(
        id:
            'https://music.test/rest/stream.view?id=song-1&format=mp3&maxBitRate=320',
        title: 'North Star',
        extras: {'songId': 'song-1'},
      );

      final description = diagnostics.describeStream(item);

      expect(description, contains('songId=song-1'));
      expect(description, contains('title="North Star"'));
      expect(description, contains('isLocal=false'));
      expect(description, contains('host=music.test'));
      expect(description, contains('path=/rest/stream.view'));
      expect(description, contains('format=mp3'));
      expect(description, contains('maxBitRate=320'));
    });

    test('describes local stream paths', () {
      const item = MediaItem(
        id: r'C:\Music\song.wav',
        title: 'Local Song',
        extras: {'isLocal': true},
      );

      final description = diagnostics.describeStream(item);

      expect(description, contains(r'songId=C:\Music\song.wav'));
      expect(description, contains('isLocal=true'));
      expect(description, contains('host=<local>'));
      expect(description, contains('format=<raw>'));
      expect(description, contains('maxBitRate=<none>'));
    });
  });
}
