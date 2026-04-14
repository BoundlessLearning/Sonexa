import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/features/library/data/models/subsonic_response_models.dart';
import 'package:sonexa/features/library/domain/entities/playlist.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';

final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final api = await ref.watch(subsonicApiClientProvider.future);
  final response = await api.getPlaylists();
  final body = response.subsonicResponseBody;
  final playlists = body?['playlists'] as Map<String, dynamic>?;
  final items = playlists?['playlist'] as List<dynamic>? ?? [];

  return items
      .map((playlist) => _parsePlaylist(playlist as Map<String, dynamic>))
      .toList();
});

class PlaylistCrudNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createPlaylist(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.createPlaylist(name: name);
      _invalidateAll();
    });
  }

  Future<void> renamePlaylist(String playlistId, String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.updatePlaylist(
            playlistId: playlistId,
            name: name,
          );
      _invalidateAll();
    });
  }

  Future<void> deletePlaylist(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.deletePlaylist(id);
      _invalidateAll();
    });
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.updatePlaylist(
            playlistId: playlistId,
            songIdsToAdd: [songId],
          );
      _invalidateAll(playlistId: playlistId);
    });
  }

  Future<void> removeSongFromPlaylist(String playlistId, int songIndex) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = await ref.read(subsonicApiClientProvider.future);
      await api.updatePlaylist(
            playlistId: playlistId,
            songIndexesToRemove: [songIndex],
          );
      _invalidateAll(playlistId: playlistId);
    });
  }

  void _invalidateAll({String? playlistId}) {
    ref.invalidate(playlistsProvider);
    if (playlistId != null) {
      ref.invalidate(playlistDetailProvider(playlistId));
    }
  }
}

final playlistCrudNotifierProvider =
    AsyncNotifierProvider<PlaylistCrudNotifier, void>(
      PlaylistCrudNotifier.new,
    );

Playlist _parsePlaylist(Map<String, dynamic> json) => Playlist(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      comment: json['comment'] as String?,
      isPublic: json['public'] as bool? ?? false,
      songCount: json['songCount'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      coverArtId: json['coverArt'] as String?,
      owner: json['owner'] as String? ?? '',
      created: json['created'] != null
          ? DateTime.tryParse(json['created'] as String)
          : null,
      changed: json['changed'] != null
          ? DateTime.tryParse(json['changed'] as String)
          : null,
    );
