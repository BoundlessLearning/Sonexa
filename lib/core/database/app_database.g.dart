// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedSongsTable extends CachedSongs
    with TableInfo<$CachedSongsTable, CachedSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverArtIdMeta = const VerificationMeta(
    'coverArtId',
  );
  @override
  late final GeneratedColumn<String> coverArtId = GeneratedColumn<String>(
    'cover_art_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  @override
  late final GeneratedColumn<int> track = GeneratedColumn<int>(
    'track',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discNumberMeta = const VerificationMeta(
    'discNumber',
  );
  @override
  late final GeneratedColumn<int> discNumber = GeneratedColumn<int>(
    'disc_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bitRateMeta = const VerificationMeta(
    'bitRate',
  );
  @override
  late final GeneratedColumn<int> bitRate = GeneratedColumn<int>(
    'bit_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suffixMeta = const VerificationMeta('suffix');
  @override
  late final GeneratedColumn<String> suffix = GeneratedColumn<String>(
    'suffix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _starredMeta = const VerificationMeta(
    'starred',
  );
  @override
  late final GeneratedColumn<DateTime> starred = GeneratedColumn<DateTime>(
    'starred',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPlayedMeta = const VerificationMeta(
    'lastPlayed',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayed = GeneratedColumn<DateTime>(
    'last_played',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artist,
    artistId,
    album,
    albumId,
    coverArtId,
    duration,
    track,
    discNumber,
    year,
    genre,
    bitRate,
    suffix,
    size,
    playCount,
    starred,
    lastPlayed,
    localFilePath,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSong> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('cover_art_id')) {
      context.handle(
        _coverArtIdMeta,
        coverArtId.isAcceptableOrUnknown(
          data['cover_art_id']!,
          _coverArtIdMeta,
        ),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('track')) {
      context.handle(
        _trackMeta,
        track.isAcceptableOrUnknown(data['track']!, _trackMeta),
      );
    }
    if (data.containsKey('disc_number')) {
      context.handle(
        _discNumberMeta,
        discNumber.isAcceptableOrUnknown(data['disc_number']!, _discNumberMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('bit_rate')) {
      context.handle(
        _bitRateMeta,
        bitRate.isAcceptableOrUnknown(data['bit_rate']!, _bitRateMeta),
      );
    }
    if (data.containsKey('suffix')) {
      context.handle(
        _suffixMeta,
        suffix.isAcceptableOrUnknown(data['suffix']!, _suffixMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('starred')) {
      context.handle(
        _starredMeta,
        starred.isAcceptableOrUnknown(data['starred']!, _starredMeta),
      );
    }
    if (data.containsKey('last_played')) {
      context.handle(
        _lastPlayedMeta,
        lastPlayed.isAcceptableOrUnknown(data['last_played']!, _lastPlayedMeta),
      );
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSong(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      artist:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}artist'],
          )!,
      artistId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}artist_id'],
          )!,
      album:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}album'],
          )!,
      albumId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}album_id'],
          )!,
      coverArtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art_id'],
      ),
      duration:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}duration'],
          )!,
      track: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track'],
      ),
      discNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_number'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      bitRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bit_rate'],
      ),
      suffix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suffix'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      ),
      playCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}play_count'],
          )!,
      starred: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starred'],
      ),
      lastPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played'],
      ),
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      ),
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
    );
  }

  @override
  $CachedSongsTable createAlias(String alias) {
    return $CachedSongsTable(attachedDatabase, alias);
  }
}

