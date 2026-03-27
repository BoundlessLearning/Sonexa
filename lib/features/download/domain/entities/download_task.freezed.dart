// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DownloadTask {

 String get id; String get songId; String get title; String get artist; DownloadStatus get status; double get progress; String? get localPath; int? get totalBytes; int? get downloadedBytes; DateTime? get startedAt; DateTime? get completedAt; String? get error;
/// Create a copy of DownloadTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadTaskCopyWith<DownloadTask> get copyWith => _$DownloadTaskCopyWithImpl<DownloadTask>(this as DownloadTask, _$identity);

  /// Serializes this DownloadTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadTask&&(identical(other.id, id) || other.id == id)&&(identical(other.songId, songId) || other.songId == songId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,songId,title,artist,status,progress,localPath,totalBytes,downloadedBytes,startedAt,completedAt,error);

@override
String toString() {
  return 'DownloadTask(id: $id, songId: $songId, title: $title, artist: $artist, status: $status, progress: $progress, localPath: $localPath, totalBytes: $totalBytes, downloadedBytes: $downloadedBytes, startedAt: $startedAt, completedAt: $completedAt, error: $error)';
}


}

/// @nodoc
abstract mixin class $DownloadTaskCopyWith<$Res>  {
  factory $DownloadTaskCopyWith(DownloadTask value, $Res Function(DownloadTask) _then) = _$DownloadTaskCopyWithImpl;
@useResult
$Res call({
 String id, String songId, String title, String artist, DownloadStatus status, double progress, String? localPath, int? totalBytes, int? downloadedBytes, DateTime? startedAt, DateTime? completedAt, String? error
});




}
/// @nodoc
class _$DownloadTaskCopyWithImpl<$Res>
    implements $DownloadTaskCopyWith<$Res> {
  _$DownloadTaskCopyWithImpl(this._self, this._then);

  final DownloadTask _self;
  final $Res Function(DownloadTask) _then;

/// Create a copy of DownloadTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? songId = null,Object? title = null,Object? artist = null,Object? status = null,Object? progress = null,Object? localPath = freezed,Object? totalBytes = freezed,Object? downloadedBytes = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,songId: null == songId ? _self.songId : songId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,totalBytes: freezed == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int?,downloadedBytes: freezed == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadTask].
extension DownloadTaskPatterns on DownloadTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadTask value)  $default,){
final _that = this;
switch (_that) {
case _DownloadTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadTask value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String songId,  String title,  String artist,  DownloadStatus status,  double progress,  String? localPath,  int? totalBytes,  int? downloadedBytes,  DateTime? startedAt,  DateTime? completedAt,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadTask() when $default != null:
return $default(_that.id,_that.songId,_that.title,_that.artist,_that.status,_that.progress,_that.localPath,_that.totalBytes,_that.downloadedBytes,_that.startedAt,_that.completedAt,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String songId,  String title,  String artist,  DownloadStatus status,  double progress,  String? localPath,  int? totalBytes,  int? downloadedBytes,  DateTime? startedAt,  DateTime? completedAt,  String? error)  $default,) {final _that = this;
switch (_that) {
case _DownloadTask():
return $default(_that.id,_that.songId,_that.title,_that.artist,_that.status,_that.progress,_that.localPath,_that.totalBytes,_that.downloadedBytes,_that.startedAt,_that.completedAt,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String songId,  String title,  String artist,  DownloadStatus status,  double progress,  String? localPath,  int? totalBytes,  int? downloadedBytes,  DateTime? startedAt,  DateTime? completedAt,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _DownloadTask() when $default != null:
return $default(_that.id,_that.songId,_that.title,_that.artist,_that.status,_that.progress,_that.localPath,_that.totalBytes,_that.downloadedBytes,_that.startedAt,_that.completedAt,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DownloadTask implements DownloadTask {
  const _DownloadTask({required this.id, required this.songId, required this.title, required this.artist, required this.status, required this.progress, this.localPath, this.totalBytes, this.downloadedBytes, this.startedAt, this.completedAt, this.error});
  factory _DownloadTask.fromJson(Map<String, dynamic> json) => _$DownloadTaskFromJson(json);

@override final  String id;
@override final  String songId;
@override final  String title;
@override final  String artist;
@override final  DownloadStatus status;
@override final  double progress;
@override final  String? localPath;
@override final  int? totalBytes;
@override final  int? downloadedBytes;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;
@override final  String? error;

/// Create a copy of DownloadTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadTaskCopyWith<_DownloadTask> get copyWith => __$DownloadTaskCopyWithImpl<_DownloadTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DownloadTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadTask&&(identical(other.id, id) || other.id == id)&&(identical(other.songId, songId) || other.songId == songId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,songId,title,artist,status,progress,localPath,totalBytes,downloadedBytes,startedAt,completedAt,error);

@override
String toString() {
  return 'DownloadTask(id: $id, songId: $songId, title: $title, artist: $artist, status: $status, progress: $progress, localPath: $localPath, totalBytes: $totalBytes, downloadedBytes: $downloadedBytes, startedAt: $startedAt, completedAt: $completedAt, error: $error)';
}


}

/// @nodoc
abstract mixin class _$DownloadTaskCopyWith<$Res> implements $DownloadTaskCopyWith<$Res> {
  factory _$DownloadTaskCopyWith(_DownloadTask value, $Res Function(_DownloadTask) _then) = __$DownloadTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String songId, String title, String artist, DownloadStatus status, double progress, String? localPath, int? totalBytes, int? downloadedBytes, DateTime? startedAt, DateTime? completedAt, String? error
});




}
/// @nodoc
class __$DownloadTaskCopyWithImpl<$Res>
    implements _$DownloadTaskCopyWith<$Res> {
  __$DownloadTaskCopyWithImpl(this._self, this._then);

  final _DownloadTask _self;
  final $Res Function(_DownloadTask) _then;

/// Create a copy of DownloadTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? songId = null,Object? title = null,Object? artist = null,Object? status = null,Object? progress = null,Object? localPath = freezed,Object? totalBytes = freezed,Object? downloadedBytes = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? error = freezed,}) {
  return _then(_DownloadTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,songId: null == songId ? _self.songId : songId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,totalBytes: freezed == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int?,downloadedBytes: freezed == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
