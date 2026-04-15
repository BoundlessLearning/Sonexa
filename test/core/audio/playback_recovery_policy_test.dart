import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sonexa/core/audio/playback_recovery_policy.dart';

void main() {
  group('PlaybackRecoveryPolicy', () {
    test('attempts recovery after repeated stale buffered position', () {
      final policy = PlaybackRecoveryPolicy(maxStaleBufferChecks: 3);

      expect(
        policy
            .checkHealth(
              playing: true,
              currentBuffered: const Duration(seconds: 10),
              currentPosition: const Duration(seconds: 8),
              duration: const Duration(minutes: 3),
              processingState: ProcessingState.ready,
              seekGuardActive: false,
            )
            .type,
        PlaybackHealthDecisionType.healthy,
      );

      expect(
        policy
            .checkHealth(
              playing: true,
              currentBuffered: const Duration(seconds: 10),
              currentPosition: const Duration(seconds: 9),
              duration: const Duration(minutes: 3),
              processingState: ProcessingState.ready,
              seekGuardActive: false,
            )
            .type,
        PlaybackHealthDecisionType.staleBuffer,
      );

      policy.checkHealth(
        playing: true,
        currentBuffered: const Duration(seconds: 10),
        currentPosition: const Duration(seconds: 10),
        duration: const Duration(minutes: 3),
        processingState: ProcessingState.ready,
        seekGuardActive: false,
      );

      final decision = policy.checkHealth(
        playing: true,
        currentBuffered: const Duration(seconds: 10),
        currentPosition: const Duration(seconds: 11),
        duration: const Duration(minutes: 3),
        processingState: ProcessingState.ready,
        seekGuardActive: false,
      );

      expect(decision.type, PlaybackHealthDecisionType.attemptRecovery);
      expect(decision.staleBufferCount, 3);
      expect(decision.shouldAttemptRecovery, isTrue);
    });

    test('resets stale count when buffered headroom is safe', () {
      final policy = PlaybackRecoveryPolicy();

      policy.checkHealth(
        playing: true,
        currentBuffered: const Duration(seconds: 10),
        currentPosition: const Duration(seconds: 8),
        duration: const Duration(minutes: 3),
        processingState: ProcessingState.ready,
        seekGuardActive: false,
      );
      policy.checkHealth(
        playing: true,
        currentBuffered: const Duration(seconds: 10),
        currentPosition: const Duration(seconds: 9),
        duration: const Duration(minutes: 3),
        processingState: ProcessingState.ready,
        seekGuardActive: false,
      );

      final decision = policy.checkHealth(
        playing: true,
        currentBuffered: const Duration(seconds: 30),
        currentPosition: const Duration(seconds: 10),
        duration: const Duration(minutes: 3),
        processingState: ProcessingState.ready,
        seekGuardActive: false,
      );

      expect(decision.type, PlaybackHealthDecisionType.safeBufferedHeadroom);
      expect(decision.previousStaleBufferCount, 1);
      expect(decision.staleBufferCount, 0);
    });

    test('does not count loading or buffering as stale', () {
      final policy = PlaybackRecoveryPolicy();

      final decision = policy.checkHealth(
        playing: true,
        currentBuffered: const Duration(seconds: 10),
        currentPosition: const Duration(seconds: 8),
        duration: const Duration(minutes: 3),
        processingState: ProcessingState.buffering,
        seekGuardActive: false,
      );

      expect(decision.type, PlaybackHealthDecisionType.loadingOrBuffering);
      expect(decision.staleBufferCount, 0);
    });

    test('suppresses stale recovery during seek guard window', () {
      final policy = PlaybackRecoveryPolicy(maxStaleBufferChecks: 1);

      policy.checkHealth(
        playing: true,
        currentBuffered: const Duration(seconds: 10),
        currentPosition: const Duration(seconds: 8),
        duration: const Duration(minutes: 3),
        processingState: ProcessingState.ready,
        seekGuardActive: false,
      );
      final decision = policy.checkHealth(
        playing: true,
        currentBuffered: const Duration(seconds: 10),
        currentPosition: const Duration(seconds: 9),
        duration: const Duration(minutes: 3),
        processingState: ProcessingState.ready,
        seekGuardActive: true,
      );

      expect(decision.type, PlaybackHealthDecisionType.seekGuardActive);
      expect(decision.shouldAttemptRecovery, isFalse);
    });

    test('resets while not playing and near track end', () {
      final policy = PlaybackRecoveryPolicy();

      expect(
        policy
            .checkHealth(
              playing: false,
              currentBuffered: Duration.zero,
              currentPosition: Duration.zero,
              duration: null,
              processingState: ProcessingState.ready,
              seekGuardActive: false,
            )
            .type,
        PlaybackHealthDecisionType.notPlaying,
      );

      expect(
        policy
            .checkHealth(
              playing: true,
              currentBuffered: const Duration(seconds: 179),
              currentPosition: const Duration(seconds: 178),
              duration: const Duration(minutes: 3),
              processingState: ProcessingState.ready,
              seekGuardActive: false,
            )
            .type,
        PlaybackHealthDecisionType.nearEnd,
      );
    });
  });
}
