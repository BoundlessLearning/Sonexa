// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Song {

 String get id; String get title; String get artist; String get artistId; String get album; String get albumId; String? get coverArtId; int get duration; int? get track; int? get discNumber; int? get year; String? get genre; int? get bitRate; String? get suffix; int? get size; int get playCount; DateTime? get starred; DateTime? get lastPlayed; String? get localFilePath;
/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongCopyWith<Song> get copyWith => _$SongCopyWithImpl<Song>(this as Song, _$identity);

  /// Serializes this Song to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Song&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.artistId, artistId) || other.artistId == artistId)&&(identical(other.album, album) || other.album == album)&&(identical(other.albumId, albumId) || other.albumId == albumId)&&(identical(other.coverArtId, coverArtId) || other.coverArtId == coverArtId)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.track, track) || other.track == track)&&(identical(other.discNumber, discNumber) || other.discNumber == discNumber)&&(identical(other.year, year) || other.year == year)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.bitRate, bitRate) || other.bitRate == bitRate)&&(identical(other.suffix, suffix) || other.suffix == suffix)&&(identical(other.size, size) || other.size == size)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.starred, starred) || other.starred == starred)&&(identical(other.lastPlayed, lastPlayed) || other.lastPlayed == lastPlayed)&&(identical(other.localFilePath, localFilePath) || other.localFilePath == localFilePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,artist,artistId,album,albumId,coverArtId,duration,track,discNumber,year,genre,bitRate,suffix,size,playCount,starred,lastPlayed,localFilePath]);

@override
String toString() {
  return 'Song(id: $id, title: $title, artist: $artist, artistId: $artistId, album: $album, albumId: $albumId, coverArtId: $coverArtId, duration: $duration, track: $track, discNumber: $discNumber, year: $year, genre: $genre, bitRate: $bitRate, suffix: $suffix, size: $size, playCount: $playCount, starred: $starred, lastPlayed: $lastPlayed, localFilePath: $localFilePath)';
}


}

/// @nodoc
abstract mixin class $SongCopyWith<$Res>  {
  factory $SongCopyWith(Song value, $Res Function(Song) _then) = _$SongCopyWithImpl;
@useResult
$Res call({
 String id, String title, String artist, String artistId, String album, String albumId, String? coverArtId, int duration, int? track, int? discNumber, int? year, String? genre, int? bitRate, String? suffix, int? size, int playCount, DateTime? starred, DateTime? lastPlayed, String? localFilePath
});




}
/// @nodoc
class _$SongCopyWithImpl<$Res>
    implements $SongCopyWith<$Res> {
  _$SongCopyWithImpl(this._self, this._then);

  final Song _self;
  final $Res Function(Song) _then;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? artistId = null,Object? album = null,Object? albumId = null,Object? coverArtId = freezed,Object? duration = null,Object? track = freezed,Object? discNumber = freezed,Object? year = freezed,Object? genre = freezed,Object? bitRate = freezed,Object? suffix = freezed,Object? size = freezed,Object? playCount = null,Object? starred = freezed,Object? lastPlayed = freezed,Object? localFilePath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,artistId: null == artistId ? _self.artistId : artistId // ignore: cast_nullable_to_non_nullable
as String,album: null == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String,albumId: null == albumId ? _self.albumId : albumId // ignore: cast_nullable_to_non_nullable
as String,coverArtId: freezed == coverArtId ? _self.coverArtId : coverArtId // ignore: cast_nullable_to_non_nullable
as String?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,track: freezed == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as int?,discNumber: freezed == discNumber ? _self.discNumber : discNumber // ignore: cast_nullable_to_non_nullable
as int?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,bitRate: freezed == bitRate ? _self.bitRate : bitRate // ignore: cast_nullable_to_non_nullable
as int?,suffix: freezed == suffix ? _self.suffix : suffix // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,starred: freezed == starred ? _self.starred : starred // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPlayed: freezed == lastPlayed ? _self.lastPlayed : lastPlayed // ignore: cast_nullable_to_non_nullable
as DateTime?,localFilePath: freezed == localFilePath ? _self.localFilePath : localFilePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Song].
extension SongPatterns on Song {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Song value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Song() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Song value)  $default,){
final _that = this;
switch (_that) {
case _Song():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Song value)?  $default,){
final _that = this;
switch (_that) {
case _Song() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String artist,  String artistId,  String album,  String albumId,  String? coverArtId,  int duration,  int? track,  int? discNumber,  int? year,  String? genre,  int? bitRate,  String? suffix,  int? size,  int playCount,  DateTime? starred,  DateTime? lastPlayed,  String? localFilePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Song() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.artistId,_that.album,_that.albumId,_that.coverArtId,_that.duration,_that.track,_that.discNumber,_that.year,_that.genre,_that.bitRate,_that.suffix,_that.size,_that.playCount,_that.starred,_that.lastPlayed,_that.localFilePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String artist,  String artistId,  String album,  String albumId,  String? coverArtId,  int duration,  int? track,  int? discNumber,  int? year,  String? genre,  int? bitRate,  String? suffix,  int? size,  int playCount,  DateTime? starred,  DateTime? lastPlayed,  String? localFilePath)  $default,) {final _that = this;
switch (_that) {
case _Song():
return $default(_that.id,_that.title,_that.artist,_that.artistId,_that.album,_that.albumId,_that.coverArtId,_that.duration,_that.track,_that.discNumber,_that.year,_that.genre,_that.bitRate,_that.suffix,_that.size,_that.playCount,_that.starred,_that.lastPlayed,_that.localFilePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String artist,  String artistId,  String album,  String albumId,  String? coverArtId,  int duration,  int? track,  int? discNumber,  int? year,  String? genre,  int? bitRate,  String? suffix,  int? size,  int playCount,  DateTime? starred,  DateTime? lastPlayed,  String? localFilePath)?  $default,) {final _that = this;
switch (_that) {
case _Song() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.artistId,_that.album,_that.albumId,_that.coverArtId,_that.duration,_that.track,_that.discNumber,_that.year,_that.genre,_that.bitRate,_that.suffix,_that.size,_that.playCount,_that.starred,_that.lastPlayed,_that.localFilePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Song implements Song {
  const _Song({required this.id, required this.title, required this.artist, required this.artistId, required this.album, required this.albumId, this.coverArtId, required this.duration, this.track, this.discNumber, this.year, this.genre, this.bitRate, this.suffix, this.size, this.playCount = 0, this.starred, this.lastPlayed, this.localFilePath});
  factory _Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

@override final  String id;
@override final  String title;
@override final  String artist;
@override final  String artistId;
@override final  String album;
@override final  String albumId;
@override final  String? coverArtId;
@override final  int duration;
@override final  int? track;
@override final  int? discNumber;
@override final  int? year;
@override final  String? genre;
@override final  int? bitRate;
@override final  String? suffix;
@override final  int? size;
@override@JsonKey() final  int playCount;
@override final  DateTime? starred;
@override final  DateTime? lastPlayed;
@override final  String? localFilePath;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongCopyWith<_Song> get copyWith => __$SongCopyWithImpl<_Song>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SongToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Song&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.artistId, artistId) || other.artistId == artistId)&&(identical(other.album, album) || other.album == album)&&(identical(other.albumId, albumId) || other.albumId == albumId)&&(identical(other.coverArtId, coverArtId) || other.coverArtId == coverArtId)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.track, track) || other.track == track)&&(identical(other.discNumber, discNumber) || other.discNumber == discNumber)&&(identical(other.year, year) || other.year == year)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.bitRate, bitRate) || other.bitRate == bitRate)&&(identical(other.suffix, suffix) || other.suffix == suffix)&&(identical(other.size, size) || other.size == size)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.starred, starred) || other.starred == starred)&&(identical(other.lastPlayed, lastPlayed) || other.lastPlayed == lastPlayed)&&(identical(other.localFilePath, localFilePath) || other.localFilePath == localFilePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,artist,artistId,album,albumId,coverArtId,duration,track,discNumber,year,genre,bitRate,suffix,size,playCount,starred,lastPlayed,localFilePath]);

