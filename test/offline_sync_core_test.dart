import 'package:flutter_test/flutter_test.dart';
import 'package:offline_sync_core/src/cache/cache_entry.dart';
import 'package:offline_sync_core/src/cache/cache_policy.dart';
import 'package:offline_sync_core/src/sync/sync_task.dart';
import 'package:offline_sync_core/src/sync/sync_status.dart';

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

    test('All CachePolicy values should exist', () {
      expect(CachePolicy.values.length, 4);
      expect(CachePolicy.values, containsAll([
        CachePolicy.cacheFirst,
        CachePolicy.networkFirst,
        CachePolicy.cacheOnly,
        CachePolicy.networkOnly,
      ]));
    });
  });

  group('SyncTask Tests', () {
    test('SyncTask should generate unique id', () {
      final task1 = SyncTask(url: 'https://api.example.com', method: 'POST');
      final task2 = SyncTask(url: 'https://api.example.com', method: 'POST');
      expect(task1.id, isNotEmpty);
      expect(task1.id, isNot(equals(task2.id)));
    });

    test('SyncTask should serialize to JSON correctly', () {
      final task = SyncTask(
        url: 'https://api.example.com/orders',
        method: 'POST',
        headers: {'Authorization': 'Bearer token'},
        body: {'item': 'book', 'qty': 1},
      );
      final json = task.toJson();
      expect(json['url'], 'https://api.example.com/orders');
      expect(json['method'], 'POST');
      expect(json['body']['item'], 'book');
      expect(json['status'], 'pending');
    });

    test('SyncTask should deserialize from JSON correctly', () {
      final task = SyncTask(
        url: 'https://api.example.com/orders',
        method: 'PUT',
        body: {'qty': 2},
      );
      final json = task.toJson();
      final restored = SyncTask.fromJson(json);
      expect(restored.id, task.id);
      expect(restored.url, task.url);
      expect(restored.method, task.method);
      expect(restored.body?['qty'], 2);
    });

    test('SyncTask copyWith should update fields correctly', () {
      final task = SyncTask(url: 'https://api.example.com', method: 'POST');
      final updated = task.copyWith(
        status: SyncStatus.failed,
        retryCount: 3,
      );
      expect(updated.id, task.id);
      expect(updated.status, SyncStatus.failed);
      expect(updated.retryCount, 3);
    });

    test('SyncTask default status should be pending', () {
      final task = SyncTask(url: 'https://api.example.com', method: 'GET');
      expect(task.status, SyncStatus.pending);
    });
  });

  group('SyncStatus Tests', () {
    test('All SyncStatus values should exist', () {
      expect(SyncStatus.values.length, 4);
      expect(SyncStatus.values, containsAll([
        SyncStatus.pending,
        SyncStatus.syncing,
        SyncStatus.success,
        SyncStatus.failed,
      ]));
    });
  });
}
