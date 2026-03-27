// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LyricLine _$LyricLineFromJson(Map<String, dynamic> json) => _LyricLine(
  timeMs: (json['timeMs'] as num).toInt(),
  text: json['text'] as String,
  translation: json['translation'] as String?,
);

Map<String, dynamic> _$LyricLineToJson(_LyricLine instance) =>
    <String, dynamic>{
      'timeMs': instance.timeMs,
      'text': instance.text,
      'translation': instance.translation,
    };

_Lyrics _$LyricsFromJson(Map<String, dynamic> json) => _Lyrics(
  songId: json['songId'] as String,
  source: $enumDecode(_$LyricsSourceEnumMap, json['source']),
  isSynced: json['isSynced'] as bool,
  lines:
      (json['lines'] as List<dynamic>)
          .map((e) => LyricLine.fromJson(e as Map<String, dynamic>))
          .toList(),
  rawLrc: json['rawLrc'] as String?,
);

Map<String, dynamic> _$LyricsToJson(_Lyrics instance) => <String, dynamic>{
  'songId': instance.songId,
  'source': _$LyricsSourceEnumMap[instance.source]!,
  'isSynced': instance.isSynced,
  'lines': instance.lines,
  'rawLrc': instance.rawLrc,
};

const _$LyricsSourceEnumMap = {
  LyricsSource.tag: 'tag',
  LyricsSource.lrclib: 'lrclib',
  LyricsSource.netease: 'netease',
  LyricsSource.qqMusic: 'qqMusic',
  LyricsSource.manual: 'manual',
};
