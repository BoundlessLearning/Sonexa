import 'package:freezed_annotation/freezed_annotation.dart';

import 'song.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

@freezed
abstract class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String name,
    String? comment,
    @Default(false) bool isPublic,
    required int songCount,
    required int duration,
    String? coverArtId,
    required String owner,
    DateTime? created,
    DateTime? changed,
    @Default([]) List<Song> songs,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);
}
