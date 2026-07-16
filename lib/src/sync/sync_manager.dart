import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'sync_queue.dart';
import 'sync_task.dart';
import 'sync_status.dart';

class SyncManager {
  final SyncQueue _queue;
  final BehaviorSubject<SyncStatus> _statusController =
      BehaviorSubject<SyncStatus>.seeded(SyncStatus.pending);

  Timer? _periodicTimer;

  Stream<SyncStatus> get syncStream => _statusController.stream;
  SyncStatus get currentStatus => _statusController.value;

  SyncManager({SyncQueue? queue}) : _queue = queue ?? SyncQueue();

  Future<void> initialize() async {
    await _queue.initialize();
    Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        processPendingTasks();
      }
    });
  }

  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) async {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.any((r) => r != ConnectivityResult.none)) {
        await processPendingTasks();
      }
    });
  }

  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  Future<void> enqueue(SyncTask task) async {
    await _queue.enqueue(task);
  }

  Future<List<SyncTask>> getPendingTasks() async {
    return _queue.getAll();
  }

  Future<void> processPendingTasks() async {
    if (_queue.isEmpty) return;
    _statusController.add(SyncStatus.syncing);
    bool allSuccess = true;
    while (!_queue.isEmpty) {
      final task = await _queue.dequeue();
      if (task == null) break;
      final success = await _executeWithRetry(task);
      if (!success) allSuccess = false;
    }
    _statusController.add(allSuccess ? SyncStatus.success : SyncStatus.failed);
  }

  Future<bool> _executeWithRetry(SyncTask task, {int attempt = 0}) async {
    const maxRetries = 3;
    try {
      await _executeTask(task);
      return true;
    } catch (_) {
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: (attempt + 1) * 2));
        return _executeWithRetry(task, attempt: attempt + 1);
      } else {
        final failed = task.copyWith(
          status: SyncStatus.failed,
          retryCount: attempt,
        );
        await _queue.enqueue(failed);
        return false;
      }
    }
  }

  Future<void> _executeTask(SyncTask task) async {
    final uri = Uri.parse(task.url);
    final headers = {
      'Content-Type': 'application/json',
      ...task.headers,
    };
    final encodedBody = task.body != null ? jsonEncode(task.body) : null;
    http.Response response;
    switch (task.method.toUpperCase()) {
      case 'POST':
        response = await http.post(uri, headers: headers, body: encodedBody);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: encodedBody);
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: encodedBody);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        response = await http.get(uri, headers: headers);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> clearQueue() async {
    await _queue.clear();
  }

  void dispose() {
    _periodicTimer?.cancel();
    _statusController.close();
  }
}
