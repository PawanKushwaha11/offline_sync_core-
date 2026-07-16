import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'storage_adapter.dart';

class SQLiteStorage implements StorageAdapter {
  late Database _db;
  final String dbName;

  SQLiteStorage({this.dbName = 'offline_sync.db'});

  @override
  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE cache (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
      },
    );
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final result = await _db.query(
      'cache',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return jsonDecode(result.first['value'] as String)
        as Map<String, dynamic>;
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    await _db.insert(
      'cache',
      {'key': key, 'value': jsonEncode(value)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String key) async {
    await _db.delete(
      'cache',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  @override
  Future<void> clear() async {
    await _db.delete('cache');
  }

  Future<void> close() async {
    await _db.close();
  }
}
