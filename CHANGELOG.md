## 0.1.3

* Added GitHub and LinkedIn badges to the README footer.

## 0.1.2

* Updated developer profile name to Pawan Kushwaha and added dynamic GitHub profile image.

## 0.1.1

* Updated README.md roadmap checkboxes and directory tree statuses to reflect fully implemented v0.1.0 features.

## 0.1.0

* Added `SyncTask` model with UUID generation, full JSON serialization, and `copyWith` support.
* Added `SyncQueue` with Hive-backed persistence for offline mutation queuing.
* Added `SyncManager` with `connectivity_plus` network listener, exponential backoff retry, and RxDart `syncStream`.
* Added `SQLiteStorage` — full `StorageAdapter` implementation using `sqflite`.
* Added `SyncLogger` singleton with configurable logging levels (info, debug, warning, error).
* Added `OfflineSyncConfig` for customizing `maxRetries`, `enableLogging`, `backgroundSyncEnabled`, and `defaultTtl`.
* Added `InspectorController` for managing cache, queue, network status, and force sync triggers.
* Added `InspectorScreen` — full Flutter debug UI with Sync Queue tab and Network status tab.
* Updated `OfflineSyncCore` with `enqueue()`, `forceSync()`, `clearCache()`, and `config` support.
* Expanded unit tests to cover `SyncTask`, `SyncStatus`, and `CachePolicy`.

## 0.0.1

* Initial release of `offline_sync_core`.
* Smart Caching with TTL support.
* Offline fallback logic serving expired cache on network failures.
* Extensible storage adapter layer (`StorageAdapter`).
* High-performance `HiveStorage` implementation out of the box.
