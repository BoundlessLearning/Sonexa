String buildStableImageCacheKey(String? url) {
  if (url == null || url.isEmpty) {
    return '';
  }

  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return url;
  }

  final queryEntries =
      uri.queryParametersAll.entries
          .where((entry) => !_authQueryKeys.contains(entry.key))
          .map(
            (entry) => MapEntry<String, List<String>>(
              entry.key,
              [...entry.value]..sort(),
            ),
          )
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));

  final normalizedQuery = <String, dynamic>{
    for (final entry in queryEntries)
      entry.key: entry.value.length == 1 ? entry.value.first : entry.value,
  };

  return uri
      .replace(
        userInfo: '',
        queryParameters: normalizedQuery.isEmpty ? null : normalizedQuery,
        fragment: null,
      )
      .toString();
}

const Set<String> _authQueryKeys = {'u', 't', 's', 'p', 'c', 'v', 'f'};
