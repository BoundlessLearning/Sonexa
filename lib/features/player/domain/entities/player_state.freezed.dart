// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerState {

 Song? get currentSong; List<Song> get queue; int get currentIndex; bool get isPlaying; bool get isBuffering; Duration get position; Duration get bufferedPosition; Duration get duration; double get volume; RepeatMode get repeatMode; bool get isShuffled;
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<PlayerState> get copyWith => _$PlayerStateCopyWithImpl<PlayerState>(this as PlayerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerState&&(identical(other.currentSong, currentSong) || other.currentSong == currentSong)&&const DeepCollectionEquality().equals(other.queue, queue)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isBuffering, isBuffering) || other.isBuffering == isBuffering)&&(identical(other.position, position) || other.position == position)&&(identical(other.bufferedPosition, bufferedPosition) || other.bufferedPosition == bufferedPosition)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.repeatMode, repeatMode) || other.repeatMode == repeatMode)&&(identical(other.isShuffled, isShuffled) || other.isShuffled == isShuffled));
}


@override
int get hashCode => Object.hash(runtimeType,currentSong,const DeepCollectionEquality().hash(queue),currentIndex,isPlaying,isBuffering,position,bufferedPosition,duration,volume,repeatMode,isShuffled);

@override
String toString() {
  return 'PlayerState(currentSong: $currentSong, queue: $queue, currentIndex: $currentIndex, isPlaying: $isPlaying, isBuffering: $isBuffering, position: $position, bufferedPosition: $bufferedPosition, duration: $duration, volume: $volume, repeatMode: $repeatMode, isShuffled: $isShuffled)';
}


}

/// @nodoc
abstract mixin class $PlayerStateCopyWith<$Res>  {
  factory $PlayerStateCopyWith(PlayerState value, $Res Function(PlayerState) _then) = _$PlayerStateCopyWithImpl;
@useResult
$Res call({
 Song? currentSong, List<Song> queue, int currentIndex, bool isPlaying, bool isBuffering, Duration position, Duration bufferedPosition, Duration duration, double volume, RepeatMode repeatMode, bool isShuffled
});


$SongCopyWith<$Res>? get currentSong;

}
/// @nodoc
class _$PlayerStateCopyWithImpl<$Res>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._self, this._then);

  final PlayerState _self;
  final $Res Function(PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentSong = freezed,Object? queue = null,Object? currentIndex = null,Object? isPlaying = null,Object? isBuffering = null,Object? position = null,Object? bufferedPosition = null,Object? duration = null,Object? volume = null,Object? repeatMode = null,Object? isShuffled = null,}) {
  return _then(_self.copyWith(
currentSong: freezed == currentSong ? _self.currentSong : currentSong // ignore: cast_nullable_to_non_nullable
as Song?,queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<Song>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,bufferedPosition: null == bufferedPosition ? _self.bufferedPosition : bufferedPosition // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,repeatMode: null == repeatMode ? _self.repeatMode : repeatMode // ignore: cast_nullable_to_non_nullable
as RepeatMode,isShuffled: null == isShuffled ? _self.isShuffled : isShuffled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res>? get currentSong {
    if (_self.currentSong == null) {
    return null;
  }

  return $SongCopyWith<$Res>(_self.currentSong!, (value) {
    return _then(_self.copyWith(currentSong: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayerState].
extension PlayerStatePatterns on PlayerState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Song? currentSong,  List<Song> queue,  int currentIndex,  bool isPlaying,  bool isBuffering,  Duration position,  Duration bufferedPosition,  Duration duration,  double volume,  RepeatMode repeatMode,  bool isShuffled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.currentSong,_that.queue,_that.currentIndex,_that.isPlaying,_that.isBuffering,_that.position,_that.bufferedPosition,_that.duration,_that.volume,_that.repeatMode,_that.isShuffled);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Song? currentSong,  List<Song> queue,  int currentIndex,  bool isPlaying,  bool isBuffering,  Duration position,  Duration bufferedPosition,  Duration duration,  double volume,  RepeatMode repeatMode,  bool isShuffled)  $default,) {final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that.currentSong,_that.queue,_that.currentIndex,_that.isPlaying,_that.isBuffering,_that.position,_that.bufferedPosition,_that.duration,_that.volume,_that.repeatMode,_that.isShuffled);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Song? currentSong,  List<Song> queue,  int currentIndex,  bool isPlaying,  bool isBuffering,  Duration position,  Duration bufferedPosition,  Duration duration,  double volume,  RepeatMode repeatMode,  bool isShuffled)?  $default,) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.currentSong,_that.queue,_that.currentIndex,_that.isPlaying,_that.isBuffering,_that.position,_that.bufferedPosition,_that.duration,_that.volume,_that.repeatMode,_that.isShuffled);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerState implements PlayerState {
  const _PlayerState({this.currentSong, final  List<Song> queue = const [], this.currentIndex = 0, this.isPlaying = false, this.isBuffering = false, this.position = Duration.zero, this.bufferedPosition = Duration.zero, this.duration = Duration.zero, this.volume = 1.0, this.repeatMode = RepeatMode.off, this.isShuffled = false}): _queue = queue;
  

@override final  Song? currentSong;
 final  List<Song> _queue;
@override@JsonKey() List<Song> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

@override@JsonKey() final  int currentIndex;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  bool isBuffering;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration bufferedPosition;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  double volume;
@override@JsonKey() final  RepeatMode repeatMode;
@override@JsonKey() final  bool isShuffled;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStateCopyWith<_PlayerState> get copyWith => __$PlayerStateCopyWithImpl<_PlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerState&&(identical(other.currentSong, currentSong) || other.currentSong == currentSong)&&const DeepCollectionEquality().equals(other._queue, _queue)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isBuffering, isBuffering) || other.isBuffering == isBuffering)&&(identical(other.position, position) || other.position == position)&&(identical(other.bufferedPosition, bufferedPosition) || other.bufferedPosition == bufferedPosition)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.repeatMode, repeatMode) || other.repeatMode == repeatMode)&&(identical(other.isShuffled, isShuffled) || other.isShuffled == isShuffled));
}


