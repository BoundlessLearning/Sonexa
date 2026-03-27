import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../library/domain/entities/song.dart';

part 'player_state.freezed.dart';

enum RepeatMode { off, all, one }

@freezed
abstract class PlayerState with _$PlayerState {
  const factory PlayerState({
    Song? currentSong,
    @Default([]) List<Song> queue,
    @Default(0) int currentIndex,
    @Default(false) bool isPlaying,
    @Default(false) bool isBuffering,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration bufferedPosition,
    @Default(Duration.zero) Duration duration,
    @Default(1.0) double volume,
    @Default(RepeatMode.off) RepeatMode repeatMode,
    @Default(false) bool isShuffled,
  }) = _PlayerState;
}
