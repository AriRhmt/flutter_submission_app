import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class FavoriteService {
  static const _dbName = 'app.db';
  static const _table = 'favorites';
  static Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            city TEXT NOT NULL,
            rating REAL NOT NULL,
            description TEXT NOT NULL,
            image TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> toggleFavorite(Map<String, dynamic> restaurant) async {
    final db = await _open();
    final id = restaurant['id'] as String;
    final existing = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (existing.isNotEmpty) {
      await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    } else {
      await db.insert(_table, restaurant, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<bool> isFavorite(String id) async {
    final db = await _open();
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    return rows.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> allFavorites() async {
    final db = await _open();
    return db.query(_table, orderBy: 'name ASC');
  }
}