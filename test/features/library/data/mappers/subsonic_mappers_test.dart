import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/features/library/data/mappers/subsonic_mappers.dart';

void main() {
  group('SubsonicMappers', () {
    test('maps Subsonic song fields into Song', () {
      final song = SubsonicMappers.song({
        'id': 'song-1',
        'title': 'North Star',
        'artist': 'The Winters',
        'artistId': 'artist-1',
        'album': 'Cold Signal',
        'albumId': 'album-1',
        'coverArt': 'cover-1',
        'duration': 231,
        'track': 4,
        'discNumber': 1,
        'year': 2026,
        'genre': 'indie',
        'bitRate': 320,
        'suffix': 'flac',
        'size': 12345678,
        'playCount': 7,
        'starred': '2026-01-02T03:04:05Z',
        'played': '2026-01-03T04:05:06Z',
      });

      expect(song.id, 'song-1');
      expect(song.title, 'North Star');
      expect(song.artist, 'The Winters');
      expect(song.coverArtId, 'cover-1');
      expect(song.duration, 231);
      expect(song.track, 4);
      expect(song.discNumber, 1);
      expect(song.year, 2026);
      expect(song.genre, 'indie');
      expect(song.bitRate, 320);
      expect(song.suffix, 'flac');
      expect(song.size, 12345678);
      expect(song.playCount, 7);
      expect(song.starred, DateTime.parse('2026-01-02T03:04:05Z'));
      expect(song.lastPlayed, DateTime.parse('2026-01-03T04:05:06Z'));
    });

    test('maps album title fallback and artist fallback id', () {
      final album = SubsonicMappers.album({
        'id': 'album-1',
        'title': 'Cold Signal',
        'artist': 'The Winters',
        'coverArt': 'cover-1',
        'songCount': '12',
        'duration': '3200',
        'created': '2026-01-01T00:00:00Z',
      }, fallbackArtistId: 'artist-1');

      expect(album.name, 'Cold Signal');
      expect(album.artistId, 'artist-1');
      expect(album.songCount, 12);
      expect(album.duration, 3200);
      expect(album.created, DateTime.parse('2026-01-01T00:00:00Z'));
    });

    test('maps artist image fallback', () {
      final artist = SubsonicMappers.artist({
        'id': 'artist-1',
        'name': 'The Winters',
        'artistImageUrl': 'https://example.test/artist.jpg',
        'albumCount': 3,
      });

      expect(artist.coverArtId, 'https://example.test/artist.jpg');
      expect(artist.albumCount, 3);
    });

    test('maps playlist entries into songs', () {
      final playlist = SubsonicMappers.playlist({
        'id': 'playlist-1',
        'name': 'Late Night',
        'comment': 'Quiet queue',
        'public': true,
        'songCount': 1,
        'duration': 231,
        'coverArt': 'playlist-cover',
        'owner': 'alice',
        'created': '2026-01-01T00:00:00Z',
        'entry': [
          {
            'id': 'song-1',
            'title': 'North Star',
            'artist': 'The Winters',
            'duration': 231,
          },
        ],
      });

      expect(playlist.id, 'playlist-1');
      expect(playlist.name, 'Late Night');
      expect(playlist.isPublic, isTrue);
      expect(playlist.songs, hasLength(1));
      expect(playlist.songs.single.title, 'North Star');
    });
  });
}
