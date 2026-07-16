import 'package:hive_flutter/hive_flutter.dart';
import 'sync_task.dart';

class SyncQueue {
  static const String _boxName = 'offline_sync_queue';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> enqueue(SyncTask task) async {
    await _box.put(task.id, task.toJson());
  }

  Future<SyncTask?> dequeue() async {
    if (_box.isEmpty) return null;
    final key = _box.keys.first;
    final data = Map<String, dynamic>.from(_box.get(key) as Map);
    await _box.delete(key);
    return SyncTask.fromJson(data);
  }

  Future<List<SyncTask>> getAll() async {
    return _box.values
        .map((e) => SyncTask.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  bool get isEmpty => _box.isEmpty;

  int get length => _box.length;
}