@override
int get hashCode => Object.hash(runtimeType,currentSong,const DeepCollectionEquality().hash(_queue),currentIndex,isPlaying,isBuffering,position,bufferedPosition,duration,volume,repeatMode,isShuffled);

@override
String toString() {
  return 'PlayerState(currentSong: $currentSong, queue: $queue, currentIndex: $currentIndex, isPlaying: $isPlaying, isBuffering: $isBuffering, position: $position, bufferedPosition: $bufferedPosition, duration: $duration, volume: $volume, repeatMode: $repeatMode, isShuffled: $isShuffled)';
}


}

/// @nodoc
abstract mixin class _$PlayerStateCopyWith<$Res> implements $PlayerStateCopyWith<$Res> {
  factory _$PlayerStateCopyWith(_PlayerState value, $Res Function(_PlayerState) _then) = __$PlayerStateCopyWithImpl;
@override @useResult
$Res call({
 Song? currentSong, List<Song> queue, int currentIndex, bool isPlaying, bool isBuffering, Duration position, Duration bufferedPosition, Duration duration, double volume, RepeatMode repeatMode, bool isShuffled
});


@override $SongCopyWith<$Res>? get currentSong;

}
/// @nodoc
class __$PlayerStateCopyWithImpl<$Res>
    implements _$PlayerStateCopyWith<$Res> {
  __$PlayerStateCopyWithImpl(this._self, this._then);

  final _PlayerState _self;
  final $Res Function(_PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentSong = freezed,Object? queue = null,Object? currentIndex = null,Object? isPlaying = null,Object? isBuffering = null,Object? position = null,Object? bufferedPosition = null,Object? duration = null,Object? volume = null,Object? repeatMode = null,Object? isShuffled = null,}) {
  return _then(_PlayerState(
currentSong: freezed == currentSong ? _self.currentSong : currentSong // ignore: cast_nullable_to_non_nullable
as Song?,queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<Song>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,bufferedPosition: null == bufferedPosition ? _self.bufferedPosition : bufferedPosition // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,repeatMode: null == repeatMode ? _self.repeatMode : repeatMode // ignore: cast_nullable_to_non_nullable
as RepeatMode,isShuffled: null == isShuffled ? _self.isShuffled : isShuffled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res>? get currentSong {
    if (_self.currentSong == null) {
    return null;
  }

  return $SongCopyWith<$Res>(_self.currentSong!, (value) {
    return _then(_self.copyWith(currentSong: value));
  });
}
}

// dart format on
