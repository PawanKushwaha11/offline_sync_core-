import 'package:flutter_test/flutter_test.dart';

import 'package:offline_sync_core/src/cache/cache_entry.dart';
import 'package:offline_sync_core/src/cache/cache_policy.dart';

void main() {
  group('CacheEntry Tests', () {
    test('CacheEntry should serialize correctly', () {
      final cache = CacheEntry(
        data: {'name': 'Ali'},
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      final json = cache.toJson();

      expect(json['data']['name'], 'Ali');
    });

    test('CacheEntry should deserialize correctly', () {
      final now = DateTime.now();

      final json = {
        'data': {'name': 'Ali'},
        'createdAt': now.toIso8601String(),
        'expiresAt': now.add(const Duration(hours: 1)).toIso8601String(),
      };

      final cache = CacheEntry.fromJson(json);

      expect(cache.data['name'], 'Ali');

      expect(cache.isExpired, false);
    });

    test('Expired cache should return true', () {
      final cache = CacheEntry(
        data: 'Hello',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      expect(cache.isExpired, true);
    });
  });

  group('CachePolicy Tests', () {
    test('Default policy should exist', () {
      expect(CachePolicy.cacheFirst, isNotNull);
    });
  });
}
