// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Artist _$ArtistFromJson(Map<String, dynamic> json) => _Artist(
  id: json['id'] as String,
  name: json['name'] as String,
  coverArtId: json['coverArtId'] as String?,
  albumCount: (json['albumCount'] as num).toInt(),
  starred:
      json['starred'] == null
          ? null
          : DateTime.parse(json['starred'] as String),
  biography: json['biography'] as String?,
  musicBrainzId: json['musicBrainzId'] as String?,
);

Map<String, dynamic> _$ArtistToJson(_Artist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'coverArtId': instance.coverArtId,
  'albumCount': instance.albumCount,
  'starred': instance.starred?.toIso8601String(),
  'biography': instance.biography,
  'musicBrainzId': instance.musicBrainzId,
};
