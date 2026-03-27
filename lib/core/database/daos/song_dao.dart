import 'package:drift/drift.dart';

import '../app_database.dart';

part 'song_dao.g.dart';

@DriftAccessor(tables: [CachedSongs])
class SongDao extends DatabaseAccessor<AppDatabase> with _$SongDaoMixin {
  SongDao(super.db);

  Future<List<CachedSong>> getAllSongs() => select(cachedSongs).get();

  Future<CachedSong?> getSongById(String id) {
    return (select(cachedSongs)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertSong(CachedSongsCompanion song) async {
    await into(cachedSongs).insertOnConflictUpdate(song);
  }

  Future<void> insertOrUpdateSongs(List<CachedSongsCompanion> songs) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(cachedSongs, songs);
    });
  }

  Future<void> updateSongLocalPath(String id, String? path) async {
    await (update(cachedSongs)..where((tbl) => tbl.id.equals(id))).write(
      CachedSongsCompanion(
        localFilePath: Value(path),
      ),
    );
  }

  Future<List<CachedSong>> getDownloadedSongs() {
    return (select(cachedSongs)..where((tbl) => tbl.localFilePath.isNotNull())).get();
  }

  Future<int> deleteSong(String id) {
    return (delete(cachedSongs)..where((tbl) => tbl.id.equals(id))).go();
  }
}
