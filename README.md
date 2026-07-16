<div align="center">

# ⚡ offline_sync_core

### Build Flutter apps that work **seamlessly offline**.

A lightweight, extensible, and production-ready package for **offline-first caching & synchronization** — featuring smart TTL-based cache management, automatic offline fallback, persistent sync queue, and a visual debug inspector.

<br/>

[![pub package](https://img.shields.io/pub/v/offline_sync_core.svg?color=blueviolet&label=pub.dev)](https://pub.dev/packages/offline_sync_core)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D1.17.0-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%5E3.10.4-0175C2?logo=dart)](https://dart.dev)
[![Issues](https://img.shields.io/github/issues/PawanKushwaha11/offline_sync_core-)](https://github.com/PawanKushwaha11/offline_sync_core-/issues)

<br/>

</div>

---

## ✨ Why offline_sync_core?

Most Flutter apps break when the internet goes down. `offline_sync_core` ensures your app **never fails** — it intelligently serves cached data while your network is offline, queues mutations locally, and automatically syncs everything when connectivity is restored.

---

## 🚀 Features

| Feature | Description |
|---|---|
| ⚡ **Smart Cache** | Serves cached data instantly with TTL-based expiry |
| 🛡 **Offline Fallback** | Falls back to expired cache when network fails — no crash, no blank screen |
| 📤 **Offline Sync Queue** | Queue POST/PUT/DELETE mutations locally when offline, auto-sync on reconnect |
| ✏️ **Optimistic Updates** | Update local cache instantly (`put`) and queue background sync separately |
| 🔄 **Periodic Sync** | Auto-sync pending queue at a configurable interval |
| 🗄 **Hive Storage** | Blazing-fast local key-value persistence out of the box |
| 🗃 **SQLite Storage** | Full relational storage adapter using `sqflite` |
| 🔌 **Pluggable Backend** | Swap storage engines easily by implementing `StorageAdapter` |
| 🔍 **Visual Inspector** | Built-in debug UI to inspect cache, queue, and network status |
| 📋 **Configurable Logging** | Structured internal logging with `SyncLogger` |

---

## 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  offline_sync_core: ^0.1.6
```

Then run:

```bash
flutter pub get
```

---

## ⚙️ Setup

Initialize `OfflineSyncCore` in your `main.dart` before `runApp()`:

```dart
import 'package:flutter/material.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await OfflineSyncCore.initialize(
    storage: HiveStorage(),
    config: const OfflineSyncConfig(
      enableLogging: true,
      maxRetries: 3,
    ),
  );

  // Optional: auto-sync every 5 minutes when internet is available
  OfflineSyncCore.startPeriodicSync(interval: const Duration(minutes: 5));

  runApp(const MyApp());
}
```

---

## 💻 Usage

### 1. Fetch & Cache Data (Smart Cache with TTL)

```dart
final user = await OfflineSyncCore.get<Map>(
  key: 'user_profile',
  ttl: const Duration(minutes: 5),
  fetch: () async {
    final response = await http.get(Uri.parse('https://api.example.com/profile'));
    return jsonDecode(response.body);
  },
);
```

**How it works:**
```
App calls get()
      │
      ▼
 Cache exists & not expired?
      │
  ┌───┴───┐
 YES      NO
  │        │
  │        ▼
  │    Call fetch() → Save to cache
  │        │
  └────────┤
           ▼
     Return data to app
           │
  [Network fails?]
           │
           ▼
   Return expired cache
   (Offline Fallback 🛡)
```

---

### 2. Optimistic Update (Update UI instantly, sync in background)

```dart
// 1. Update local cache immediately — UI changes instantly (even offline)
await OfflineSyncCore.put(
  key: 'user_profile',
  data: {'name': 'Shivam', 'email': 'shivam@example.com'},
  ttl: const Duration(minutes: 5),
);

// 2. Queue background sync to update the server
await OfflineSyncCore.enqueue(SyncTask(
  url: 'https://api.example.com/users/1',
  method: 'PUT',
  body: {'name': 'Shivam', 'email': 'shivam@example.com'},
));
```

---

### 3. Offline Sync Queue (Queue mutations when offline)

```dart
// Queue a POST request — safe even without internet
await OfflineSyncCore.enqueue(SyncTask(
  url: 'https://api.example.com/posts',
  method: 'POST',
  body: {'title': 'New Post', 'body': 'Created offline'},
));

// When internet restores, SyncManager auto-syncs all pending tasks.
// You can also force sync manually:
await OfflineSyncCore.forceSync();
```

---

### 4. Periodic Sync (Timer-based background sync)

```dart
// Start syncing pending queue every 10 minutes
OfflineSyncCore.startPeriodicSync(
  interval: const Duration(minutes: 10),
);

// Stop when no longer needed (e.g., on app pause)
OfflineSyncCore.stopPeriodicSync();
```

---

### 5. Visual Debug Inspector

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => InspectorScreen(
      controller: InspectorController(
        storage: HiveStorage(),
        syncManager: OfflineSyncCore.syncManager,
      ),
    ),
  ),
);
```

---

## 🏗 Architecture

```
lib/
├── offline_sync_core.dart         ← Public API barrel file
│
└── src/
    ├── core/
    │   ├── offline_sync_core.dart ← Main engine (get, put, enqueue, sync)
    │   └── config.dart            ← OfflineSyncConfig model
    │
    ├── cache/
    │   ├── cache_manager.dart     ← Cache CRUD operations
    │   ├── cache_entry.dart       ← TTL & serialization model
    │   └── cache_policy.dart      ← cacheFirst, networkFirst, etc.
    │
    ├── storage/
    │   ├── storage_adapter.dart   ← Abstract interface
    │   ├── hive_storage.dart      ← Hive implementation ✅
    │   └── sqlite_storage.dart    ← SQLite implementation ✅
    │
    ├── sync/
    │   ├── sync_manager.dart      ← Connectivity listener, periodic sync ✅
    │   ├── sync_queue.dart        ← Hive-backed offline queue ✅
    │   ├── sync_task.dart         ← Task model with retry support ✅
    │   └── sync_status.dart       ← Status enum (pending/syncing/success/failed)
    │
    ├── inspector/
    │   ├── inspector_controller.dart ← Debug controls ✅
    │   └── inspector_screen.dart     ← Debug UI overlay ✅
    │
    └── utils/
        ├── logger.dart            ← SyncLogger singleton
        └── extensions.dart        ← Dart extensions
```

---

## 🔌 Custom Storage Backend

You can implement your own storage backend by extending `StorageAdapter`:

```dart
class MyCustomStorage implements StorageAdapter {
  @override
  Future<void> initialize() async { /* your init logic */ }

  @override
  Future<Map<String, dynamic>?> get(String key) async { /* read */ }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async { /* write */ }

  @override
  Future<void> delete(String key) async { /* delete */ }

  @override
  Future<void> clear() async { /* clear all */ }
}

// Then use it:
await OfflineSyncCore.initialize(storage: MyCustomStorage());
```

---

## 📅 Roadmap

- [x] Smart caching with TTL
- [x] Offline fallback to expired cache
- [x] Hive storage adapter
- [x] Abstract storage interface
- [x] Persistent offline sync queue
- [x] SQLite storage adapter
- [x] Visual debug Inspector screen
- [x] Optimistic UI update via `put()`
- [x] Periodic sync with configurable interval
- [ ] Background auto-sync using WorkManager
- [ ] Conflict resolution strategy

---

## 🤝 Contributing

Contributions, issues and feature requests are welcome!

1. Fork this repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

Feel free to check the [issues page](https://github.com/PawanKushwaha11/offline_sync_core-/issues).

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ by Pawan Kushwaha

<br/>

<img src="https://raw.githubusercontent.com/PawanKushwaha11/offline_sync_core-/main/assets/profile.jpeg" width="100" height="100" style="border-radius: 50%;" />

<br/><br/>

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/PawanKushwaha11)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/pawan8052/)

<br/><br/>

⭐ **If this package helped you, please star the repo!** ⭐

</div>
