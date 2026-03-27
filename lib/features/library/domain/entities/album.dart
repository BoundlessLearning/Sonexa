import 'package:freezed_annotation/freezed_annotation.dart';

part 'album.freezed.dart';
part 'album.g.dart';

@freezed
abstract class Album with _$Album {
  const factory Album({
    required String id,
    required String name,
    required String artist,
    required String artistId,
    String? coverArtId,
    required int songCount,
    required int duration,
    int? year,
    String? genre,
    int? playCount,
    DateTime? starred,
    DateTime? created,
  }) = _Album;

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
