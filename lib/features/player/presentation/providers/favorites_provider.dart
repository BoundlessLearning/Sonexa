import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
      return FavoritesNotifier(ref);
    });

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._ref) : super(<String>{});

  final Ref _ref;

  bool isFavorite(String songId) => state.contains(songId);

  Future<void> toggleFavorite(String songId) async {
    final previousState = state;
    final isCurrentlyFavorite = previousState.contains(songId);

    // 先乐观更新 UI，失败时再回滚，保证交互更流畅。
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
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}