@override
String toString() {
  return 'Song(id: $id, title: $title, artist: $artist, artistId: $artistId, album: $album, albumId: $albumId, coverArtId: $coverArtId, duration: $duration, track: $track, discNumber: $discNumber, year: $year, genre: $genre, bitRate: $bitRate, suffix: $suffix, size: $size, playCount: $playCount, starred: $starred, lastPlayed: $lastPlayed, localFilePath: $localFilePath)';
}


}

/// @nodoc
abstract mixin class _$SongCopyWith<$Res> implements $SongCopyWith<$Res> {
  factory _$SongCopyWith(_Song value, $Res Function(_Song) _then) = __$SongCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String artist, String artistId, String album, String albumId, String? coverArtId, int duration, int? track, int? discNumber, int? year, String? genre, int? bitRate, String? suffix, int? size, int playCount, DateTime? starred, DateTime? lastPlayed, String? localFilePath
});




}
/// @nodoc
class __$SongCopyWithImpl<$Res>
    implements _$SongCopyWith<$Res> {
  __$SongCopyWithImpl(this._self, this._then);

  final _Song _self;
  final $Res Function(_Song) _then;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? artistId = null,Object? album = null,Object? albumId = null,Object? coverArtId = freezed,Object? duration = null,Object? track = freezed,Object? discNumber = freezed,Object? year = freezed,Object? genre = freezed,Object? bitRate = freezed,Object? suffix = freezed,Object? size = freezed,Object? playCount = null,Object? starred = freezed,Object? lastPlayed = freezed,Object? localFilePath = freezed,}) {
  return _then(_Song(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,artistId: null == artistId ? _self.artistId : artistId // ignore: cast_nullable_to_non_nullable
as String,album: null == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String,albumId: null == albumId ? _self.albumId : albumId // ignore: cast_nullable_to_non_nullable
as String,coverArtId: freezed == coverArtId ? _self.coverArtId : coverArtId // ignore: cast_nullable_to_non_nullable
as String?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,track: freezed == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as int?,discNumber: freezed == discNumber ? _self.discNumber : discNumber // ignore: cast_nullable_to_non_nullable
as int?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,bitRate: freezed == bitRate ? _self.bitRate : bitRate // ignore: cast_nullable_to_non_nullable
as int?,suffix: freezed == suffix ? _self.suffix : suffix // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,starred: freezed == starred ? _self.starred : starred // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPlayed: freezed == lastPlayed ? _self.lastPlayed : lastPlayed // ignore: cast_nullable_to_non_nullable
as DateTime?,localFilePath: freezed == localFilePath ? _self.localFilePath : localFilePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
