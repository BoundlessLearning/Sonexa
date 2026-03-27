// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Song _$SongFromJson(Map<String, dynamic> json) => _Song(
  id: json['id'] as String,
  title: json['title'] as String,
  artist: json['artist'] as String,
  artistId: json['artistId'] as String,
  album: json['album'] as String,
  albumId: json['albumId'] as String,
  coverArtId: json['coverArtId'] as String?,
  duration: (json['duration'] as num).toInt(),
  track: (json['track'] as num?)?.toInt(),
  discNumber: (json['discNumber'] as num?)?.toInt(),
  year: (json['year'] as num?)?.toInt(),
  genre: json['genre'] as String?,
  bitRate: (json['bitRate'] as num?)?.toInt(),
  suffix: json['suffix'] as String?,
  size: (json['size'] as num?)?.toInt(),
  playCount: (json['playCount'] as num?)?.toInt() ?? 0,
  starred:
      json['starred'] == null
          ? null
          : DateTime.parse(json['starred'] as String),
  lastPlayed:
      json['lastPlayed'] == null
          ? null
          : DateTime.parse(json['lastPlayed'] as String),
  localFilePath: json['localFilePath'] as String?,
);

Map<String, dynamic> _$SongToJson(_Song instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'artist': instance.artist,
  'artistId': instance.artistId,
  'album': instance.album,
  'albumId': instance.albumId,
  'coverArtId': instance.coverArtId,
  'duration': instance.duration,
  'track': instance.track,
  'discNumber': instance.discNumber,
  'year': instance.year,
  'genre': instance.genre,
  'bitRate': instance.bitRate,
  'suffix': instance.suffix,
  'size': instance.size,
  'playCount': instance.playCount,
  'starred': instance.starred?.toIso8601String(),
  'lastPlayed': instance.lastPlayed?.toIso8601String(),
  'localFilePath': instance.localFilePath,
};
