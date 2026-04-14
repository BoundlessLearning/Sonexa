import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonexa/features/home/presentation/providers/home_provider.dart';
import 'package:sonexa/features/library/domain/entities/song.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
      final notifier = FavoritesNotifier(ref);

      ref.listen<AsyncValue<List<Song>>>(starredSongsProvider, (_, next) {
        next.whenData(notifier.replaceWithServerSongs);
      });

      final initialFavorites = ref.watch(starredSongsProvider).valueOrNull;
      if (initialFavorites != null) {
        notifier.replaceWithServerSongs(initialFavorites);
      }

      return notifier;
    });

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._ref) : super(<String>{});

  final Ref _ref;

  bool isFavorite(String songId) => state.contains(songId);

  void replaceWithServerSongs(List<Song> songs) {
    state = songs.map((song) => song.id).toSet();
  }

  Future<void> toggleFavorite(String songId) async {
    final previousState = state;
    final isCurrentlyFavorite = previousState.contains(songId);
    final nextState = Set<String>.from(previousState);

    if (isCurrentlyFavorite) {
      nextState.remove(songId);
    } else {
      nextState.add(songId);
    }
    state = nextState;

    try {
      final api = await _ref.read(subsonicApiClientProvider.future);
      if (isCurrentlyFavorite) {
        await api.unstar(songId: songId);
      } else {
        await api.star(songId: songId);
      }
      _ref.invalidate(starredSongsProvider);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}
