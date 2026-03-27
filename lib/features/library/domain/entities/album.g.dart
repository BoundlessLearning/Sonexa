// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Album _$AlbumFromJson(Map<String, dynamic> json) => _Album(
  id: json['id'] as String,
  name: json['name'] as String,
  artist: json['artist'] as String,
  artistId: json['artistId'] as String,
  coverArtId: json['coverArtId'] as String?,
  songCount: (json['songCount'] as num).toInt(),
  duration: (json['duration'] as num).toInt(),
  year: (json['year'] as num?)?.toInt(),
  genre: json['genre'] as String?,
  playCount: (json['playCount'] as num?)?.toInt(),
  starred:
      json['starred'] == null
          ? null
          : DateTime.parse(json['starred'] as String),
  created:
      json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
);

Map<String, dynamic> _$AlbumToJson(_Album instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'artist': instance.artist,
  'artistId': instance.artistId,
  'coverArtId': instance.coverArtId,
  'songCount': instance.songCount,
  'duration': instance.duration,
  'year': instance.year,
  'genre': instance.genre,
  'playCount': instance.playCount,
  'starred': instance.starred?.toIso8601String(),
  'created': instance.created?.toIso8601String(),
};
