// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Playlist _$PlaylistFromJson(Map<String, dynamic> json) => _Playlist(
  id: json['id'] as String,
  name: json['name'] as String,
  comment: json['comment'] as String?,
  isPublic: json['isPublic'] as bool? ?? false,
  songCount: (json['songCount'] as num).toInt(),
  duration: (json['duration'] as num).toInt(),
  coverArtId: json['coverArtId'] as String?,
  owner: json['owner'] as String,
  created:
      json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
  changed:
      json['changed'] == null
          ? null
          : DateTime.parse(json['changed'] as String),
  songs:
      (json['songs'] as List<dynamic>?)
          ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PlaylistToJson(_Playlist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'comment': instance.comment,
  'isPublic': instance.isPublic,
  'songCount': instance.songCount,
  'duration': instance.duration,
  'coverArtId': instance.coverArtId,
  'owner': instance.owner,
  'created': instance.created?.toIso8601String(),
  'changed': instance.changed?.toIso8601String(),
  'songs': instance.songs,
};
