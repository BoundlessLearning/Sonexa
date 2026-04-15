class TimedMemoryCache {
  TimedMemoryCache({required this.ttl, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Duration ttl;
  final DateTime Function() _now;
  final Map<String, _TimedMemoryCacheEntry> _entries = {};

  Future<T> getOrLoad<T>(
    String key,
    Future<T> Function() loader, {
    bool forceRefresh = false,
  }) async {
    final existing = _entries[key];
    final now = _now();
    if (!forceRefresh && existing != null && existing.isFresh(now, ttl)) {
      return await existing.value as T;
    }

    final future = loader();
    final entry = _TimedMemoryCacheEntry(createdAt: now, value: future);
    _entries[key] = entry;

    try {
      return await future;
    } catch (_) {
      if (identical(_entries[key], entry)) {
        _entries.remove(key);
      }
      rethrow;
    }
  }

  void remove(String key) {
    _entries.remove(key);
  }

  void clear() {
    _entries.clear();
  }
}

class _TimedMemoryCacheEntry {
  const _TimedMemoryCacheEntry({required this.createdAt, required this.value});

  final DateTime createdAt;
  final Future<Object?> value;

  bool isFresh(DateTime now, Duration ttl) {
    return now.difference(createdAt) < ttl;
  }
}
