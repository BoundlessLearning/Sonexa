import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ohmymusic/features/library/data/repositories/library_repository.dart';
import 'package:ohmymusic/features/library/presentation/providers/library_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultProvider = FutureProvider<SearchResult?>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return null;
  final repo = ref.read(libraryRepositoryProvider);
  return repo.search(query);
});
