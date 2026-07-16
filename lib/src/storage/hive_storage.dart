import 'package:hive_flutter/hive_flutter.dart';
import 'storage_adapter.dart';

/// A [StorageAdapter] implementation using the Hive database.
///
/// This provides very fast key-value persistence. Under the hood, it initializes
/// Hive for Flutter and opens a designated box to store cache entries.
class HiveStorage implements StorageAdapter {
  late Box _box;

  /// The name of the Hive box to store cached values.
  final String boxName;

  /// Creates a [HiveStorage] instance.
  ///
  /// Optionally accepts a custom [boxName] (defaults to `'offline_sync_box'`).
  HiveStorage({this.boxName = 'offline_sync_box'});

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final data = _box.get(key);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    await _box.put(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
