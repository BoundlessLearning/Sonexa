import 'package:sonexa/features/library/domain/entities/album.dart';
import 'package:sonexa/features/library/domain/entities/artist.dart';
import 'package:sonexa/features/library/domain/entities/playlist.dart';
import 'package:sonexa/features/library/domain/entities/song.dart';

class SubsonicMappers {
  const SubsonicMappers._();

  static Song song(Map<String, dynamic> json, {String? localFilePath}) {
    return Song(
      id: _requiredString(json, 'id'),
      title: _string(json['title']) ?? '',
      artist: _string(json['artist']) ?? 'Unknown',
      artistId: _string(json['artistId']) ?? '',
      album: _string(json['album']) ?? '',
      albumId: _string(json['albumId']) ?? '',
      coverArtId: _string(json['coverArt']),
      duration: _int(json['duration']) ?? 0,
      track: _int(json['track']),
      discNumber: _int(json['discNumber']),
      year: _int(json['year']),
      genre: _string(json['genre']),
      bitRate: _int(json['bitRate']),
      suffix: _string(json['suffix']),
      size: _int(json['size']),
      playCount: _int(json['playCount']) ?? 0,
      starred: _dateTime(json['starred']),
      lastPlayed: _dateTime(json['played']) ?? _dateTime(json['lastPlayed']),
      localFilePath: localFilePath,
    );
  }

  static Album album(Map<String, dynamic> json, {String? fallbackArtistId}) {
    return Album(
      id: _requiredString(json, 'id'),
      name: _string(json['name']) ?? _string(json['title']) ?? '',
      artist: _string(json['artist']) ?? 'Unknown',
      artistId: _string(json['artistId']) ?? fallbackArtistId ?? '',
      coverArtId: _string(json['coverArt']),
      songCount: _int(json['songCount']) ?? 0,
      duration: _int(json['duration']) ?? 0,
      year: _int(json['year']),
      genre: _string(json['genre']),
      playCount: _int(json['playCount']),
      starred: _dateTime(json['starred']),
      created: _dateTime(json['created']),
    );
  }

  static Artist artist(Map<String, dynamic> json) {
    return Artist(
      id: _requiredString(json, 'id'),
      name: _string(json['name']) ?? 'Unknown',
      coverArtId: _string(json['coverArt']) ?? _string(json['artistImageUrl']),
      albumCount: _int(json['albumCount']) ?? 0,
      starred: _dateTime(json['starred']),
      biography: _string(json['biography']),
      musicBrainzId: _string(json['musicBrainzId']),
    );
  }

  static Playlist playlist(Map<String, dynamic> json) {
    final songs =
        (json['entry'] as List<dynamic>? ?? [])
            .map((entry) => song(entry as Map<String, dynamic>))
            .toList();

    return Playlist(
      id: _requiredString(json, 'id'),
      name: _string(json['name']) ?? '',
      comment: _string(json['comment']),
      isPublic: _bool(json['public']) ?? false,
      songCount: _int(json['songCount']) ?? songs.length,
      duration: _int(json['duration']) ?? 0,
      coverArtId: _string(json['coverArt']),
      owner: _string(json['owner']) ?? '',
      created: _dateTime(json['created']),
      changed: _dateTime(json['changed']),
      songs: songs,
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) {
      throw FormatException('Missing required Subsonic field "$key".');
    }
    return _string(value)!;
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static int? _int(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _bool(Object? value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value);
    return null;
  }

  static DateTime? _dateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