class CachedSong extends DataClass implements Insertable<CachedSong> {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final String? coverArtId;
  final int duration;
  final int? track;
  final int? discNumber;
  final int? year;
  final String? genre;
  final int? bitRate;
  final String? suffix;
  final int? size;
  final int playCount;
  final DateTime? starred;
  final DateTime? lastPlayed;
  final String? localFilePath;
  final DateTime cachedAt;
  const CachedSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.album,
    required this.albumId,
    this.coverArtId,
    required this.duration,
    this.track,
    this.discNumber,
    this.year,
    this.genre,
    this.bitRate,
    this.suffix,
    this.size,
    required this.playCount,
    this.starred,
    this.lastPlayed,
    this.localFilePath,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['artist_id'] = Variable<String>(artistId);
    map['album'] = Variable<String>(album);
    map['album_id'] = Variable<String>(albumId);
    if (!nullToAbsent || coverArtId != null) {
      map['cover_art_id'] = Variable<String>(coverArtId);
    }
    map['duration'] = Variable<int>(duration);
    if (!nullToAbsent || track != null) {
      map['track'] = Variable<int>(track);
    }
    if (!nullToAbsent || discNumber != null) {
      map['disc_number'] = Variable<int>(discNumber);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || bitRate != null) {
      map['bit_rate'] = Variable<int>(bitRate);
    }
    if (!nullToAbsent || suffix != null) {
      map['suffix'] = Variable<String>(suffix);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<int>(size);
    }
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || starred != null) {
      map['starred'] = Variable<DateTime>(starred);
    }
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<DateTime>(lastPlayed);
    }
    if (!nullToAbsent || localFilePath != null) {
      map['local_file_path'] = Variable<String>(localFilePath);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedSongsCompanion toCompanion(bool nullToAbsent) {
    return CachedSongsCompanion(
      id: Value(id),
      title: Value(title),
      artist: Value(artist),
      artistId: Value(artistId),
      album: Value(album),
      albumId: Value(albumId),
      coverArtId:
          coverArtId == null && nullToAbsent
              ? const Value.absent()
              : Value(coverArtId),
      duration: Value(duration),
      track:
          track == null && nullToAbsent ? const Value.absent() : Value(track),
      discNumber:
          discNumber == null && nullToAbsent
              ? const Value.absent()
              : Value(discNumber),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      genre:
          genre == null && nullToAbsent ? const Value.absent() : Value(genre),
      bitRate:
          bitRate == null && nullToAbsent
              ? const Value.absent()
              : Value(bitRate),
      suffix:
          suffix == null && nullToAbsent ? const Value.absent() : Value(suffix),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      playCount: Value(playCount),
      starred:
          starred == null && nullToAbsent
              ? const Value.absent()
              : Value(starred),
      lastPlayed:
          lastPlayed == null && nullToAbsent
              ? const Value.absent()
              : Value(lastPlayed),
      localFilePath:
          localFilePath == null && nullToAbsent
              ? const Value.absent()
              : Value(localFilePath),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedSong.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSong(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      artistId: serializer.fromJson<String>(json['artistId']),
      album: serializer.fromJson<String>(json['album']),
      albumId: serializer.fromJson<String>(json['albumId']),
      coverArtId: serializer.fromJson<String?>(json['coverArtId']),
      duration: serializer.fromJson<int>(json['duration']),
      track: serializer.fromJson<int?>(json['track']),
      discNumber: serializer.fromJson<int?>(json['discNumber']),
      year: serializer.fromJson<int?>(json['year']),
      genre: serializer.fromJson<String?>(json['genre']),
      bitRate: serializer.fromJson<int?>(json['bitRate']),
      suffix: serializer.fromJson<String?>(json['suffix']),
      size: serializer.fromJson<int?>(json['size']),
      playCount: serializer.fromJson<int>(json['playCount']),
      starred: serializer.fromJson<DateTime?>(json['starred']),
      lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),
      localFilePath: serializer.fromJson<String?>(json['localFilePath']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'artistId': serializer.toJson<String>(artistId),
      'album': serializer.toJson<String>(album),
      'albumId': serializer.toJson<String>(albumId),
      'coverArtId': serializer.toJson<String?>(coverArtId),
      'duration': serializer.toJson<int>(duration),
      'track': serializer.toJson<int?>(track),
      'discNumber': serializer.toJson<int?>(discNumber),
      'year': serializer.toJson<int?>(year),
      'genre': serializer.toJson<String?>(genre),
      'bitRate': serializer.toJson<int?>(bitRate),
      'suffix': serializer.toJson<String?>(suffix),
      'size': serializer.toJson<int?>(size),
      'playCount': serializer.toJson<int>(playCount),
      'starred': serializer.toJson<DateTime?>(starred),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
      'localFilePath': serializer.toJson<String?>(localFilePath),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedSong copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? album,
    String? albumId,
    Value<String?> coverArtId = const Value.absent(),
    int? duration,
    Value<int?> track = const Value.absent(),
    Value<int?> discNumber = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<int?> bitRate = const Value.absent(),
    Value<String?> suffix = const Value.absent(),
    Value<int?> size = const Value.absent(),
    int? playCount,
    Value<DateTime?> starred = const Value.absent(),
    Value<DateTime?> lastPlayed = const Value.absent(),
    Value<String?> localFilePath = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedSong(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    artistId: artistId ?? this.artistId,
    album: album ?? this.album,
    albumId: albumId ?? this.albumId,
    coverArtId: coverArtId.present ? coverArtId.value : this.coverArtId,
    duration: duration ?? this.duration,
    track: track.present ? track.value : this.track,
    discNumber: discNumber.present ? discNumber.value : this.discNumber,
    year: year.present ? year.value : this.year,
    genre: genre.present ? genre.value : this.genre,
    bitRate: bitRate.present ? bitRate.value : this.bitRate,
    suffix: suffix.present ? suffix.value : this.suffix,
    size: size.present ? size.value : this.size,
    playCount: playCount ?? this.playCount,
    starred: starred.present ? starred.value : this.starred,
    lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
    localFilePath:
        localFilePath.present ? localFilePath.value : this.localFilePath,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedSong copyWithCompanion(CachedSongsCompanion data) {
    return CachedSong(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      album: data.album.present ? data.album.value : this.album,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      coverArtId:
          data.coverArtId.present ? data.coverArtId.value : this.coverArtId,
      duration: data.duration.present ? data.duration.value : this.duration,
      track: data.track.present ? data.track.value : this.track,
      discNumber:
          data.discNumber.present ? data.discNumber.value : this.discNumber,
      year: data.year.present ? data.year.value : this.year,
      genre: data.genre.present ? data.genre.value : this.genre,
      bitRate: data.bitRate.present ? data.bitRate.value : this.bitRate,
      suffix: data.suffix.present ? data.suffix.value : this.suffix,
      size: data.size.present ? data.size.value : this.size,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      starred: data.starred.present ? data.starred.value : this.starred,
      lastPlayed:
          data.lastPlayed.present ? data.lastPlayed.value : this.lastPlayed,
      localFilePath:
          data.localFilePath.present
              ? data.localFilePath.value
              : this.localFilePath,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSong(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('artistId: $artistId, ')
          ..write('album: $album, ')
          ..write('albumId: $albumId, ')
          ..write('coverArtId: $coverArtId, ')
          ..write('duration: $duration, ')
          ..write('track: $track, ')
          ..write('discNumber: $discNumber, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('bitRate: $bitRate, ')
          ..write('suffix: $suffix, ')
          ..write('size: $size, ')
          ..write('playCount: $playCount, ')
          ..write('starred: $starred, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    artistId,
    album,
    albumId,
    coverArtId,
    duration,
    track,
    discNumber,
    year,
    genre,
    bitRate,
    suffix,
    size,
    playCount,
    starred,
    lastPlayed,
    localFilePath,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSong &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.artistId == this.artistId &&
          other.album == this.album &&
          other.albumId == this.albumId &&
          other.coverArtId == this.coverArtId &&
          other.duration == this.duration &&
          other.track == this.track &&
          other.discNumber == this.discNumber &&
          other.year == this.year &&
          other.genre == this.genre &&
          other.bitRate == this.bitRate &&
          other.suffix == this.suffix &&
          other.size == this.size &&
          other.playCount == this.playCount &&
          other.starred == this.starred &&
          other.lastPlayed == this.lastPlayed &&
          other.localFilePath == this.localFilePath &&
          other.cachedAt == this.cachedAt);
}

class CachedSongsCompanion extends UpdateCompanion<CachedSong> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> artistId;
  final Value<String> album;
  final Value<String> albumId;
  final Value<String?> coverArtId;
  final Value<int> duration;
  final Value<int?> track;
  final Value<int?> discNumber;
  final Value<int?> year;
  final Value<String?> genre;
  final Value<int?> bitRate;
  final Value<String?> suffix;
  final Value<int?> size;
  final Value<int> playCount;
  final Value<DateTime?> starred;
  final Value<DateTime?> lastPlayed;
  final Value<String?> localFilePath;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedSongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.artistId = const Value.absent(),
    this.album = const Value.absent(),
    this.albumId = const Value.absent(),
    this.coverArtId = const Value.absent(),
    this.duration = const Value.absent(),
    this.track = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.bitRate = const Value.absent(),
    this.suffix = const Value.absent(),
    this.size = const Value.absent(),
    this.playCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSongsCompanion.insert({
    required String id,
    required String title,
    required String artist,
    required String artistId,
    required String album,
    required String albumId,
    this.coverArtId = const Value.absent(),
    required int duration,
    this.track = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.bitRate = const Value.absent(),
    this.suffix = const Value.absent(),
    this.size = const Value.absent(),
    this.playCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.localFilePath = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       artist = Value(artist),
       artistId = Value(artistId),
       album = Value(album),
       albumId = Value(albumId),
       duration = Value(duration),
       cachedAt = Value(cachedAt);
  static Insertable<CachedSong> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? artistId,
    Expression<String>? album,
    Expression<String>? albumId,
    Expression<String>? coverArtId,
    Expression<int>? duration,
    Expression<int>? track,
    Expression<int>? discNumber,
    Expression<int>? year,
    Expression<String>? genre,
    Expression<int>? bitRate,
    Expression<String>? suffix,
    Expression<int>? size,
    Expression<int>? playCount,
    Expression<DateTime>? starred,
    Expression<DateTime>? lastPlayed,
    Expression<String>? localFilePath,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (artistId != null) 'artist_id': artistId,
      if (album != null) 'album': album,
      if (albumId != null) 'album_id': albumId,
      if (coverArtId != null) 'cover_art_id': coverArtId,
      if (duration != null) 'duration': duration,
      if (track != null) 'track': track,
      if (discNumber != null) 'disc_number': discNumber,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (bitRate != null) 'bit_rate': bitRate,
      if (suffix != null) 'suffix': suffix,
      if (size != null) 'size': size,
      if (playCount != null) 'play_count': playCount,
      if (starred != null) 'starred': starred,
      if (lastPlayed != null) 'last_played': lastPlayed,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSongsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? artistId,
    Value<String>? album,
    Value<String>? albumId,
    Value<String?>? coverArtId,
    Value<int>? duration,
    Value<int?>? track,
    Value<int?>? discNumber,
    Value<int?>? year,
    Value<String?>? genre,
    Value<int?>? bitRate,
    Value<String?>? suffix,
    Value<int?>? size,
    Value<int>? playCount,
    Value<DateTime?>? starred,
    Value<DateTime?>? lastPlayed,
    Value<String?>? localFilePath,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedSongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      coverArtId: coverArtId ?? this.coverArtId,
      duration: duration ?? this.duration,
      track: track ?? this.track,
      discNumber: discNumber ?? this.discNumber,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      bitRate: bitRate ?? this.bitRate,
      suffix: suffix ?? this.suffix,
      size: size ?? this.size,
      playCount: playCount ?? this.playCount,
      starred: starred ?? this.starred,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      localFilePath: localFilePath ?? this.localFilePath,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (coverArtId.present) {
      map['cover_art_id'] = Variable<String>(coverArtId.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (track.present) {
      map['track'] = Variable<int>(track.value);
    }
    if (discNumber.present) {
      map['disc_number'] = Variable<int>(discNumber.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (bitRate.present) {
      map['bit_rate'] = Variable<int>(bitRate.value);
    }
    if (suffix.present) {
      map['suffix'] = Variable<String>(suffix.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (starred.present) {
      map['starred'] = Variable<DateTime>(starred.value);
    }
    if (lastPlayed.present) {
      map['last_played'] = Variable<DateTime>(lastPlayed.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('artistId: $artistId, ')
          ..write('album: $album, ')
          ..write('albumId: $albumId, ')
          ..write('coverArtId: $coverArtId, ')
          ..write('duration: $duration, ')
          ..write('track: $track, ')
          ..write('discNumber: $discNumber, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('bitRate: $bitRate, ')
          ..write('suffix: $suffix, ')
          ..write('size: $size, ')
          ..write('playCount: $playCount, ')
          ..write('starred: $starred, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedAlbumsTable extends CachedAlbums
    with TableInfo<$CachedAlbumsTable, CachedAlbum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverArtIdMeta = const VerificationMeta(
    'coverArtId',
  );
  @override
  late final GeneratedColumn<String> coverArtId = GeneratedColumn<String>(
    'cover_art_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _starredMeta = const VerificationMeta(
    'starred',
  );
  @override
  late final GeneratedColumn<DateTime> starred = GeneratedColumn<DateTime>(
    'starred',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdMeta = const VerificationMeta(
    'created',
  );
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    artist,
    artistId,
    coverArtId,
    songCount,
    duration,
    year,
    genre,
    playCount,
    starred,
    created,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAlbum> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('cover_art_id')) {
      context.handle(
        _coverArtIdMeta,
        coverArtId.isAcceptableOrUnknown(
          data['cover_art_id']!,
          _coverArtIdMeta,
        ),
      );
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    } else if (isInserting) {
      context.missing(_songCountMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('starred')) {
      context.handle(
        _starredMeta,
        starred.isAcceptableOrUnknown(data['starred']!, _starredMeta),
      );
    }
    if (data.containsKey('created')) {
      context.handle(
        _createdMeta,
        created.isAcceptableOrUnknown(data['created']!, _createdMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAlbum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAlbum(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      artist:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}artist'],
          )!,
      artistId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}artist_id'],
          )!,
      coverArtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art_id'],
      ),
      songCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}song_count'],
          )!,
      duration:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}duration'],
          )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      ),
      starred: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starred'],
      ),
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      ),
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
    );
  }

  @override
  $CachedAlbumsTable createAlias(String alias) {
    return $CachedAlbumsTable(attachedDatabase, alias);
  }
}

class CachedAlbum extends DataClass implements Insertable<CachedAlbum> {
  final String id;
  final String name;
  final String artist;
  final String artistId;
  final String? coverArtId;
  final int songCount;
  final int duration;
  final int? year;
  final String? genre;
  final int? playCount;
  final DateTime? starred;
  final DateTime? created;
  final DateTime cachedAt;
  const CachedAlbum({
    required this.id,
    required this.name,
    required this.artist,
    required this.artistId,
    this.coverArtId,
    required this.songCount,
    required this.duration,
    this.year,
    this.genre,
    this.playCount,
    this.starred,
    this.created,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['artist'] = Variable<String>(artist);
    map['artist_id'] = Variable<String>(artistId);
    if (!nullToAbsent || coverArtId != null) {
      map['cover_art_id'] = Variable<String>(coverArtId);
    }
    map['song_count'] = Variable<int>(songCount);
    map['duration'] = Variable<int>(duration);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || playCount != null) {
      map['play_count'] = Variable<int>(playCount);
    }
    if (!nullToAbsent || starred != null) {
      map['starred'] = Variable<DateTime>(starred);
    }
    if (!nullToAbsent || created != null) {
      map['created'] = Variable<DateTime>(created);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedAlbumsCompanion toCompanion(bool nullToAbsent) {
    return CachedAlbumsCompanion(
      id: Value(id),
      name: Value(name),
      artist: Value(artist),
      artistId: Value(artistId),
      coverArtId:
          coverArtId == null && nullToAbsent
              ? const Value.absent()
              : Value(coverArtId),
      songCount: Value(songCount),
      duration: Value(duration),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      genre:
          genre == null && nullToAbsent ? const Value.absent() : Value(genre),
      playCount:
          playCount == null && nullToAbsent
              ? const Value.absent()
              : Value(playCount),
      starred:
          starred == null && nullToAbsent
              ? const Value.absent()
              : Value(starred),
      created:
          created == null && nullToAbsent
              ? const Value.absent()
              : Value(created),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedAlbum.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAlbum(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      artist: serializer.fromJson<String>(json['artist']),
      artistId: serializer.fromJson<String>(json['artistId']),
      coverArtId: serializer.fromJson<String?>(json['coverArtId']),
      songCount: serializer.fromJson<int>(json['songCount']),
      duration: serializer.fromJson<int>(json['duration']),
      year: serializer.fromJson<int?>(json['year']),
      genre: serializer.fromJson<String?>(json['genre']),
      playCount: serializer.fromJson<int?>(json['playCount']),
      starred: serializer.fromJson<DateTime?>(json['starred']),
      created: serializer.fromJson<DateTime?>(json['created']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'artist': serializer.toJson<String>(artist),
      'artistId': serializer.toJson<String>(artistId),
      'coverArtId': serializer.toJson<String?>(coverArtId),
      'songCount': serializer.toJson<int>(songCount),
      'duration': serializer.toJson<int>(duration),
      'year': serializer.toJson<int?>(year),
      'genre': serializer.toJson<String?>(genre),
      'playCount': serializer.toJson<int?>(playCount),
      'starred': serializer.toJson<DateTime?>(starred),
      'created': serializer.toJson<DateTime?>(created),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedAlbum copyWith({
    String? id,
    String? name,
    String? artist,
    String? artistId,
    Value<String?> coverArtId = const Value.absent(),
    int? songCount,
    int? duration,
    Value<int?> year = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<int?> playCount = const Value.absent(),
    Value<DateTime?> starred = const Value.absent(),
    Value<DateTime?> created = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedAlbum(
    id: id ?? this.id,
    name: name ?? this.name,
    artist: artist ?? this.artist,
    artistId: artistId ?? this.artistId,
    coverArtId: coverArtId.present ? coverArtId.value : this.coverArtId,
    songCount: songCount ?? this.songCount,
    duration: duration ?? this.duration,
    year: year.present ? year.value : this.year,
    genre: genre.present ? genre.value : this.genre,
    playCount: playCount.present ? playCount.value : this.playCount,
    starred: starred.present ? starred.value : this.starred,
    created: created.present ? created.value : this.created,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedAlbum copyWithCompanion(CachedAlbumsCompanion data) {
    return CachedAlbum(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      artist: data.artist.present ? data.artist.value : this.artist,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      coverArtId:
          data.coverArtId.present ? data.coverArtId.value : this.coverArtId,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
      duration: data.duration.present ? data.duration.value : this.duration,
      year: data.year.present ? data.year.value : this.year,
      genre: data.genre.present ? data.genre.value : this.genre,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      starred: data.starred.present ? data.starred.value : this.starred,
      created: data.created.present ? data.created.value : this.created,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAlbum(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artist: $artist, ')
          ..write('artistId: $artistId, ')
          ..write('coverArtId: $coverArtId, ')
          ..write('songCount: $songCount, ')
          ..write('duration: $duration, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('playCount: $playCount, ')
          ..write('starred: $starred, ')
          ..write('created: $created, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    artist,
    artistId,
    coverArtId,
    songCount,
    duration,
    year,
    genre,
    playCount,
    starred,
    created,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAlbum &&
          other.id == this.id &&
          other.name == this.name &&
          other.artist == this.artist &&
          other.artistId == this.artistId &&
          other.coverArtId == this.coverArtId &&
          other.songCount == this.songCount &&
          other.duration == this.duration &&
          other.year == this.year &&
          other.genre == this.genre &&
          other.playCount == this.playCount &&
          other.starred == this.starred &&
          other.created == this.created &&
          other.cachedAt == this.cachedAt);
}

class CachedAlbumsCompanion extends UpdateCompanion<CachedAlbum> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> artist;
  final Value<String> artistId;
  final Value<String?> coverArtId;
  final Value<int> songCount;
  final Value<int> duration;
  final Value<int?> year;
  final Value<String?> genre;
  final Value<int?> playCount;
  final Value<DateTime?> starred;
  final Value<DateTime?> created;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedAlbumsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.artist = const Value.absent(),
    this.artistId = const Value.absent(),
    this.coverArtId = const Value.absent(),
    this.songCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.playCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.created = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedAlbumsCompanion.insert({
    required String id,
    required String name,
    required String artist,
    required String artistId,
    this.coverArtId = const Value.absent(),
    required int songCount,
    required int duration,
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.playCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.created = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       artist = Value(artist),
       artistId = Value(artistId),
       songCount = Value(songCount),
       duration = Value(duration),
       cachedAt = Value(cachedAt);
  static Insertable<CachedAlbum> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? artist,
    Expression<String>? artistId,
    Expression<String>? coverArtId,
    Expression<int>? songCount,
    Expression<int>? duration,
    Expression<int>? year,
    Expression<String>? genre,
    Expression<int>? playCount,
    Expression<DateTime>? starred,
    Expression<DateTime>? created,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (artist != null) 'artist': artist,
      if (artistId != null) 'artist_id': artistId,
      if (coverArtId != null) 'cover_art_id': coverArtId,
      if (songCount != null) 'song_count': songCount,
      if (duration != null) 'duration': duration,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (playCount != null) 'play_count': playCount,
      if (starred != null) 'starred': starred,
      if (created != null) 'created': created,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedAlbumsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? artist,
    Value<String>? artistId,
    Value<String?>? coverArtId,
    Value<int>? songCount,
    Value<int>? duration,
    Value<int?>? year,
    Value<String?>? genre,
    Value<int?>? playCount,
    Value<DateTime?>? starred,
    Value<DateTime?>? created,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedAlbumsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      coverArtId: coverArtId ?? this.coverArtId,
      songCount: songCount ?? this.songCount,
      duration: duration ?? this.duration,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      playCount: playCount ?? this.playCount,
      starred: starred ?? this.starred,
      created: created ?? this.created,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (coverArtId.present) {
      map['cover_art_id'] = Variable<String>(coverArtId.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (starred.present) {
      map['starred'] = Variable<DateTime>(starred.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAlbumsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artist: $artist, ')
          ..write('artistId: $artistId, ')
          ..write('coverArtId: $coverArtId, ')
          ..write('songCount: $songCount, ')
          ..write('duration: $duration, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('playCount: $playCount, ')
          ..write('starred: $starred, ')
          ..write('created: $created, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedArtistsTable extends CachedArtists
    with TableInfo<$CachedArtistsTable, CachedArtist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverArtIdMeta = const VerificationMeta(
    'coverArtId',
  );
  @override
  late final GeneratedColumn<String> coverArtId = GeneratedColumn<String>(
    'cover_art_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumCountMeta = const VerificationMeta(
    'albumCount',
  );
  @override
  late final GeneratedColumn<int> albumCount = GeneratedColumn<int>(
    'album_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starredMeta = const VerificationMeta(
    'starred',
  );
  @override
  late final GeneratedColumn<DateTime> starred = GeneratedColumn<DateTime>(
    'starred',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    coverArtId,
    albumCount,
    starred,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedArtist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover_art_id')) {
      context.handle(
        _coverArtIdMeta,
        coverArtId.isAcceptableOrUnknown(
          data['cover_art_id']!,
          _coverArtIdMeta,
        ),
      );
    }
    if (data.containsKey('album_count')) {
      context.handle(
        _albumCountMeta,
        albumCount.isAcceptableOrUnknown(data['album_count']!, _albumCountMeta),
      );
    } else if (isInserting) {
      context.missing(_albumCountMeta);
    }
    if (data.containsKey('starred')) {
      context.handle(
        _starredMeta,
        starred.isAcceptableOrUnknown(data['starred']!, _starredMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedArtist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedArtist(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      coverArtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art_id'],
      ),
      albumCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}album_count'],
          )!,
      starred: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starred'],
      ),
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
    );
  }

  @override
  $CachedArtistsTable createAlias(String alias) {
    return $CachedArtistsTable(attachedDatabase, alias);
  }
}

class CachedArtist extends DataClass implements Insertable<CachedArtist> {
  final String id;
  final String name;
  final String? coverArtId;
  final int albumCount;
  final DateTime? starred;
  final DateTime cachedAt;
  const CachedArtist({
    required this.id,
    required this.name,
    this.coverArtId,
    required this.albumCount,
    this.starred,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || coverArtId != null) {
      map['cover_art_id'] = Variable<String>(coverArtId);
    }
    map['album_count'] = Variable<int>(albumCount);
    if (!nullToAbsent || starred != null) {
      map['starred'] = Variable<DateTime>(starred);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedArtistsCompanion toCompanion(bool nullToAbsent) {
    return CachedArtistsCompanion(
      id: Value(id),
      name: Value(name),
      coverArtId:
          coverArtId == null && nullToAbsent
              ? const Value.absent()
              : Value(coverArtId),
      albumCount: Value(albumCount),
      starred:
          starred == null && nullToAbsent
              ? const Value.absent()
              : Value(starred),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedArtist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedArtist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      coverArtId: serializer.fromJson<String?>(json['coverArtId']),
      albumCount: serializer.fromJson<int>(json['albumCount']),
      starred: serializer.fromJson<DateTime?>(json['starred']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'coverArtId': serializer.toJson<String?>(coverArtId),
      'albumCount': serializer.toJson<int>(albumCount),
      'starred': serializer.toJson<DateTime?>(starred),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedArtist copyWith({
    String? id,
    String? name,
    Value<String?> coverArtId = const Value.absent(),
    int? albumCount,
    Value<DateTime?> starred = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedArtist(
    id: id ?? this.id,
    name: name ?? this.name,
    coverArtId: coverArtId.present ? coverArtId.value : this.coverArtId,
    albumCount: albumCount ?? this.albumCount,
    starred: starred.present ? starred.value : this.starred,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedArtist copyWithCompanion(CachedArtistsCompanion data) {
    return CachedArtist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      coverArtId:
          data.coverArtId.present ? data.coverArtId.value : this.coverArtId,
      albumCount:
          data.albumCount.present ? data.albumCount.value : this.albumCount,
      starred: data.starred.present ? data.starred.value : this.starred,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedArtist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverArtId: $coverArtId, ')
          ..write('albumCount: $albumCount, ')
          ..write('starred: $starred, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, coverArtId, albumCount, starred, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedArtist &&
          other.id == this.id &&
          other.name == this.name &&
          other.coverArtId == this.coverArtId &&
          other.albumCount == this.albumCount &&
          other.starred == this.starred &&
          other.cachedAt == this.cachedAt);
}

class CachedArtistsCompanion extends UpdateCompanion<CachedArtist> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> coverArtId;
  final Value<int> albumCount;
  final Value<DateTime?> starred;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedArtistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.coverArtId = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedArtistsCompanion.insert({
    required String id,
    required String name,
    this.coverArtId = const Value.absent(),
    required int albumCount,
    this.starred = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       albumCount = Value(albumCount),
       cachedAt = Value(cachedAt);
  static Insertable<CachedArtist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? coverArtId,
    Expression<int>? albumCount,
    Expression<DateTime>? starred,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (coverArtId != null) 'cover_art_id': coverArtId,
      if (albumCount != null) 'album_count': albumCount,
      if (starred != null) 'starred': starred,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedArtistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? coverArtId,
    Value<int>? albumCount,
    Value<DateTime?>? starred,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedArtistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      coverArtId: coverArtId ?? this.coverArtId,
      albumCount: albumCount ?? this.albumCount,
      starred: starred ?? this.starred,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (coverArtId.present) {
      map['cover_art_id'] = Variable<String>(coverArtId.value);
    }
    if (albumCount.present) {
      map['album_count'] = Variable<int>(albumCount.value);
    }
    if (starred.present) {
      map['starred'] = Variable<DateTime>(starred.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedArtistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverArtId: $coverArtId, ')
          ..write('albumCount: $albumCount, ')
          ..write('starred: $starred, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPlaylistsTable extends LocalPlaylists
    with TableInfo<$LocalPlaylistsTable, LocalPlaylist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPlaylist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPlaylist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPlaylist(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $LocalPlaylistsTable createAlias(String alias) {
    return $LocalPlaylistsTable(attachedDatabase, alias);
  }
}

class LocalPlaylist extends DataClass implements Insertable<LocalPlaylist> {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalPlaylist({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalPlaylistsCompanion toCompanion(bool nullToAbsent) {
    return LocalPlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalPlaylist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPlaylist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalPlaylist copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalPlaylist(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalPlaylist copyWithCompanion(LocalPlaylistsCompanion data) {
    return LocalPlaylist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlaylist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPlaylist &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalPlaylistsCompanion extends UpdateCompanion<LocalPlaylist> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalPlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPlaylistsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalPlaylist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalPlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSongEntriesTable extends PlaylistSongEntries
    with TableInfo<$PlaylistSongEntriesTable, PlaylistSongEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSongEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES local_playlists(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES cached_songs(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    songId,
    sortOrder,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_song_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistSongEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, songId};
  @override
  PlaylistSongEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSongEntry(
      playlistId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}playlist_id'],
          )!,
      songId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}song_id'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
      addedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}added_at'],
          )!,
    );
  }

  @override
  $PlaylistSongEntriesTable createAlias(String alias) {
    return $PlaylistSongEntriesTable(attachedDatabase, alias);
  }
}

class PlaylistSongEntry extends DataClass
    implements Insertable<PlaylistSongEntry> {
  final String playlistId;
  final String songId;
  final int sortOrder;
  final DateTime addedAt;
  const PlaylistSongEntry({
    required this.playlistId,
    required this.songId,
    required this.sortOrder,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['song_id'] = Variable<String>(songId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  PlaylistSongEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongEntriesCompanion(
      playlistId: Value(playlistId),
      songId: Value(songId),
      sortOrder: Value(sortOrder),
      addedAt: Value(addedAt),
    );
  }

  factory PlaylistSongEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSongEntry(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      songId: serializer.fromJson<String>(json['songId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'songId': serializer.toJson<String>(songId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  PlaylistSongEntry copyWith({
    String? playlistId,
    String? songId,
    int? sortOrder,
    DateTime? addedAt,
  }) => PlaylistSongEntry(
    playlistId: playlistId ?? this.playlistId,
    songId: songId ?? this.songId,
    sortOrder: sortOrder ?? this.sortOrder,
    addedAt: addedAt ?? this.addedAt,
  );
  PlaylistSongEntry copyWithCompanion(PlaylistSongEntriesCompanion data) {
    return PlaylistSongEntry(
      playlistId:
          data.playlistId.present ? data.playlistId.value : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongEntry(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, songId, sortOrder, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSongEntry &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.sortOrder == this.sortOrder &&
          other.addedAt == this.addedAt);
}

class PlaylistSongEntriesCompanion extends UpdateCompanion<PlaylistSongEntry> {
  final Value<String> playlistId;
  final Value<String> songId;
  final Value<int> sortOrder;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const PlaylistSongEntriesCompanion({
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistSongEntriesCompanion.insert({
    required String playlistId,
    required String songId,
    required int sortOrder,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songId = Value(songId),
       sortOrder = Value(sortOrder),
       addedAt = Value(addedAt);
  static Insertable<PlaylistSongEntry> custom({
    Expression<String>? playlistId,
    Expression<String>? songId,
    Expression<int>? sortOrder,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistSongEntriesCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? songId,
    Value<int>? sortOrder,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return PlaylistSongEntriesCompanion(
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      sortOrder: sortOrder ?? this.sortOrder,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongEntriesCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayHistoryTable extends PlayHistory
    with TableInfo<$PlayHistoryTable, PlayHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songTitleMeta = const VerificationMeta(
    'songTitle',
  );
  @override
  late final GeneratedColumn<String> songTitle = GeneratedColumn<String>(
    'song_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listenDurationSecMeta = const VerificationMeta(
    'listenDurationSec',
  );
  @override
  late final GeneratedColumn<int> listenDurationSec = GeneratedColumn<int>(
    'listen_duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songId,
    songTitle,
    artist,
    albumId,
    playedAt,
    listenDurationSec,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('song_title')) {
      context.handle(
        _songTitleMeta,
        songTitle.isAcceptableOrUnknown(data['song_title']!, _songTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_songTitleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    if (data.containsKey('listen_duration_sec')) {
      context.handle(
        _listenDurationSecMeta,
        listenDurationSec.isAcceptableOrUnknown(
          data['listen_duration_sec']!,
          _listenDurationSecMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_listenDurationSecMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayHistoryData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      songId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}song_id'],
          )!,
      songTitle:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}song_title'],
          )!,
      artist:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}artist'],
          )!,
      albumId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}album_id'],
          )!,
      playedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}played_at'],
          )!,
      listenDurationSec:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}listen_duration_sec'],
          )!,
    );
  }

  @override
  $PlayHistoryTable createAlias(String alias) {
    return $PlayHistoryTable(attachedDatabase, alias);
  }
}

class PlayHistoryData extends DataClass implements Insertable<PlayHistoryData> {
  final int id;
  final String songId;
  final String songTitle;
  final String artist;
  final String albumId;
  final DateTime playedAt;
  final int listenDurationSec;
  const PlayHistoryData({
    required this.id,
    required this.songId,
    required this.songTitle,
    required this.artist,
    required this.albumId,
    required this.playedAt,
    required this.listenDurationSec,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['song_id'] = Variable<String>(songId);
    map['song_title'] = Variable<String>(songTitle);
    map['artist'] = Variable<String>(artist);
    map['album_id'] = Variable<String>(albumId);
    map['played_at'] = Variable<DateTime>(playedAt);
    map['listen_duration_sec'] = Variable<int>(listenDurationSec);
    return map;
  }

  PlayHistoryCompanion toCompanion(bool nullToAbsent) {
    return PlayHistoryCompanion(
      id: Value(id),
      songId: Value(songId),
      songTitle: Value(songTitle),
      artist: Value(artist),
      albumId: Value(albumId),
      playedAt: Value(playedAt),
      listenDurationSec: Value(listenDurationSec),
    );
  }

  factory PlayHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayHistoryData(
      id: serializer.fromJson<int>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      songTitle: serializer.fromJson<String>(json['songTitle']),
      artist: serializer.fromJson<String>(json['artist']),
      albumId: serializer.fromJson<String>(json['albumId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
      listenDurationSec: serializer.fromJson<int>(json['listenDurationSec']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songId': serializer.toJson<String>(songId),
      'songTitle': serializer.toJson<String>(songTitle),
      'artist': serializer.toJson<String>(artist),
      'albumId': serializer.toJson<String>(albumId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
      'listenDurationSec': serializer.toJson<int>(listenDurationSec),
    };
  }

  PlayHistoryData copyWith({
    int? id,
    String? songId,
    String? songTitle,
    String? artist,
    String? albumId,
    DateTime? playedAt,
    int? listenDurationSec,
  }) => PlayHistoryData(
    id: id ?? this.id,
    songId: songId ?? this.songId,
    songTitle: songTitle ?? this.songTitle,
    artist: artist ?? this.artist,
    albumId: albumId ?? this.albumId,
    playedAt: playedAt ?? this.playedAt,
    listenDurationSec: listenDurationSec ?? this.listenDurationSec,
  );
  PlayHistoryData copyWithCompanion(PlayHistoryCompanion data) {
    return PlayHistoryData(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      songTitle: data.songTitle.present ? data.songTitle.value : this.songTitle,
      artist: data.artist.present ? data.artist.value : this.artist,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      listenDurationSec:
          data.listenDurationSec.present
              ? data.listenDurationSec.value
              : this.listenDurationSec,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryData(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('songTitle: $songTitle, ')
          ..write('artist: $artist, ')
          ..write('albumId: $albumId, ')
          ..write('playedAt: $playedAt, ')
          ..write('listenDurationSec: $listenDurationSec')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    songId,
    songTitle,
    artist,
    albumId,
    playedAt,
    listenDurationSec,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayHistoryData &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.songTitle == this.songTitle &&
          other.artist == this.artist &&
          other.albumId == this.albumId &&
          other.playedAt == this.playedAt &&
          other.listenDurationSec == this.listenDurationSec);
}

class PlayHistoryCompanion extends UpdateCompanion<PlayHistoryData> {
  final Value<int> id;
  final Value<String> songId;
  final Value<String> songTitle;
  final Value<String> artist;
  final Value<String> albumId;
  final Value<DateTime> playedAt;
  final Value<int> listenDurationSec;
  const PlayHistoryCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.songTitle = const Value.absent(),
    this.artist = const Value.absent(),
    this.albumId = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.listenDurationSec = const Value.absent(),
  });
  PlayHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String songId,
    required String songTitle,
    required String artist,
    required String albumId,
    required DateTime playedAt,
    required int listenDurationSec,
  }) : songId = Value(songId),
       songTitle = Value(songTitle),
       artist = Value(artist),
       albumId = Value(albumId),
       playedAt = Value(playedAt),
       listenDurationSec = Value(listenDurationSec);
  static Insertable<PlayHistoryData> custom({
    Expression<int>? id,
    Expression<String>? songId,
    Expression<String>? songTitle,
    Expression<String>? artist,
    Expression<String>? albumId,
    Expression<DateTime>? playedAt,
    Expression<int>? listenDurationSec,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (songTitle != null) 'song_title': songTitle,
      if (artist != null) 'artist': artist,
      if (albumId != null) 'album_id': albumId,
      if (playedAt != null) 'played_at': playedAt,
      if (listenDurationSec != null) 'listen_duration_sec': listenDurationSec,
    });
  }

  PlayHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? songId,
    Value<String>? songTitle,
    Value<String>? artist,
    Value<String>? albumId,
    Value<DateTime>? playedAt,
    Value<int>? listenDurationSec,
  }) {
    return PlayHistoryCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      songTitle: songTitle ?? this.songTitle,
      artist: artist ?? this.artist,
      albumId: albumId ?? this.albumId,
      playedAt: playedAt ?? this.playedAt,
      listenDurationSec: listenDurationSec ?? this.listenDurationSec,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (songTitle.present) {
      map['song_title'] = Variable<String>(songTitle.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (listenDurationSec.present) {
      map['listen_duration_sec'] = Variable<int>(listenDurationSec.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('songTitle: $songTitle, ')
          ..write('artist: $artist, ')
          ..write('albumId: $albumId, ')
          ..write('playedAt: $playedAt, ')
          ..write('listenDurationSec: $listenDurationSec')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, Download> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songId,
    localPath,
    fileSize,
    status,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Download> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Download map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Download(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      songId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}song_id'],
          )!,
      localPath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}local_path'],
          )!,
      fileSize:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}file_size'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      downloadedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}downloaded_at'],
          )!,
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }
}

class Download extends DataClass implements Insertable<Download> {
  final String id;
  final String songId;
  final String localPath;
  final int fileSize;
  final String status;
  final DateTime downloadedAt;
  const Download({
    required this.id,
    required this.songId,
    required this.localPath,
    required this.fileSize,
    required this.status,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['song_id'] = Variable<String>(songId);
    map['local_path'] = Variable<String>(localPath);
    map['file_size'] = Variable<int>(fileSize);
    map['status'] = Variable<String>(status);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      id: Value(id),
      songId: Value(songId),
      localPath: Value(localPath),
      fileSize: Value(fileSize),
      status: Value(status),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory Download.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Download(
      id: serializer.fromJson<String>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      status: serializer.fromJson<String>(json['status']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'songId': serializer.toJson<String>(songId),
      'localPath': serializer.toJson<String>(localPath),
      'fileSize': serializer.toJson<int>(fileSize),
      'status': serializer.toJson<String>(status),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  Download copyWith({
    String? id,
    String? songId,
    String? localPath,
    int? fileSize,
    String? status,
    DateTime? downloadedAt,
  }) => Download(
    id: id ?? this.id,
    songId: songId ?? this.songId,
    localPath: localPath ?? this.localPath,
    fileSize: fileSize ?? this.fileSize,
    status: status ?? this.status,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  Download copyWithCompanion(DownloadsCompanion data) {
    return Download(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      status: data.status.present ? data.status.value : this.status,
      downloadedAt:
          data.downloadedAt.present
              ? data.downloadedAt.value
              : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Download(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('localPath: $localPath, ')
          ..write('fileSize: $fileSize, ')
          ..write('status: $status, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, songId, localPath, fileSize, status, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Download &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.localPath == this.localPath &&
          other.fileSize == this.fileSize &&
          other.status == this.status &&
          other.downloadedAt == this.downloadedAt);
}

class DownloadsCompanion extends UpdateCompanion<Download> {
  final Value<String> id;
  final Value<String> songId;
  final Value<String> localPath;
  final Value<int> fileSize;
  final Value<String> status;
  final Value<DateTime> downloadedAt;
  final Value<int> rowid;
  const DownloadsCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.status = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadsCompanion.insert({
    required String id,
    required String songId,
    required String localPath,
    required int fileSize,
    required String status,
    required DateTime downloadedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       songId = Value(songId),
       localPath = Value(localPath),
       fileSize = Value(fileSize),
       status = Value(status),
       downloadedAt = Value(downloadedAt);
  static Insertable<Download> custom({
    Expression<String>? id,
    Expression<String>? songId,
    Expression<String>? localPath,
    Expression<int>? fileSize,
    Expression<String>? status,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (localPath != null) 'local_path': localPath,
      if (fileSize != null) 'file_size': fileSize,
      if (status != null) 'status': status,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadsCompanion copyWith({
    Value<String>? id,
    Value<String>? songId,
    Value<String>? localPath,
    Value<int>? fileSize,
    Value<String>? status,
    Value<DateTime>? downloadedAt,
    Value<int>? rowid,
  }) {
    return DownloadsCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('localPath: $localPath, ')
          ..write('fileSize: $fileSize, ')
          ..write('status: $status, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedLyricsTable extends CachedLyrics
    with TableInfo<$CachedLyricsTable, CachedLyric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedLyricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
  );
  static const VerificationMeta _rawLrcMeta = const VerificationMeta('rawLrc');
  @override
  late final GeneratedColumn<String> rawLrc = GeneratedColumn<String>(
    'raw_lrc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linesJsonMeta = const VerificationMeta(
    'linesJson',
  );
  @override
  late final GeneratedColumn<String> linesJson = GeneratedColumn<String>(
    'lines_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    songId,
    source,
    isSynced,
    rawLrc,
    linesJson,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_lyrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedLyric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    } else if (isInserting) {
      context.missing(_isSyncedMeta);
    }
    if (data.containsKey('raw_lrc')) {
      context.handle(
        _rawLrcMeta,
        rawLrc.isAcceptableOrUnknown(data['raw_lrc']!, _rawLrcMeta),
      );
    }
    if (data.containsKey('lines_json')) {
      context.handle(
        _linesJsonMeta,
        linesJson.isAcceptableOrUnknown(data['lines_json']!, _linesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_linesJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  CachedLyric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedLyric(
      songId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}song_id'],
          )!,
      source:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}source'],
          )!,
      isSynced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_synced'],
          )!,
      rawLrc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_lrc'],
      ),
      linesJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}lines_json'],
          )!,
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
    );
  }

  @override
  $CachedLyricsTable createAlias(String alias) {
    return $CachedLyricsTable(attachedDatabase, alias);
  }
}

class CachedLyric extends DataClass implements Insertable<CachedLyric> {
  final String songId;
  final String source;
  final bool isSynced;
  final String? rawLrc;
  final String linesJson;
  final DateTime cachedAt;
  const CachedLyric({
    required this.songId,
    required this.source,
    required this.isSynced,
    this.rawLrc,
    required this.linesJson,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['source'] = Variable<String>(source);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || rawLrc != null) {
      map['raw_lrc'] = Variable<String>(rawLrc);
    }
    map['lines_json'] = Variable<String>(linesJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedLyricsCompanion toCompanion(bool nullToAbsent) {
    return CachedLyricsCompanion(
      songId: Value(songId),
      source: Value(source),
      isSynced: Value(isSynced),
      rawLrc:
          rawLrc == null && nullToAbsent ? const Value.absent() : Value(rawLrc),
      linesJson: Value(linesJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedLyric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedLyric(
      songId: serializer.fromJson<String>(json['songId']),
      source: serializer.fromJson<String>(json['source']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      rawLrc: serializer.fromJson<String?>(json['rawLrc']),
      linesJson: serializer.fromJson<String>(json['linesJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'source': serializer.toJson<String>(source),
      'isSynced': serializer.toJson<bool>(isSynced),
      'rawLrc': serializer.toJson<String?>(rawLrc),
      'linesJson': serializer.toJson<String>(linesJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedLyric copyWith({
    String? songId,
    String? source,
    bool? isSynced,
    Value<String?> rawLrc = const Value.absent(),
    String? linesJson,
    DateTime? cachedAt,
  }) => CachedLyric(
    songId: songId ?? this.songId,
    source: source ?? this.source,
    isSynced: isSynced ?? this.isSynced,
    rawLrc: rawLrc.present ? rawLrc.value : this.rawLrc,
    linesJson: linesJson ?? this.linesJson,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedLyric copyWithCompanion(CachedLyricsCompanion data) {
    return CachedLyric(
      songId: data.songId.present ? data.songId.value : this.songId,
      source: data.source.present ? data.source.value : this.source,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      rawLrc: data.rawLrc.present ? data.rawLrc.value : this.rawLrc,
      linesJson: data.linesJson.present ? data.linesJson.value : this.linesJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedLyric(')
          ..write('songId: $songId, ')
          ..write('source: $source, ')
          ..write('isSynced: $isSynced, ')
          ..write('rawLrc: $rawLrc, ')
          ..write('linesJson: $linesJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(songId, source, isSynced, rawLrc, linesJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedLyric &&
          other.songId == this.songId &&
          other.source == this.source &&
          other.isSynced == this.isSynced &&
          other.rawLrc == this.rawLrc &&
          other.linesJson == this.linesJson &&
          other.cachedAt == this.cachedAt);
}

class CachedLyricsCompanion extends UpdateCompanion<CachedLyric> {
  final Value<String> songId;
  final Value<String> source;
  final Value<bool> isSynced;
  final Value<String?> rawLrc;
  final Value<String> linesJson;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedLyricsCompanion({
    this.songId = const Value.absent(),
    this.source = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rawLrc = const Value.absent(),
    this.linesJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedLyricsCompanion.insert({
    required String songId,
    required String source,
    required bool isSynced,
    this.rawLrc = const Value.absent(),
    required String linesJson,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       source = Value(source),
       isSynced = Value(isSynced),
       linesJson = Value(linesJson),
       cachedAt = Value(cachedAt);
  static Insertable<CachedLyric> custom({
    Expression<String>? songId,
    Expression<String>? source,
    Expression<bool>? isSynced,
    Expression<String>? rawLrc,
    Expression<String>? linesJson,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (source != null) 'source': source,
      if (isSynced != null) 'is_synced': isSynced,
      if (rawLrc != null) 'raw_lrc': rawLrc,
      if (linesJson != null) 'lines_json': linesJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedLyricsCompanion copyWith({
    Value<String>? songId,
    Value<String>? source,
    Value<bool>? isSynced,
    Value<String?>? rawLrc,
    Value<String>? linesJson,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedLyricsCompanion(
      songId: songId ?? this.songId,
      source: source ?? this.source,
      isSynced: isSynced ?? this.isSynced,
      rawLrc: rawLrc ?? this.rawLrc,
      linesJson: linesJson ?? this.linesJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rawLrc.present) {
      map['raw_lrc'] = Variable<String>(rawLrc.value);
    }
    if (linesJson.present) {
      map['lines_json'] = Variable<String>(linesJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedLyricsCompanion(')
          ..write('songId: $songId, ')
          ..write('source: $source, ')
          ..write('isSynced: $isSynced, ')
          ..write('rawLrc: $rawLrc, ')
          ..write('linesJson: $linesJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServerConfigsTable extends ServerConfigs
    with TableInfo<$ServerConfigsTable, ServerConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedPasswordMeta = const VerificationMeta(
    'encryptedPassword',
  );
  @override
  late final GeneratedColumn<String> encryptedPassword =
      GeneratedColumn<String>(
        'encrypted_password',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastConnectedMeta = const VerificationMeta(
    'lastConnected',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnected =
      GeneratedColumn<DateTime>(
        'last_connected',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    baseUrl,
    username,
    encryptedPassword,
    isActive,
    lastConnected,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('encrypted_password')) {
      context.handle(
        _encryptedPasswordMeta,
        encryptedPassword.isAcceptableOrUnknown(
          data['encrypted_password']!,
          _encryptedPasswordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPasswordMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_connected')) {
      context.handle(
        _lastConnectedMeta,
        lastConnected.isAcceptableOrUnknown(
          data['last_connected']!,
          _lastConnectedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServerConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerConfig(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      baseUrl:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}base_url'],
          )!,
      username:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}username'],
          )!,
      encryptedPassword:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}encrypted_password'],
          )!,
      isActive:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_active'],
          )!,
      lastConnected: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected'],
      ),
    );
  }

  @override
  $ServerConfigsTable createAlias(String alias) {
    return $ServerConfigsTable(attachedDatabase, alias);
  }
}

class ServerConfig extends DataClass implements Insertable<ServerConfig> {
  final String id;
  final String baseUrl;
  final String username;
  final String encryptedPassword;
  final bool isActive;
  final DateTime? lastConnected;
  const ServerConfig({
    required this.id,
    required this.baseUrl,
    required this.username,
    required this.encryptedPassword,
    required this.isActive,
    this.lastConnected,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['base_url'] = Variable<String>(baseUrl);
    map['username'] = Variable<String>(username);
    map['encrypted_password'] = Variable<String>(encryptedPassword);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastConnected != null) {
      map['last_connected'] = Variable<DateTime>(lastConnected);
    }
    return map;
  }

  ServerConfigsCompanion toCompanion(bool nullToAbsent) {
    return ServerConfigsCompanion(
      id: Value(id),
      baseUrl: Value(baseUrl),
      username: Value(username),
      encryptedPassword: Value(encryptedPassword),
      isActive: Value(isActive),
      lastConnected:
          lastConnected == null && nullToAbsent
              ? const Value.absent()
              : Value(lastConnected),
    );
  }

  factory ServerConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerConfig(
      id: serializer.fromJson<String>(json['id']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      username: serializer.fromJson<String>(json['username']),
      encryptedPassword: serializer.fromJson<String>(json['encryptedPassword']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastConnected: serializer.fromJson<DateTime?>(json['lastConnected']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'username': serializer.toJson<String>(username),
      'encryptedPassword': serializer.toJson<String>(encryptedPassword),
      'isActive': serializer.toJson<bool>(isActive),
      'lastConnected': serializer.toJson<DateTime?>(lastConnected),
    };
  }

  ServerConfig copyWith({
    String? id,
    String? baseUrl,
    String? username,
    String? encryptedPassword,
    bool? isActive,
    Value<DateTime?> lastConnected = const Value.absent(),
  }) => ServerConfig(
    id: id ?? this.id,
    baseUrl: baseUrl ?? this.baseUrl,
    username: username ?? this.username,
    encryptedPassword: encryptedPassword ?? this.encryptedPassword,
    isActive: isActive ?? this.isActive,
    lastConnected:
        lastConnected.present ? lastConnected.value : this.lastConnected,
  );
  ServerConfig copyWithCompanion(ServerConfigsCompanion data) {
    return ServerConfig(
      id: data.id.present ? data.id.value : this.id,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      username: data.username.present ? data.username.value : this.username,
      encryptedPassword:
          data.encryptedPassword.present
              ? data.encryptedPassword.value
              : this.encryptedPassword,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastConnected:
          data.lastConnected.present
              ? data.lastConnected.value
              : this.lastConnected,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerConfig(')
          ..write('id: $id, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('isActive: $isActive, ')
          ..write('lastConnected: $lastConnected')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    baseUrl,
    username,
    encryptedPassword,
    isActive,
    lastConnected,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerConfig &&
          other.id == this.id &&
          other.baseUrl == this.baseUrl &&
          other.username == this.username &&
          other.encryptedPassword == this.encryptedPassword &&
          other.isActive == this.isActive &&
          other.lastConnected == this.lastConnected);
}

class ServerConfigsCompanion extends UpdateCompanion<ServerConfig> {
  final Value<String> id;
  final Value<String> baseUrl;
  final Value<String> username;
  final Value<String> encryptedPassword;
  final Value<bool> isActive;
  final Value<DateTime?> lastConnected;
  final Value<int> rowid;
  const ServerConfigsCompanion({
    this.id = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.username = const Value.absent(),
    this.encryptedPassword = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastConnected = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServerConfigsCompanion.insert({
    required String id,
    required String baseUrl,
    required String username,
    required String encryptedPassword,
    this.isActive = const Value.absent(),
    this.lastConnected = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       baseUrl = Value(baseUrl),
       username = Value(username),
       encryptedPassword = Value(encryptedPassword);
  static Insertable<ServerConfig> custom({
    Expression<String>? id,
    Expression<String>? baseUrl,
    Expression<String>? username,
    Expression<String>? encryptedPassword,
    Expression<bool>? isActive,
    Expression<DateTime>? lastConnected,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baseUrl != null) 'base_url': baseUrl,
      if (username != null) 'username': username,
      if (encryptedPassword != null) 'encrypted_password': encryptedPassword,
      if (isActive != null) 'is_active': isActive,
      if (lastConnected != null) 'last_connected': lastConnected,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServerConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? baseUrl,
    Value<String>? username,
    Value<String>? encryptedPassword,
    Value<bool>? isActive,
    Value<DateTime?>? lastConnected,
    Value<int>? rowid,
  }) {
    return ServerConfigsCompanion(
      id: id ?? this.id,
      baseUrl: baseUrl ?? this.baseUrl,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      isActive: isActive ?? this.isActive,
      lastConnected: lastConnected ?? this.lastConnected,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (encryptedPassword.present) {
      map['encrypted_password'] = Variable<String>(encryptedPassword.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastConnected.present) {
      map['last_connected'] = Variable<DateTime>(lastConnected.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerConfigsCompanion(')
          ..write('id: $id, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('isActive: $isActive, ')
          ..write('lastConnected: $lastConnected, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedSongsTable cachedSongs = $CachedSongsTable(this);
  late final $CachedAlbumsTable cachedAlbums = $CachedAlbumsTable(this);
  late final $CachedArtistsTable cachedArtists = $CachedArtistsTable(this);
  late final $LocalPlaylistsTable localPlaylists = $LocalPlaylistsTable(this);
  late final $PlaylistSongEntriesTable playlistSongEntries =
      $PlaylistSongEntriesTable(this);
  late final $PlayHistoryTable playHistory = $PlayHistoryTable(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  late final $CachedLyricsTable cachedLyrics = $CachedLyricsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ServerConfigsTable serverConfigs = $ServerConfigsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedSongs,
    cachedAlbums,
    cachedArtists,
    localPlaylists,
    playlistSongEntries,
    playHistory,
    downloads,
    cachedLyrics,
    appSettings,
    serverConfigs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_song_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cached_songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_song_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CachedSongsTableCreateCompanionBuilder =
    CachedSongsCompanion Function({
      required String id,
      required String title,
      required String artist,
      required String artistId,
      required String album,
      required String albumId,
      Value<String?> coverArtId,
      required int duration,
      Value<int?> track,
      Value<int?> discNumber,
      Value<int?> year,
      Value<String?> genre,
      Value<int?> bitRate,
      Value<String?> suffix,
      Value<int?> size,
      Value<int> playCount,
      Value<DateTime?> starred,
      Value<DateTime?> lastPlayed,
      Value<String?> localFilePath,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedSongsTableUpdateCompanionBuilder =
    CachedSongsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> artist,
      Value<String> artistId,
      Value<String> album,
      Value<String> albumId,
      Value<String?> coverArtId,
      Value<int> duration,
      Value<int?> track,
      Value<int?> discNumber,
      Value<int?> year,
      Value<String?> genre,
      Value<int?> bitRate,
      Value<String?> suffix,
      Value<int?> size,
      Value<int> playCount,
      Value<DateTime?> starred,
      Value<DateTime?> lastPlayed,
      Value<String?> localFilePath,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

final class $$CachedSongsTableReferences
    extends BaseReferences<_$AppDatabase, $CachedSongsTable, CachedSong> {
  $$CachedSongsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistSongEntriesTable, List<PlaylistSongEntry>>
  _playlistSongEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistSongEntries,
        aliasName: $_aliasNameGenerator(
          db.cachedSongs.id,
          db.playlistSongEntries.songId,
        ),
      );

  $$PlaylistSongEntriesTableProcessedTableManager get playlistSongEntriesRefs {
    final manager = $$PlaylistSongEntriesTableTableManager(
      $_db,
      $_db.playlistSongEntries,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistSongEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CachedSongsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSongsTable> {
  $$CachedSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitRate => $composableBuilder(
    column: $table.bitRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suffix => $composableBuilder(
    column: $table.suffix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistSongEntriesRefs(
    Expression<bool> Function($$PlaylistSongEntriesTableFilterComposer f) f,
  ) {
    final $$PlaylistSongEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongEntries,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongEntriesTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CachedSongsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSongsTable> {
  $$CachedSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitRate => $composableBuilder(
    column: $table.bitRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suffix => $composableBuilder(
    column: $table.suffix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedSongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSongsTable> {
  $$CachedSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get track =>
      $composableBuilder(column: $table.track, builder: (column) => column);

  GeneratedColumn<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get bitRate =>
      $composableBuilder(column: $table.bitRate, builder: (column) => column);

  GeneratedColumn<String> get suffix =>
      $composableBuilder(column: $table.suffix, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  Expression<T> playlistSongEntriesRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongEntriesTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistSongEntries,
          getReferencedColumn: (t) => t.songId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistSongEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistSongEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CachedSongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSongsTable,
          CachedSong,
          $$CachedSongsTableFilterComposer,
          $$CachedSongsTableOrderingComposer,
          $$CachedSongsTableAnnotationComposer,
          $$CachedSongsTableCreateCompanionBuilder,
          $$CachedSongsTableUpdateCompanionBuilder,
          (CachedSong, $$CachedSongsTableReferences),
          CachedSong,
          PrefetchHooks Function({bool playlistSongEntriesRefs})
        > {
  $$CachedSongsTableTableManager(_$AppDatabase db, $CachedSongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CachedSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$CachedSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> artistId = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String> albumId = const Value.absent(),
                Value<String?> coverArtId = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int?> track = const Value.absent(),
                Value<int?> discNumber = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> bitRate = const Value.absent(),
                Value<String?> suffix = const Value.absent(),
                Value<int?> size = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> starred = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSongsCompanion(
                id: id,
                title: title,
                artist: artist,
                artistId: artistId,
                album: album,
                albumId: albumId,
                coverArtId: coverArtId,
                duration: duration,
                track: track,
                discNumber: discNumber,
                year: year,
                genre: genre,
                bitRate: bitRate,
                suffix: suffix,
                size: size,
                playCount: playCount,
                starred: starred,
                lastPlayed: lastPlayed,
                localFilePath: localFilePath,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String artist,
                required String artistId,
                required String album,
                required String albumId,
                Value<String?> coverArtId = const Value.absent(),
                required int duration,
                Value<int?> track = const Value.absent(),
                Value<int?> discNumber = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> bitRate = const Value.absent(),
                Value<String?> suffix = const Value.absent(),
                Value<int?> size = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> starred = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedSongsCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                artistId: artistId,
                album: album,
                albumId: albumId,
                coverArtId: coverArtId,
                duration: duration,
                track: track,
                discNumber: discNumber,
                year: year,
                genre: genre,
                bitRate: bitRate,
                suffix: suffix,
                size: size,
                playCount: playCount,
                starred: starred,
                lastPlayed: lastPlayed,
                localFilePath: localFilePath,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CachedSongsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({playlistSongEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistSongEntriesRefs) db.playlistSongEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistSongEntriesRefs)
                    await $_getPrefetchedData<
                      CachedSong,
                      $CachedSongsTable,
                      PlaylistSongEntry
                    >(
                      currentTable: table,
                      referencedTable: $$CachedSongsTableReferences
                          ._playlistSongEntriesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CachedSongsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistSongEntriesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.songId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CachedSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedSongsTable,
      CachedSong,
      $$CachedSongsTableFilterComposer,
      $$CachedSongsTableOrderingComposer,
      $$CachedSongsTableAnnotationComposer,
      $$CachedSongsTableCreateCompanionBuilder,
      $$CachedSongsTableUpdateCompanionBuilder,
      (CachedSong, $$CachedSongsTableReferences),
      CachedSong,
      PrefetchHooks Function({bool playlistSongEntriesRefs})
    >;
typedef $$CachedAlbumsTableCreateCompanionBuilder =
    CachedAlbumsCompanion Function({
      required String id,
      required String name,
      required String artist,
      required String artistId,
      Value<String?> coverArtId,
      required int songCount,
      required int duration,
      Value<int?> year,
      Value<String?> genre,
      Value<int?> playCount,
      Value<DateTime?> starred,
      Value<DateTime?> created,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedAlbumsTableUpdateCompanionBuilder =
    CachedAlbumsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> artist,
      Value<String> artistId,
      Value<String?> coverArtId,
      Value<int> songCount,
      Value<int> duration,
      Value<int?> year,
      Value<String?> genre,
      Value<int?> playCount,
      Value<DateTime?> starred,
      Value<DateTime?> created,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedAlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAlbumsTable> {
  $$CachedAlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedAlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAlbumsTable> {
  $$CachedAlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedAlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAlbumsTable> {
  $$CachedAlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedAlbumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedAlbumsTable,
          CachedAlbum,
          $$CachedAlbumsTableFilterComposer,
          $$CachedAlbumsTableOrderingComposer,
          $$CachedAlbumsTableAnnotationComposer,
          $$CachedAlbumsTableCreateCompanionBuilder,
          $$CachedAlbumsTableUpdateCompanionBuilder,
          (
            CachedAlbum,
            BaseReferences<_$AppDatabase, $CachedAlbumsTable, CachedAlbum>,
          ),
          CachedAlbum,
          PrefetchHooks Function()
        > {
  $$CachedAlbumsTableTableManager(_$AppDatabase db, $CachedAlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedAlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CachedAlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$CachedAlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> artistId = const Value.absent(),
                Value<String?> coverArtId = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> playCount = const Value.absent(),
                Value<DateTime?> starred = const Value.absent(),
                Value<DateTime?> created = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAlbumsCompanion(
                id: id,
                name: name,
                artist: artist,
                artistId: artistId,
                coverArtId: coverArtId,
                songCount: songCount,
                duration: duration,
                year: year,
                genre: genre,
                playCount: playCount,
                starred: starred,
                created: created,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String artist,
                required String artistId,
                Value<String?> coverArtId = const Value.absent(),
                required int songCount,
                required int duration,
                Value<int?> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> playCount = const Value.absent(),
                Value<DateTime?> starred = const Value.absent(),
                Value<DateTime?> created = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedAlbumsCompanion.insert(
                id: id,
                name: name,
                artist: artist,
                artistId: artistId,
                coverArtId: coverArtId,
                songCount: songCount,
                duration: duration,
                year: year,
                genre: genre,
                playCount: playCount,
                starred: starred,
                created: created,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedAlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedAlbumsTable,
      CachedAlbum,
      $$CachedAlbumsTableFilterComposer,
      $$CachedAlbumsTableOrderingComposer,
      $$CachedAlbumsTableAnnotationComposer,
      $$CachedAlbumsTableCreateCompanionBuilder,
      $$CachedAlbumsTableUpdateCompanionBuilder,
      (
        CachedAlbum,
        BaseReferences<_$AppDatabase, $CachedAlbumsTable, CachedAlbum>,
      ),
      CachedAlbum,
      PrefetchHooks Function()
    >;
typedef $$CachedArtistsTableCreateCompanionBuilder =
    CachedArtistsCompanion Function({
      required String id,
      required String name,
      Value<String?> coverArtId,
      required int albumCount,
      Value<DateTime?> starred,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedArtistsTableUpdateCompanionBuilder =
    CachedArtistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> coverArtId,
      Value<int> albumCount,
      Value<DateTime?> starred,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedArtistsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedArtistsTable> {
  $$CachedArtistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedArtistsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedArtistsTable> {
  $$CachedArtistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedArtistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedArtistsTable> {
  $$CachedArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedArtistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedArtistsTable,
          CachedArtist,
          $$CachedArtistsTableFilterComposer,
          $$CachedArtistsTableOrderingComposer,
          $$CachedArtistsTableAnnotationComposer,
          $$CachedArtistsTableCreateCompanionBuilder,
          $$CachedArtistsTableUpdateCompanionBuilder,
          (
            CachedArtist,
            BaseReferences<_$AppDatabase, $CachedArtistsTable, CachedArtist>,
          ),
          CachedArtist,
          PrefetchHooks Function()
        > {
  $$CachedArtistsTableTableManager(_$AppDatabase db, $CachedArtistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$CachedArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CachedArtistsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> coverArtId = const Value.absent(),
                Value<int> albumCount = const Value.absent(),
                Value<DateTime?> starred = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedArtistsCompanion(
                id: id,
                name: name,
                coverArtId: coverArtId,
                albumCount: albumCount,
                starred: starred,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> coverArtId = const Value.absent(),
                required int albumCount,
                Value<DateTime?> starred = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedArtistsCompanion.insert(
                id: id,
                name: name,
                coverArtId: coverArtId,
                albumCount: albumCount,
                starred: starred,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedArtistsTable,
      CachedArtist,
      $$CachedArtistsTableFilterComposer,
      $$CachedArtistsTableOrderingComposer,
      $$CachedArtistsTableAnnotationComposer,
      $$CachedArtistsTableCreateCompanionBuilder,
      $$CachedArtistsTableUpdateCompanionBuilder,
      (
        CachedArtist,
        BaseReferences<_$AppDatabase, $CachedArtistsTable, CachedArtist>,
      ),
      CachedArtist,
      PrefetchHooks Function()
    >;
typedef $$LocalPlaylistsTableCreateCompanionBuilder =
    LocalPlaylistsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalPlaylistsTableUpdateCompanionBuilder =
    LocalPlaylistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LocalPlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalPlaylistsTable, LocalPlaylist> {
  $$LocalPlaylistsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PlaylistSongEntriesTable, List<PlaylistSongEntry>>
  _playlistSongEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistSongEntries,
        aliasName: $_aliasNameGenerator(
          db.localPlaylists.id,
          db.playlistSongEntries.playlistId,
        ),
      );

  $$PlaylistSongEntriesTableProcessedTableManager get playlistSongEntriesRefs {
    final manager = $$PlaylistSongEntriesTableTableManager(
      $_db,
      $_db.playlistSongEntries,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistSongEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalPlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPlaylistsTable> {
  $$LocalPlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistSongEntriesRefs(
    Expression<bool> Function($$PlaylistSongEntriesTableFilterComposer f) f,
  ) {
    final $$PlaylistSongEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongEntries,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongEntriesTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalPlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPlaylistsTable> {
  $$LocalPlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPlaylistsTable> {
  $$LocalPlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> playlistSongEntriesRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongEntriesTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistSongEntries,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistSongEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistSongEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalPlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPlaylistsTable,
          LocalPlaylist,
          $$LocalPlaylistsTableFilterComposer,
          $$LocalPlaylistsTableOrderingComposer,
          $$LocalPlaylistsTableAnnotationComposer,
          $$LocalPlaylistsTableCreateCompanionBuilder,
          $$LocalPlaylistsTableUpdateCompanionBuilder,
          (LocalPlaylist, $$LocalPlaylistsTableReferences),
          LocalPlaylist,
          PrefetchHooks Function({bool playlistSongEntriesRefs})
        > {
  $$LocalPlaylistsTableTableManager(
    _$AppDatabase db,
    $LocalPlaylistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalPlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalPlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalPlaylistsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlaylistsCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalPlaylistsCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LocalPlaylistsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({playlistSongEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistSongEntriesRefs) db.playlistSongEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistSongEntriesRefs)
                    await $_getPrefetchedData<
                      LocalPlaylist,
                      $LocalPlaylistsTable,
                      PlaylistSongEntry
                    >(
                      currentTable: table,
                      referencedTable: $$LocalPlaylistsTableReferences
                          ._playlistSongEntriesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$LocalPlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistSongEntriesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.playlistId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalPlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPlaylistsTable,
      LocalPlaylist,
      $$LocalPlaylistsTableFilterComposer,
      $$LocalPlaylistsTableOrderingComposer,
      $$LocalPlaylistsTableAnnotationComposer,
      $$LocalPlaylistsTableCreateCompanionBuilder,
      $$LocalPlaylistsTableUpdateCompanionBuilder,
      (LocalPlaylist, $$LocalPlaylistsTableReferences),
      LocalPlaylist,
      PrefetchHooks Function({bool playlistSongEntriesRefs})
    >;
typedef $$PlaylistSongEntriesTableCreateCompanionBuilder =
    PlaylistSongEntriesCompanion Function({
      required String playlistId,
      required String songId,
      required int sortOrder,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$PlaylistSongEntriesTableUpdateCompanionBuilder =
    PlaylistSongEntriesCompanion Function({
      Value<String> playlistId,
      Value<String> songId,
      Value<int> sortOrder,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$PlaylistSongEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistSongEntriesTable,
          PlaylistSongEntry
        > {
  $$PlaylistSongEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalPlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.localPlaylists.createAlias(
        $_aliasNameGenerator(
          db.playlistSongEntries.playlistId,
          db.localPlaylists.id,
        ),
      );

  $$LocalPlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$LocalPlaylistsTableTableManager(
      $_db,
      $_db.localPlaylists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CachedSongsTable _songIdTable(_$AppDatabase db) =>
      db.cachedSongs.createAlias(
        $_aliasNameGenerator(db.playlistSongEntries.songId, db.cachedSongs.id),
      );

  $$CachedSongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$CachedSongsTableTableManager(
      $_db,
      $_db.cachedSongs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistSongEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistSongEntriesTable> {
  $$PlaylistSongEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalPlaylistsTableFilterComposer get playlistId {
    final $$LocalPlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.localPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalPlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.localPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CachedSongsTableFilterComposer get songId {
    final $$CachedSongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.cachedSongs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedSongsTableFilterComposer(
            $db: $db,
            $table: $db.cachedSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistSongEntriesTable> {
  $$PlaylistSongEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalPlaylistsTableOrderingComposer get playlistId {
    final $$LocalPlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.localPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalPlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.localPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CachedSongsTableOrderingComposer get songId {
    final $$CachedSongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.cachedSongs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedSongsTableOrderingComposer(
            $db: $db,
            $table: $db.cachedSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistSongEntriesTable> {
  $$PlaylistSongEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$LocalPlaylistsTableAnnotationComposer get playlistId {
    final $$LocalPlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.localPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalPlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.localPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CachedSongsTableAnnotationComposer get songId {
    final $$CachedSongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.cachedSongs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedSongsTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistSongEntriesTable,
          PlaylistSongEntry,
          $$PlaylistSongEntriesTableFilterComposer,
          $$PlaylistSongEntriesTableOrderingComposer,
          $$PlaylistSongEntriesTableAnnotationComposer,
          $$PlaylistSongEntriesTableCreateCompanionBuilder,
          $$PlaylistSongEntriesTableUpdateCompanionBuilder,
          (PlaylistSongEntry, $$PlaylistSongEntriesTableReferences),
          PlaylistSongEntry,
          PrefetchHooks Function({bool playlistId, bool songId})
        > {
  $$PlaylistSongEntriesTableTableManager(
    _$AppDatabase db,
    $PlaylistSongEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PlaylistSongEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$PlaylistSongEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$PlaylistSongEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongEntriesCompanion(
                playlistId: playlistId,
                songId: songId,
                sortOrder: sortOrder,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String songId,
                required int sortOrder,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongEntriesCompanion.insert(
                playlistId: playlistId,
                songId: songId,
                sortOrder: sortOrder,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PlaylistSongEntriesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({playlistId = false, songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (playlistId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.playlistId,
                            referencedTable:
                                $$PlaylistSongEntriesTableReferences
                                    ._playlistIdTable(db),
                            referencedColumn:
                                $$PlaylistSongEntriesTableReferences
                                    ._playlistIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (songId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.songId,
                            referencedTable:
                                $$PlaylistSongEntriesTableReferences
                                    ._songIdTable(db),
                            referencedColumn:
                                $$PlaylistSongEntriesTableReferences
                                    ._songIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistSongEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistSongEntriesTable,
      PlaylistSongEntry,
      $$PlaylistSongEntriesTableFilterComposer,
      $$PlaylistSongEntriesTableOrderingComposer,
      $$PlaylistSongEntriesTableAnnotationComposer,
      $$PlaylistSongEntriesTableCreateCompanionBuilder,
      $$PlaylistSongEntriesTableUpdateCompanionBuilder,
      (PlaylistSongEntry, $$PlaylistSongEntriesTableReferences),
      PlaylistSongEntry,
      PrefetchHooks Function({bool playlistId, bool songId})
    >;
typedef $$PlayHistoryTableCreateCompanionBuilder =
    PlayHistoryCompanion Function({
      Value<int> id,
      required String songId,
      required String songTitle,
      required String artist,
      required String albumId,
      required DateTime playedAt,
      required int listenDurationSec,
    });
typedef $$PlayHistoryTableUpdateCompanionBuilder =
    PlayHistoryCompanion Function({
      Value<int> id,
      Value<String> songId,
      Value<String> songTitle,
      Value<String> artist,
      Value<String> albumId,
      Value<DateTime> playedAt,
      Value<int> listenDurationSec,
    });

class $$PlayHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songTitle => $composableBuilder(
    column: $table.songTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listenDurationSec => $composableBuilder(
    column: $table.listenDurationSec,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songTitle => $composableBuilder(
    column: $table.songTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listenDurationSec => $composableBuilder(
    column: $table.listenDurationSec,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<String> get songTitle =>
      $composableBuilder(column: $table.songTitle, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get listenDurationSec => $composableBuilder(
    column: $table.listenDurationSec,
    builder: (column) => column,
  );
}

class $$PlayHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayHistoryTable,
          PlayHistoryData,
          $$PlayHistoryTableFilterComposer,
          $$PlayHistoryTableOrderingComposer,
          $$PlayHistoryTableAnnotationComposer,
          $$PlayHistoryTableCreateCompanionBuilder,
          $$PlayHistoryTableUpdateCompanionBuilder,
          (
            PlayHistoryData,
            BaseReferences<_$AppDatabase, $PlayHistoryTable, PlayHistoryData>,
          ),
          PlayHistoryData,
          PrefetchHooks Function()
        > {
  $$PlayHistoryTableTableManager(_$AppDatabase db, $PlayHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PlayHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PlayHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$PlayHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<String> songTitle = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> albumId = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> listenDurationSec = const Value.absent(),
              }) => PlayHistoryCompanion(
                id: id,
                songId: songId,
                songTitle: songTitle,
                artist: artist,
                albumId: albumId,
                playedAt: playedAt,
                listenDurationSec: listenDurationSec,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String songId,
                required String songTitle,
                required String artist,
                required String albumId,
                required DateTime playedAt,
                required int listenDurationSec,
              }) => PlayHistoryCompanion.insert(
                id: id,
                songId: songId,
                songTitle: songTitle,
                artist: artist,
                albumId: albumId,
                playedAt: playedAt,
                listenDurationSec: listenDurationSec,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayHistoryTable,
      PlayHistoryData,
      $$PlayHistoryTableFilterComposer,
      $$PlayHistoryTableOrderingComposer,
      $$PlayHistoryTableAnnotationComposer,
      $$PlayHistoryTableCreateCompanionBuilder,
      $$PlayHistoryTableUpdateCompanionBuilder,
      (
        PlayHistoryData,
        BaseReferences<_$AppDatabase, $PlayHistoryTable, PlayHistoryData>,
      ),
      PlayHistoryData,
      PrefetchHooks Function()
    >;
typedef $$DownloadsTableCreateCompanionBuilder =
    DownloadsCompanion Function({
      required String id,
      required String songId,
      required String localPath,
      required int fileSize,
      required String status,
      required DateTime downloadedAt,
      Value<int> rowid,
    });
typedef $$DownloadsTableUpdateCompanionBuilder =
    DownloadsCompanion Function({
      Value<String> id,
      Value<String> songId,
      Value<String> localPath,
      Value<int> fileSize,
      Value<String> status,
      Value<DateTime> downloadedAt,
      Value<int> rowid,
    });

class $$DownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$DownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadsTable,
          Download,
          $$DownloadsTableFilterComposer,
          $$DownloadsTableOrderingComposer,
          $$DownloadsTableAnnotationComposer,
          $$DownloadsTableCreateCompanionBuilder,
          $$DownloadsTableUpdateCompanionBuilder,
          (Download, BaseReferences<_$AppDatabase, $DownloadsTable, Download>),
          Download,
          PrefetchHooks Function()
        > {
  $$DownloadsTableTableManager(_$AppDatabase db, $DownloadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadsCompanion(
                id: id,
                songId: songId,
                localPath: localPath,
                fileSize: fileSize,
                status: status,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String songId,
                required String localPath,
                required int fileSize,
                required String status,
                required DateTime downloadedAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadsCompanion.insert(
                id: id,
                songId: songId,
                localPath: localPath,
                fileSize: fileSize,
                status: status,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadsTable,
      Download,
      $$DownloadsTableFilterComposer,
      $$DownloadsTableOrderingComposer,
      $$DownloadsTableAnnotationComposer,
      $$DownloadsTableCreateCompanionBuilder,
      $$DownloadsTableUpdateCompanionBuilder,
      (Download, BaseReferences<_$AppDatabase, $DownloadsTable, Download>),
      Download,
      PrefetchHooks Function()
    >;
typedef $$CachedLyricsTableCreateCompanionBuilder =
    CachedLyricsCompanion Function({
      required String songId,
      required String source,
      required bool isSynced,
      Value<String?> rawLrc,
      required String linesJson,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedLyricsTableUpdateCompanionBuilder =
    CachedLyricsCompanion Function({
      Value<String> songId,
      Value<String> source,
      Value<bool> isSynced,
      Value<String?> rawLrc,
      Value<String> linesJson,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedLyricsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedLyricsTable> {
  $$CachedLyricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawLrc => $composableBuilder(
    column: $table.rawLrc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linesJson => $composableBuilder(
    column: $table.linesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedLyricsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedLyricsTable> {
  $$CachedLyricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawLrc => $composableBuilder(
    column: $table.rawLrc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linesJson => $composableBuilder(
    column: $table.linesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedLyricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedLyricsTable> {
  $$CachedLyricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get rawLrc =>
      $composableBuilder(column: $table.rawLrc, builder: (column) => column);

  GeneratedColumn<String> get linesJson =>
      $composableBuilder(column: $table.linesJson, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedLyricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedLyricsTable,
          CachedLyric,
          $$CachedLyricsTableFilterComposer,
          $$CachedLyricsTableOrderingComposer,
          $$CachedLyricsTableAnnotationComposer,
          $$CachedLyricsTableCreateCompanionBuilder,
          $$CachedLyricsTableUpdateCompanionBuilder,
          (
            CachedLyric,
            BaseReferences<_$AppDatabase, $CachedLyricsTable, CachedLyric>,
          ),
          CachedLyric,
          PrefetchHooks Function()
        > {
  $$CachedLyricsTableTableManager(_$AppDatabase db, $CachedLyricsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedLyricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CachedLyricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$CachedLyricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> rawLrc = const Value.absent(),
                Value<String> linesJson = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedLyricsCompanion(
                songId: songId,
                source: source,
                isSynced: isSynced,
                rawLrc: rawLrc,
                linesJson: linesJson,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                required String source,
                required bool isSynced,
                Value<String?> rawLrc = const Value.absent(),
                required String linesJson,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedLyricsCompanion.insert(
                songId: songId,
                source: source,
                isSynced: isSynced,
                rawLrc: rawLrc,
                linesJson: linesJson,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedLyricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedLyricsTable,
      CachedLyric,
      $$CachedLyricsTableFilterComposer,
      $$CachedLyricsTableOrderingComposer,
      $$CachedLyricsTableAnnotationComposer,
      $$CachedLyricsTableCreateCompanionBuilder,
      $$CachedLyricsTableUpdateCompanionBuilder,
      (
        CachedLyric,
        BaseReferences<_$AppDatabase, $CachedLyricsTable, CachedLyric>,
      ),
      CachedLyric,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ServerConfigsTableCreateCompanionBuilder =
    ServerConfigsCompanion Function({
      required String id,
      required String baseUrl,
      required String username,
      required String encryptedPassword,
      Value<bool> isActive,
      Value<DateTime?> lastConnected,
      Value<int> rowid,
    });
typedef $$ServerConfigsTableUpdateCompanionBuilder =
    ServerConfigsCompanion Function({
      Value<String> id,
      Value<String> baseUrl,
      Value<String> username,
      Value<String> encryptedPassword,
      Value<bool> isActive,
      Value<DateTime?> lastConnected,
      Value<int> rowid,
    });

class $$ServerConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $ServerConfigsTable> {
  $$ServerConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnected => $composableBuilder(
    column: $table.lastConnected,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServerConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServerConfigsTable> {
  $$ServerConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnected => $composableBuilder(
    column: $table.lastConnected,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServerConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServerConfigsTable> {
  $$ServerConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastConnected => $composableBuilder(
    column: $table.lastConnected,
    builder: (column) => column,
  );
}

class $$ServerConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServerConfigsTable,
          ServerConfig,
          $$ServerConfigsTableFilterComposer,
          $$ServerConfigsTableOrderingComposer,
          $$ServerConfigsTableAnnotationComposer,
          $$ServerConfigsTableCreateCompanionBuilder,
          $$ServerConfigsTableUpdateCompanionBuilder,
          (
            ServerConfig,
            BaseReferences<_$AppDatabase, $ServerConfigsTable, ServerConfig>,
          ),
          ServerConfig,
          PrefetchHooks Function()
        > {
  $$ServerConfigsTableTableManager(_$AppDatabase db, $ServerConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ServerConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$ServerConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ServerConfigsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> encryptedPassword = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastConnected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServerConfigsCompanion(
                id: id,
                baseUrl: baseUrl,
                username: username,
                encryptedPassword: encryptedPassword,
                isActive: isActive,
                lastConnected: lastConnected,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String baseUrl,
                required String username,
                required String encryptedPassword,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastConnected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServerConfigsCompanion.insert(
                id: id,
                baseUrl: baseUrl,
                username: username,
                encryptedPassword: encryptedPassword,
                isActive: isActive,
                lastConnected: lastConnected,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServerConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServerConfigsTable,
      ServerConfig,
      $$ServerConfigsTableFilterComposer,
      $$ServerConfigsTableOrderingComposer,
      $$ServerConfigsTableAnnotationComposer,
      $$ServerConfigsTableCreateCompanionBuilder,
      $$ServerConfigsTableUpdateCompanionBuilder,
      (
        ServerConfig,
        BaseReferences<_$AppDatabase, $ServerConfigsTable, ServerConfig>,
      ),
      ServerConfig,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedSongsTableTableManager get cachedSongs =>
      $$CachedSongsTableTableManager(_db, _db.cachedSongs);
  $$CachedAlbumsTableTableManager get cachedAlbums =>
      $$CachedAlbumsTableTableManager(_db, _db.cachedAlbums);
  $$CachedArtistsTableTableManager get cachedArtists =>
      $$CachedArtistsTableTableManager(_db, _db.cachedArtists);
  $$LocalPlaylistsTableTableManager get localPlaylists =>
      $$LocalPlaylistsTableTableManager(_db, _db.localPlaylists);
  $$PlaylistSongEntriesTableTableManager get playlistSongEntries =>
      $$PlaylistSongEntriesTableTableManager(_db, _db.playlistSongEntries);
  $$PlayHistoryTableTableManager get playHistory =>
      $$PlayHistoryTableTableManager(_db, _db.playHistory);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
  $$CachedLyricsTableTableManager get cachedLyrics =>
      $$CachedLyricsTableTableManager(_db, _db.cachedLyrics);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ServerConfigsTableTableManager get serverConfigs =>
      $$ServerConfigsTableTableManager(_db, _db.serverConfigs);
}
