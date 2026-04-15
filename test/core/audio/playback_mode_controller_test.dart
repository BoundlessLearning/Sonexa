import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/core/audio/playback_mode_controller.dart';

void main() {
  group('PlaybackModeController', () {
    test('resolves sequential next and previous indexes', () {
      final controller = PlaybackModeController();

      expect(controller.resolveNextIndex(currentIndex: 0, total: 3), 1);
      expect(controller.resolveNextIndex(currentIndex: 2, total: 3), isNull);
      expect(
        controller.resolvePreviousIndex(
          currentIndex: 2,
          queueSongIds: ['a', 'b', 'c'],
        ),
        1,
      );
      expect(
        controller.resolvePreviousIndex(
          currentIndex: 0,
          queueSongIds: ['a', 'b', 'c'],
        ),
        isNull,
      );
    });

    test('resolves repeat modes', () {
      final controller = PlaybackModeController();

      controller.setMode(PlaybackMode.repeatOne);
      expect(controller.resolveNextIndex(currentIndex: 1, total: 3), 1);
      expect(
        controller.resolvePreviousIndex(
          currentIndex: 1,
          queueSongIds: ['a', 'b', 'c'],
        ),
        1,
      );

      controller.setMode(PlaybackMode.repeatAll);
      expect(controller.resolveNextIndex(currentIndex: 2, total: 3), 0);
      expect(
        controller.resolvePreviousIndex(
          currentIndex: 0,
          queueSongIds: ['a', 'b', 'c'],
        ),
        2,
      );
    });

    test('resolves shuffle next with a non-current random index', () {
      final controller = PlaybackModeController(randomIndexResolver: (_) => 2);
      controller.setMode(PlaybackMode.shuffle);

      expect(controller.resolveNextIndex(currentIndex: 0, total: 3), 2);
    });

    test('uses shuffle history for previous index', () {
      final controller = PlaybackModeController();
      controller.setMode(PlaybackMode.shuffle);

      final historySize = controller.recordShuffleHistory(
        fromSongId: 'song-a',
        targetSongId: 'song-c',
        reason: 'skipToNext',
      );

      expect(historySize, 1);
      expect(
        controller.resolvePreviousIndex(
          currentIndex: 2,
          queueSongIds: ['song-a', 'song-b', 'song-c'],
        ),
        0,
      );
      expect(
        controller.resolvePreviousIndex(
          currentIndex: 2,
          queueSongIds: ['song-a', 'song-b', 'song-c'],
        ),
        isNull,
      );
    });

    test('does not record shuffle history outside shuffle mode', () {
      final controller = PlaybackModeController();

      expect(
        controller.recordShuffleHistory(
          fromSongId: 'song-a',
          targetSongId: 'song-b',
          reason: 'skipToNext',
        ),
        isNull,
      );
      expect(controller.shuffleHistoryLength, 0);
    });

    test('resets shuffle history when requested', () {
      final controller = PlaybackModeController();
      controller.setMode(PlaybackMode.shuffle);
      controller.recordShuffleHistory(
        fromSongId: 'song-a',
        targetSongId: 'song-b',
        reason: 'skipToNext',
      );

      expect(controller.resetShuffleHistory(), isTrue);
      expect(controller.shuffleHistoryLength, 0);
      expect(controller.resetShuffleHistory(), isFalse);
    });
  });
}
