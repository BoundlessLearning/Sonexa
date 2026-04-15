import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/core/cache/timed_memory_cache.dart';

void main() {
  group('TimedMemoryCache', () {
    test('reuses cached values inside ttl', () async {
      var now = DateTime(2026, 4, 15);
      var loads = 0;
      final cache = TimedMemoryCache(
        ttl: const Duration(minutes: 2),
        now: () => now,
      );

      final first = await cache.getOrLoad('songs', () async => ++loads);
      final second = await cache.getOrLoad('songs', () async => ++loads);

      expect(first, 1);
      expect(second, 1);
      expect(loads, 1);
    });

    test('reloads values after ttl expires', () async {
      var now = DateTime(2026, 4, 15);
      var loads = 0;
      final cache = TimedMemoryCache(
        ttl: const Duration(minutes: 2),
        now: () => now,
      );

      await cache.getOrLoad('songs', () async => ++loads);
      now = now.add(const Duration(minutes: 3));
      final value = await cache.getOrLoad('songs', () async => ++loads);

      expect(value, 2);
      expect(loads, 2);
    });

    test('forceRefresh bypasses fresh cache', () async {
      var loads = 0;
      final cache = TimedMemoryCache(ttl: const Duration(minutes: 2));

      await cache.getOrLoad('songs', () async => ++loads);
      final value = await cache.getOrLoad(
        'songs',
        () async => ++loads,
        forceRefresh: true,
      );

      expect(value, 2);
      expect(loads, 2);
    });

    test('coalesces concurrent loads for the same key', () async {
      var loads = 0;
      final cache = TimedMemoryCache(ttl: const Duration(minutes: 2));
      final completer = Completer<int>();

      final first = cache.getOrLoad('songs', () {
        loads++;
        return completer.future;
      });
      final second = cache.getOrLoad('songs', () async => 2);

      completer.complete(1);

      expect(await first, 1);
      expect(await second, 1);
      expect(loads, 1);
    });

    test('removes failed entries so a retry can reload', () async {
      var loads = 0;
      final cache = TimedMemoryCache(ttl: const Duration(minutes: 2));

      await expectLater(
        cache.getOrLoad<int>('songs', () async {
          loads++;
          throw StateError('failed');
        }),
        throwsStateError,
      );

      final value = await cache.getOrLoad('songs', () async => ++loads);

      expect(value, 2);
      expect(loads, 2);
    });

    test('clear removes all entries', () async {
      var loads = 0;
      final cache = TimedMemoryCache(ttl: const Duration(minutes: 2));

      await cache.getOrLoad('songs', () async => ++loads);
      cache.clear();
      final value = await cache.getOrLoad('songs', () async => ++loads);

      expect(value, 2);
      expect(loads, 2);
    });
  });
}
