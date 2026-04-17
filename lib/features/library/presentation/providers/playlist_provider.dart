import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/features/library/data/models/subsonic_response_models.dart';
import 'package:sonexa/features/library/domain/entities/playlist.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';

final _playlistDiag = DiagnosticLogger.instance.module('playlist');

final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final api = await ref.watch(subsonicApiClientProvider.future);
  await _playlistDiag.log('fetch playlists start', scope: 'provider');
  final response = await api.getPlaylists();
  final body = response.subsonicResponseBody;
  final playlists = body?['playlists'] as Map<String, dynamic>?;
  final items = playlists?['playlist'] as List<dynamic>? ?? [];

  await _playlistDiag.log(
    'fetch playlists done: count=${items.length}',
    scope: 'provider',
  );

  return items
      .map((playlist) => _parsePlaylist(playlist as Map<String, dynamic>))
      .toList();
});

class PlaylistCrudNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createPlaylist(String name) async {
    state = const AsyncLoading();
    await _playlistDiag.log('create start: name=$name', scope: 'crud');
    state = await AsyncValue.guard(() async {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.createPlaylist(name: name);
      _invalidateAll();
      await _playlistDiag.log('create done: name=$name', scope: 'crud');
    });
    if (state.hasError) {
      await _playlistDiag.error(
        'create playlist',
        state.error!,
        stackTrace: state.stackTrace,
        scope: 'crud',
        fields: {'name': name},
      );
    }
  }

  Future<void> renamePlaylist(String playlistId, String name) async {
    state = const AsyncLoading();
    await _playlistDiag.log(
      'rename start: playlistId=$playlistId, name=$name',
      scope: 'crud',
    );
    state = await AsyncValue.guard(() async {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.updatePlaylist(playlistId: playlistId, name: name);
      _invalidateAll();
      await _playlistDiag.log(
        'rename done: playlistId=$playlistId, name=$name',
        scope: 'crud',
      );
    });
    if (state.hasError) {
      await _playlistDiag.error(
        'rename playlist',
        state.error!,
        stackTrace: state.stackTrace,
        scope: 'crud',
        fields: {'playlistId': playlistId, 'name': name},
      );
    }
  }

  Future<void> deletePlaylist(String id) async {
    state = const AsyncLoading();
    await _playlistDiag.log('delete start: playlistId=$id', scope: 'crud');
    state = await AsyncValue.guard(() async {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.deletePlaylist(id);
      _invalidateAll();
      await _playlistDiag.log('delete done: playlistId=$id', scope: 'crud');
    });
    if (state.hasError) {
      await _playlistDiag.error(
        'delete playlist',
        state.error!,
        stackTrace: state.stackTrace,
        scope: 'crud',
        fields: {'playlistId': id},
      );
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    state = const AsyncLoading();
    await _playlistDiag.log(
      'add song start: playlistId=$playlistId, songId=$songId',
      scope: 'crud',
    );
    state = await AsyncValue.guard(() async {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.updatePlaylist(playlistId: playlistId, songIdsToAdd: [songId]);
      _invalidateAll(playlistId: playlistId);
      await _playlistDiag.log(
        'add song done: playlistId=$playlistId, songId=$songId',
        scope: 'crud',
      );
    });
    if (state.hasError) {
      await _playlistDiag.error(
        'add song to playlist',
        state.error!,
        stackTrace: state.stackTrace,
        scope: 'crud',
        fields: {'playlistId': playlistId, 'songId': songId},
      );
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, int songIndex) async {
    state = const AsyncLoading();
    await _playlistDiag.log(
      'remove song start: playlistId=$playlistId, songIndex=$songIndex',
      scope: 'crud',
    );
    state = await AsyncValue.guard(() async {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.updatePlaylist(
        playlistId: playlistId,
        songIndexesToRemove: [songIndex],
      );
      _invalidateAll(playlistId: playlistId);
      await _playlistDiag.log(
        'remove song done: playlistId=$playlistId, songIndex=$songIndex',
        scope: 'crud',
      );
    });
    if (state.hasError) {
      await _playlistDiag.error(
        'remove song from playlist',
        state.error!,
        stackTrace: state.stackTrace,
        scope: 'crud',
        fields: {'playlistId': playlistId, 'songIndex': songIndex},
      );
    }
  }

  void _invalidateAll({String? playlistId}) {
    ref.invalidate(playlistsProvider);
    if (playlistId != null) {
      ref.invalidate(playlistDetailProvider(playlistId));
    }
  }
}

final playlistCrudNotifierProvider =
    AsyncNotifierProvider<PlaylistCrudNotifier, void>(PlaylistCrudNotifier.new);

Playlist _parsePlaylist(Map<String, dynamic> json) => Playlist(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  comment: json['comment'] as String?,
  isPublic: json['public'] as bool? ?? false,
  songCount: json['songCount'] as int? ?? 0,
  duration: json['duration'] as int? ?? 0,
  coverArtId: json['coverArt'] as String?,
  owner: json['owner'] as String? ?? '',
  created:
      json['created'] != null
          ? DateTime.tryParse(json['created'] as String)
          : null,
  changed:
      json['changed'] != null
          ? DateTime.tryParse(json['changed'] as String)
          : null,
);
