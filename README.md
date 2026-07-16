<div align="center">

# ⚡ offline_sync_core

### Build Flutter apps that work **seamlessly offline**.

A lightweight, extensible, and production-ready package for **offline-first caching & synchronization** — featuring smart TTL-based cache management, automatic offline fallback, and pluggable storage backends.

<br/>

[![pub package](https://img.shields.io/pub/v/offline_sync_core.svg?color=blueviolet&label=pub.dev)](https://pub.dev/packages/offline_sync_core)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D1.17.0-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%5E3.10.4-0175C2?logo=dart)](https://dart.dev)
[![Issues](https://img.shields.io/github/issues/AmarJeet/offline_sync_core)](https://github.com/AmarJeet/offline_sync_core/issues)

<br/>

</div>

---

## ✨ Why offline_sync_core?

Most Flutter apps break when the internet goes down. `offline_sync_core` ensures your app **never fails** — it intelligently serves cached data while your network is offline, and automatically syncs when it comes back.

---

## 🚀 Features

| Feature | Description |
|---|---|
| ⚡ **Smart Cache** | Serves cached data instantly, fetches fresh data in the background |
| ⏳ **TTL Support** | Set custom expiry duration per cache entry |
| 🛡 **Offline Fallback** | Falls back to expired cache when network fails — no crash, no blank screen |
| 🗄 **Hive Storage** | Blazing-fast local key-value persistence out of the box |
| 🔌 **Pluggable Backend** | Swap storage engines easily by implementing `StorageAdapter` |
| 📐 **Extensible Architecture** | Built with clean abstractions — ready to scale with Sync Queue, SQLite, and Inspector |

---

## 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  offline_sync_core: ^0.0.1
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
  );

  runApp(const MyApp());
}
```

---

## 💻 Usage

### Fetch & Cache Data (Smart Cache with TTL)

```dart
final user = await OfflineSyncCore.get<Map>(
  key: 'user_profile',
  ttl: const Duration(minutes: 5),
  fetch: () async {
    // Your remote API call here
    final response = await http.get(
      Uri.parse('https://api.example.com/profile'),
    );
    return jsonDecode(response.body);
  },
);
```

### How it works:

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

## 🏗 Architecture

```
lib/
├── offline_sync_core.dart         ← Public API barrel file
│
└── src/
    ├── core/
    │   ├── offline_sync_core.dart ← Main engine (initialize + get)
    │   └── config.dart            ← Configuration model
    │
    ├── cache/
    │   ├── cache_manager.dart     ← Cache CRUD operations
    │   ├── cache_entry.dart       ← TTL & serialization model
    │   └── cache_policy.dart      ← cacheFirst, networkFirst, etc.
    │
    ├── storage/
    │   ├── storage_adapter.dart   ← Abstract interface
    │   ├── hive_storage.dart      ← Hive implementation ✅
    │   └── sqlite_storage.dart    ← SQLite implementation 🔜
    │
    ├── sync/
    │   ├── sync_manager.dart      ← Sync orchestration 🔜
    │   ├── sync_queue.dart        ← Offline mutation queue 🔜
    │   ├── sync_task.dart         ← Task model 🔜
    │   └── sync_status.dart       ← Status enum
    │
    ├── inspector/
    │   ├── inspector_controller.dart ← Debug controls 🔜
    │   └── inspector_screen.dart     ← Debug UI overlay 🔜
    │
    └── utils/
        ├── logger.dart            ← Internal logging
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
- [ ] Persistent offline sync queue
- [ ] SQLite storage adapter
- [ ] Background auto-sync using WorkManager
- [ ] Visual debug Inspector screen
- [ ] Conflict resolution strategy

---

## 🤝 Contributing

Contributions, issues and feature requests are welcome!

1. Fork this repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

Feel free to check the [issues page](https://github.com/AmarJeet/offline_sync_core/issues).

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ by [AmarJeet](https://github.com/AmarJeet)

⭐ **If this package helped you, please star the repo!** ⭐

</div>
