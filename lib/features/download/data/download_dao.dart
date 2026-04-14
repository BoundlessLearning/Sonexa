import 'package:drift/drift.dart';
import 'package:sonexa/core/database/app_database.dart';

class DownloadDao {
  DownloadDao(this._db);

  final AppDatabase _db;

  Future<void> insertDownload(DownloadsCompanion entry) async {
    await _db.into(_db.downloads).insertOnConflictUpdate(entry);
  }

  Future<void> updateDownloadStatus(String id, String status) async {
    await (_db.update(_db.downloads)..where((tbl) => tbl.id.equals(id))).write(
      DownloadsCompanion(status: Value(status)),
    );
  }

  Future<List<Download>> getAllDownloads() {
    return (_db.select(_db.downloads)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.downloadedAt)]))
        .get();
  }

  Future<Download?> getDownloadBySongId(String songId) {
    return (_db.select(_db.downloads)
          ..where((tbl) => tbl.songId.equals(songId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.downloadedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> deleteDownload(String id) async {
    await (_db.delete(_db.downloads)..where((tbl) => tbl.id.equals(id))).go();
  }

  Stream<List<Download>> watchAllDownloads() {
    return (_db.select(_db.downloads)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.downloadedAt)]))
        .watch();
  }
}
