import 'package:freezed_annotation/freezed_annotation.dart';

part 'song.freezed.dart';
part 'song.g.dart';

@freezed
abstract class Song with _$Song {
  const factory Song({
    required String id,
    required String title,
    required String artist,
    required String artistId,
    required String album,
    required String albumId,
    String? coverArtId,
    required int duration,
    int? track,
    int? discNumber,
    int? year,
    String? genre,
    int? bitRate,
    String? suffix,
    int? size,
    @Default(0) int playCount,
    DateTime? starred,
    DateTime? lastPlayed,
    String? localFilePath,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
}
