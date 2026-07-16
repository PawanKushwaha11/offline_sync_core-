import '../storage/storage_adapter.dart';
import '../cache/cache_entry.dart';
import '../sync/sync_manager.dart';
import '../sync/sync_task.dart';
import '../utils/logger.dart';
import 'config.dart';

class OfflineSyncCore {
  static StorageAdapter? _storage;
  static SyncManager? _syncManager;
  static OfflineSyncConfig _config = const OfflineSyncConfig();

  static Future<void> initialize({
    required StorageAdapter storage,
    OfflineSyncConfig config = const OfflineSyncConfig(),
  }) async {
    _config = config;
    _storage = storage;
    await _storage!.initialize();
    SyncLogger.configure(enabled: _config.enableLogging);
    _syncManager = SyncManager();
    await _syncManager!.initialize();
    SyncLogger.instance.info('OfflineSyncCore initialized');
  }

  static Future<T?> get<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() fetch,
  }) async {
    _assertInitialized();
    try {
      final cachedData = await _storage!.get(key);
      if (cachedData != null) {
        final entry = CacheEntry.fromJson(cachedData);
        if (!entry.isExpired) {
          SyncLogger.instance.info('Cache hit: $key');
          return entry.data as T?;
        }
        SyncLogger.instance.debug('Cache expired: $key');
      }
    } catch (e) {
      SyncLogger.instance.warning('Cache read error for $key: $e');
    }

    try {
      SyncLogger.instance.info('Fetching from network: $key');
      final data = await fetch();
      if (data != null) {
        final entry = CacheEntry(
          data: data,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(ttl),
        );
        await _storage!.put(key, entry.toJson());
        SyncLogger.instance.info('Cache saved: $key');
      }
      return data;
    } catch (e) {
      SyncLogger.instance.error('Network fetch failed for $key', e);
      try {
        final cachedData = await _storage!.get(key);
        if (cachedData != null) {
          SyncLogger.instance.warning('Returning expired cache for $key');
          final entry = CacheEntry.fromJson(cachedData);
          return entry.data as T?;
        }
      } catch (_) {}
      rethrow;
    }
  }

  static Future<void> enqueue(SyncTask task) async {
    _assertInitialized();
    await _syncManager!.enqueue(task);
    SyncLogger.instance.info('Task enqueued: ${task.url}');
  }

  static Future<void> forceSync() async {
    _assertInitialized();
    await _syncManager!.processPendingTasks();
  }

  static Future<void> clearCache() async {
    _assertInitialized();
    await _storage!.clear();
    SyncLogger.instance.info('Cache cleared');
  }

  static SyncManager get syncManager {
    _assertInitialized();
    return _syncManager!;
  }

  static OfflineSyncConfig get config => _config;

  static void _assertInitialized() {
    if (_storage == null || _syncManager == null) {
      throw StateError(
          'OfflineSyncCore is not initialized. Call initialize() first.');
    }
  }
}
