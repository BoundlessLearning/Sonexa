import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:smtc_windows/smtc_windows.dart';

import 'package:ohmymusic/core/audio/audio_handler.dart';
import 'package:ohmymusic/core/utils/diagnostic_logger.dart';

/// Windows 系统媒体控制（SMTC）桥接。
///
/// 目标：
/// 1. 将当前播放状态同步到 Windows 系统媒体控制面板
/// 2. 将系统层的播放/暂停/切歌按钮回传给 MusicAudioHandler
class WindowsMediaControls {
  WindowsMediaControls._(this._audioHandler)
      : _smtc = SMTCWindows(
          config: const SMTCConfig(
            playEnabled: true,
            pauseEnabled: true,
            nextEnabled: true,
            prevEnabled: true,
            stopEnabled: true,
            fastForwardEnabled: false,
            rewindEnabled: false,
          ),
          status: PlaybackStatus.Stopped,
          timeline: const PlaybackTimeline(
            startTimeMs: 0,
            endTimeMs: 0,
            positionMs: 0,
          ),
        );

  static WindowsMediaControls? _instance;

  static Future<void> initialize(MusicAudioHandler audioHandler) async {
    if (!Platform.isWindows || kIsWeb) {
      return;
    }
    _instance ??= WindowsMediaControls._(audioHandler);
    await _instance!._init();
  }

  final MusicAudioHandler _audioHandler;
  final SMTCWindows _smtc;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _timelineTimer;
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _subscriptions.add(
      _smtc.buttonPressStream.listen((event) {
        unawaited(_handleButtonPress(event));
      }),
    );

    _subscriptions.add(
      _audioHandler.mediaItem.listen((item) {
        unawaited(_syncMetadata(item));
      }),
    );

    _subscriptions.add(
      _audioHandler.playbackState.listen((state) {
        unawaited(_syncPlaybackState(state));
      }),
    );

    _subscriptions.add(
      _audioHandler.queue.listen((queue) {
        unawaited(_syncQueueConfig(queue));
      }),
    );

    _timelineTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_syncTimeline());
    });

    await DiagnosticLogger.instance
        .log('[DIAG] Windows SMTC initialized');
  }

  Future<void> _handleButtonPress(PressedButton event) async {
    await DiagnosticLogger.instance
        .log('[OP] windows_smtc_button: $event');
    switch (event) {
      case PressedButton.play:
        await _audioHandler.play();
      case PressedButton.pause:
        await _audioHandler.pause();
      case PressedButton.next:
        await _audioHandler.skipToNext();
      case PressedButton.previous:
        await _audioHandler.skipToPrevious();
      case PressedButton.stop:
        await _audioHandler.stop();
      case PressedButton.fastForward:
      case PressedButton.rewind:
      case PressedButton.record:
      case PressedButton.channelUp:
      case PressedButton.channelDown:
        break;
    }
  }

  Future<void> _syncMetadata(MediaItem? item) async {
    if (item == null) {
      await _smtc.clearMetadata();
      return;
    }

    await _smtc.updateMetadata(
      MusicMetadata(
        title: item.title,
        artist: item.artist,
        album: item.album,
        albumArtist: item.artist,
        thumbnail: item.artUri?.toString(),
      ),
    );
  }

  Future<void> _syncPlaybackState(PlaybackState state) async {
    final status = switch (state.processingState) {
      AudioProcessingState.idle => PlaybackStatus.Stopped,
      AudioProcessingState.loading || AudioProcessingState.buffering =>
        PlaybackStatus.Changing,
      AudioProcessingState.ready || AudioProcessingState.completed =>
        state.playing ? PlaybackStatus.Playing : PlaybackStatus.Paused,
      AudioProcessingState.error => PlaybackStatus.Stopped,
    };

    await _smtc.setPlaybackStatus(status);
    await _syncTimeline();
  }

  Future<void> _syncQueueConfig(List<MediaItem> queue) async {
    await _smtc.updateConfig(
      _smtc.config.copyWith(
        nextEnabled: queue.length > 1,
        prevEnabled: queue.length > 1,
      ),
    );
  }

  Future<void> _syncTimeline() async {
    final mediaItem = _audioHandler.mediaItem.valueOrNull;
    final duration = mediaItem?.duration ?? Duration.zero;
    final position = _audioHandler.playbackState.value.updatePosition;

    await _smtc.updateTimeline(
      PlaybackTimeline(
        startTimeMs: 0,
        endTimeMs: duration.inMilliseconds,
        positionMs: position.inMilliseconds,
        minSeekTimeMs: 0,
        maxSeekTimeMs: duration.inMilliseconds,
      ),
    );
  }

  Future<void> dispose() async {
    _timelineTimer?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _smtc.dispose();
  }
}
