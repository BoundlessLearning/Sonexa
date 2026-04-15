import 'package:just_audio/just_audio.dart';

enum PlaybackHealthDecisionType {
  notPlaying,
  nearEnd,
  loadingOrBuffering,
  safeBufferedHeadroom,
  seekGuardActive,
  staleBuffer,
  attemptRecovery,
  healthy,
}

class PlaybackHealthDecision {
  const PlaybackHealthDecision({
    required this.type,
    required this.staleBufferCount,
    required this.previousStaleBufferCount,
    required this.bufferedHeadroom,
  });

  final PlaybackHealthDecisionType type;
  final int staleBufferCount;
  final int previousStaleBufferCount;
  final Duration bufferedHeadroom;

  bool get shouldAttemptRecovery =>
      type == PlaybackHealthDecisionType.attemptRecovery;
}

class PlaybackRecoveryPolicy {
  PlaybackRecoveryPolicy({
    this.maxStaleBufferChecks = 3,
    this.bufferedHeadroomSafeZone = const Duration(seconds: 12),
  });

  final int maxStaleBufferChecks;
  final Duration bufferedHeadroomSafeZone;

  Duration _lastBufferedPosition = Duration.zero;
  int _staleBufferCount = 0;

  void reset({Duration lastBufferedPosition = Duration.zero}) {
    _staleBufferCount = 0;
    _lastBufferedPosition = lastBufferedPosition;
  }

  PlaybackHealthDecision checkHealth({
    required bool playing,
    required Duration currentBuffered,
    required Duration currentPosition,
    required Duration? duration,
    required ProcessingState processingState,
    required bool seekGuardActive,
  }) {
    final bufferedHeadroom =
        currentBuffered > currentPosition
            ? currentBuffered - currentPosition
            : Duration.zero;
    final previousStaleCount = _staleBufferCount;

    if (!playing) {
      reset();
      return _decision(
        PlaybackHealthDecisionType.notPlaying,
        previousStaleCount,
        bufferedHeadroom,
      );
    }

    if (duration != null &&
        currentPosition.inMilliseconds > 0 &&
        currentPosition >= duration - const Duration(seconds: 2)) {
      _staleBufferCount = 0;
      return _decision(
        PlaybackHealthDecisionType.nearEnd,
        previousStaleCount,
        bufferedHeadroom,
      );
    }

    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      reset(lastBufferedPosition: currentBuffered);
      return _decision(
        PlaybackHealthDecisionType.loadingOrBuffering,
        previousStaleCount,
        bufferedHeadroom,
      );
    }

    if (bufferedHeadroom >= bufferedHeadroomSafeZone) {
      reset(lastBufferedPosition: currentBuffered);
      return _decision(
        PlaybackHealthDecisionType.safeBufferedHeadroom,
        previousStaleCount,
        bufferedHeadroom,
      );
    }

    if (seekGuardActive) {
      reset(lastBufferedPosition: currentBuffered);
      return _decision(
        PlaybackHealthDecisionType.seekGuardActive,
        previousStaleCount,
        bufferedHeadroom,
      );
    }

    if (currentBuffered == _lastBufferedPosition &&
        currentBuffered.inMilliseconds > 0) {
      _staleBufferCount++;
      final currentStaleCount = _staleBufferCount;
      if (_staleBufferCount >= maxStaleBufferChecks) {
        _staleBufferCount = 0;
        _lastBufferedPosition = currentBuffered;
        return PlaybackHealthDecision(
          type: PlaybackHealthDecisionType.attemptRecovery,
          staleBufferCount: currentStaleCount,
          previousStaleBufferCount: previousStaleCount,
          bufferedHeadroom: bufferedHeadroom,
        );
      }
      _lastBufferedPosition = currentBuffered;
      return PlaybackHealthDecision(
        type: PlaybackHealthDecisionType.staleBuffer,
        staleBufferCount: currentStaleCount,
        previousStaleBufferCount: previousStaleCount,
        bufferedHeadroom: bufferedHeadroom,
      );
    }

    reset(lastBufferedPosition: currentBuffered);
    return _decision(
      PlaybackHealthDecisionType.healthy,
      previousStaleCount,
      bufferedHeadroom,
    );
  }

  PlaybackHealthDecision _decision(
    PlaybackHealthDecisionType type,
    int previousStaleCount,
    Duration bufferedHeadroom,
  ) {
    return PlaybackHealthDecision(
      type: type,
      staleBufferCount: _staleBufferCount,
      previousStaleBufferCount: previousStaleCount,
      bufferedHeadroom: bufferedHeadroom,
    );
  }
}
