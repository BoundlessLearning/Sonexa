import 'dart:math';

enum PlaybackMode { sequential, shuffle, repeatOne, repeatAll }

typedef RandomIndexResolver = int Function(int max);

class PlaybackModeController {
  PlaybackModeController({
    Random? random,
    RandomIndexResolver? randomIndexResolver,
  }) : _random = random ?? Random(),
       _randomIndexResolver = randomIndexResolver;

  static const int shuffleHistoryLimit = 100;

  final Random _random;
  final RandomIndexResolver? _randomIndexResolver;
  final List<String> _shufflePreviousHistory = [];
  PlaybackMode _mode = PlaybackMode.sequential;

  PlaybackMode get mode => _mode;

  bool get shuffleEnabled => _mode == PlaybackMode.shuffle;

  int get shuffleHistoryLength => _shufflePreviousHistory.length;

  void setMode(PlaybackMode mode) {
    _mode = mode;
  }

  void setShuffleEnabled(bool enabled) {
    _mode = enabled ? PlaybackMode.shuffle : PlaybackMode.sequential;
  }

  int? resolveNextIndex({required int currentIndex, required int total}) {
    if (total <= 0) {
      return null;
    }

    return switch (_mode) {
      PlaybackMode.sequential =>
        currentIndex < total - 1 ? currentIndex + 1 : null,
      PlaybackMode.shuffle => _randomDifferentIndex(currentIndex, total),
      PlaybackMode.repeatOne => currentIndex,
      PlaybackMode.repeatAll => (currentIndex + 1) % total,
    };
  }

  int? resolvePreviousIndex({
    required int currentIndex,
    required List<String> queueSongIds,
  }) {
    final total = queueSongIds.length;
    if (total <= 0) {
      return null;
    }

    return switch (_mode) {
      PlaybackMode.sequential => currentIndex > 0 ? currentIndex - 1 : null,
      PlaybackMode.shuffle => _popShufflePreviousIndex(
        currentIndex: currentIndex,
        queueSongIds: queueSongIds,
      ),
      PlaybackMode.repeatOne => currentIndex,
      PlaybackMode.repeatAll => (currentIndex - 1 + total) % total,
    };
  }

  int? recordShuffleHistory({
    required String fromSongId,
    required String targetSongId,
    required String reason,
  }) {
    if (_mode != PlaybackMode.shuffle) {
      return null;
    }
    if (fromSongId.isEmpty || targetSongId.isEmpty) {
      return null;
    }
    if (reason == 'skipToPrevious') {
      return null;
    }
    if (fromSongId == targetSongId) {
      return null;
    }

    _shufflePreviousHistory.add(fromSongId);
    if (_shufflePreviousHistory.length > shuffleHistoryLimit) {
      _shufflePreviousHistory.removeAt(0);
    }
    return _shufflePreviousHistory.length;
  }

  bool resetShuffleHistory() {
    if (_shufflePreviousHistory.isEmpty) {
      return false;
    }
    _shufflePreviousHistory.clear();
    return true;
  }

  int? _randomDifferentIndex(int currentIndex, int total) {
    if (total <= 0) {
      return null;
    }
    if (total == 1) {
      return 0;
    }

    var candidate = currentIndex;
    while (candidate == currentIndex) {
      candidate = _randomIndexResolver?.call(total) ?? _random.nextInt(total);
    }
    return candidate;
  }

  int? _popShufflePreviousIndex({
    required int currentIndex,
    required List<String> queueSongIds,
  }) {
    final total = queueSongIds.length;
    while (_shufflePreviousHistory.isNotEmpty) {
      final candidateSongId = _shufflePreviousHistory.removeLast();
      final candidate = queueSongIds.indexOf(candidateSongId);
      if (candidate < 0 || candidate >= total) {
        continue;
      }
      if (candidate == currentIndex) {
        continue;
      }
      return candidate;
    }
    return null;
  }
}
