/// An abstract interface class defining operations required for local persistence.
///
/// Any storage engine (e.g. Hive, SQLite, Shared Preferences) must implement
/// this adapter to be used as the caching backend in [OfflineSyncCore].
abstract class StorageAdapter {
  /// Initializes the storage engine (e.g., opening database files, setting up tables).
  Future<void> initialize();

  /// Retrieves the cached entry associated with [key].
  ///
  /// Returns `null` if the key is not found in the storage.
  Future<Map<String, dynamic>?> get(String key);

  /// Saves the cached entry [value] associated with [key].
  Future<void> put(String key, Map<String, dynamic> value);

  /// Removes the entry associated with [key] from storage.
  Future<void> delete(String key);

  /// Removes all entries from the storage.
  Future<void> clear();
}
