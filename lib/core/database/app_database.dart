import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class CachedSongs extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get artistId => text()();
  TextColumn get album => text()();
  TextColumn get albumId => text()();
  TextColumn get coverArtId => text().nullable()();
  IntColumn get duration => integer()();
  IntColumn get track => integer().nullable()();
  IntColumn get discNumber => integer().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get bitRate => integer().nullable()();
  TextColumn get suffix => text().nullable()();
  IntColumn get size => integer().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get starred => dateTime().nullable()();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
  TextColumn get localFilePath => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedAlbums extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get artist => text()();
  TextColumn get artistId => text()();
  TextColumn get coverArtId => text().nullable()();
  IntColumn get songCount => integer()();
  IntColumn get duration => integer()();
  IntColumn get year => integer().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get playCount => integer().nullable()();
  DateTimeColumn get starred => dateTime().nullable()();
  DateTimeColumn get created => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedArtists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get coverArtId => text().nullable()();
  IntColumn get albumCount => integer()();
  DateTimeColumn get starred => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalPlaylists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PlaylistSongEntries extends Table {
  TextColumn get playlistId =>
      text().customConstraint(
        'REFERENCES local_playlists(id) ON DELETE CASCADE',
      )();
  TextColumn get songId =>
      text().customConstraint(
        'REFERENCES cached_songs(id) ON DELETE CASCADE',
      )();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, songId};
}

class PlayHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get songId => text()();
  TextColumn get songTitle => text()();
  TextColumn get artist => text()();
  TextColumn get albumId => text()();
  DateTimeColumn get playedAt => dateTime()();
  IntColumn get listenDurationSec => integer()();
}

class Downloads extends Table {
  TextColumn get id => text()();
  TextColumn get songId => text()();
  TextColumn get localPath => text()();
  IntColumn get fileSize => integer()();
  TextColumn get status => text()();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedLyrics extends Table {
  TextColumn get songId => text()();
  TextColumn get source => text()();
  BoolColumn get isSynced => boolean()();
  TextColumn get rawLrc => text().nullable()();
  TextColumn get linesJson => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {songId};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class ServerConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get baseUrl => text()();
  TextColumn get username => text()();
  TextColumn get password => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastConnected => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    CachedSongs,
    CachedAlbums,
    CachedArtists,
    LocalPlaylists,
    PlaylistSongEntries,
    PlayHistory,
    Downloads,
    CachedLyrics,
    AppSettings,
    ServerConfigs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor})
    : super(executor ?? driftDatabase(name: 'sonexa_db'));

  static const currentSchemaVersion = 2;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      for (var version = from; version < to; version++) {
        switch (version) {
          case 1:
            await migrator.addColumn(serverConfigs, serverConfigs.password);
            await customStatement(
              'UPDATE server_configs SET password = encrypted_password',
            );
            break;
          default:
            throw StateError(
              'Missing database migration from schema $version to ${version + 1}.',
            );
        }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
