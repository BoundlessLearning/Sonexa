import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyrics.freezed.dart';
part 'lyrics.g.dart';

enum LyricsSource { tag, lrclib, netease, qqMusic, manual }

@freezed
abstract class LyricLine with _$LyricLine {
  const factory LyricLine({
    required int timeMs,
    required String text,
    String? translation,
  }) = _LyricLine;

  factory LyricLine.fromJson(Map<String, dynamic> json) => _$LyricLineFromJson(json);
}

@freezed
abstract class Lyrics with _$Lyrics {
  const factory Lyrics({
    required String songId,
    required LyricsSource source,
    required bool isSynced,
    required List<LyricLine> lines,
    String? rawLrc,
  }) = _Lyrics;

  factory Lyrics.fromJson(Map<String, dynamic> json) => _$LyricsFromJson(json);
}
