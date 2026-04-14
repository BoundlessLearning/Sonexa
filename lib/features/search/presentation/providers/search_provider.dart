import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/features/library/data/repositories/library_repository.dart';
import 'package:sonexa/features/library/presentation/providers/library_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultProvider = FutureProvider<SearchResult?>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return null;
  final repo = await ref.watch(libraryRepositoryProvider.future);
  return repo.search(query);
});
