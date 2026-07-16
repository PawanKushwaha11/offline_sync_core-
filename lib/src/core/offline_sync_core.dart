import '../storage/storage_adapter.dart';
import '../cache/cache_entry.dart';

/// The core manager class for the Offline Sync package.
///
/// It handles the initialization of the underlying storage and coordinates
/// caching requests with Time-to-Live (TTL) verification and fallback mechanisms.
class OfflineSyncCore {
  static StorageAdapter? _storage;

  /// Initializes the [OfflineSyncCore] with a persistent storage mechanism.
  ///
  /// This must be called before calling [get].
  ///
  /// Example:
  /// ```dart
  /// await OfflineSyncCore.initialize(storage: HiveStorage());
  /// ```
  static Future<void> initialize({required StorageAdapter storage}) async {
    _storage = storage;
    await _storage!.initialize();
  }

  /// Retrieves a value of type [T] associated with [key].
  ///
  /// First, it tries to fetch the data from the local storage cache. If the
  /// cache exists and its age is within the specified [ttl] duration, the cached data is returned.
  ///
  /// If the cache is empty or expired, it calls the [fetch] function to get fresh
  /// data, saves it to the cache, and returns it.
  ///
  /// If the network request [fetch] fails and the cache exists but is expired,
  /// it will gracefully fall back and return the expired cache data instead of throwing an error.
  ///
  /// Throws [StateError] if [OfflineSyncCore] is not initialized.
  static Future<T?> get<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() fetch,
  }) async {
    if (_storage == null) {
      throw StateError(
        'OfflineSyncCore has not been initialized. Call initialize() first.',
      );
    }

    // 1. Try to get from storage cache
    try {
      final cachedData = await _storage!.get(key);
      if (cachedData != null) {
        final entry = CacheEntry.fromJson(cachedData);
        if (!entry.isExpired) {
          return entry.data as T?;
        }
      }
    } catch (e) {
      // Log or handle cache read error silently, or proceed to fetch
    }

    // 2. Fetch from remote/API if cache is empty or expired
    try {
      final data = await fetch();
      if (data != null) {
        final entry = CacheEntry(
          data: data,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(ttl),
        );
        await _storage!.put(key, entry.toJson());
      }
      return data;
    } catch (e) {
      // Fallback: if fetching fails, try to return the expired cache
      try {
        final cachedData = await _storage!.get(key);
        if (cachedData != null) {
          final entry = CacheEntry.fromJson(cachedData);
          return entry.data as T?;
        }
      } catch (_) {}
      rethrow;
    }
  }
}
