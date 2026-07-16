import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';
import '../cache/cache_entry.dart';
import '../storage/storage_adapter.dart';
import '../sync/sync_manager.dart';
import '../sync/sync_task.dart';
import '../sync/sync_status.dart';

class CacheInspectorEntry {
  final String key;
  final CacheEntry entry;

  CacheInspectorEntry({required this.key, required this.entry});

  bool get isExpired => entry.isExpired;
}

class InspectorController {
  final StorageAdapter _storage;
  final SyncManager _syncManager;
  final BehaviorSubject<bool> _networkStatusController =
      BehaviorSubject<bool>.seeded(true);

  Stream<bool> get networkStream => _networkStatusController.stream;
  bool get isOnline => _networkStatusController.value;

  InspectorController({
    required StorageAdapter storage,
    required SyncManager syncManager,
  })  : _storage = storage,
        _syncManager = syncManager {
    Connectivity().onConnectivityChanged.listen((results) {
      _networkStatusController
          .add(results.any((r) => r != ConnectivityResult.none));
    });
  }

  Future<List<SyncTask>> getSyncQueue() async {
    return _syncManager.getPendingTasks();
  }

  Future<void> clearCache() async {
    await _storage.clear();
  }

  Future<void> clearQueue() async {
    await _syncManager.clearQueue();
  }

  Future<void> forceSync() async {
    await _syncManager.processPendingTasks();
  }

  Stream<SyncStatus> get syncStream => _syncManager.syncStream;

  void dispose() {
    _networkStatusController.close();
  }
}
