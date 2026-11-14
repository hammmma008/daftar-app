import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/daftar_record.dart';

class DaftarDatabase {
  DaftarDatabase._();
  static final DaftarDatabase instance = DaftarDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final base = await getDatabasesPath();
    final path = p.join(base, 'daftar_local.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            module TEXT NOT NULL,
            title TEXT NOT NULL,
            amount REAL NOT NULL DEFAULT 0,
            details TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<List<DaftarRecord>> getRecords(String module) async {
    final db = await database;
    final rows = await db.query(
      'records',
      where: 'module = ?',
      whereArgs: [module],
      orderBy: 'id DESC',
    );
    return rows.map(DaftarRecord.fromMap).toList();
  }

  Future<List<DaftarRecord>> getAllRecords() async {
    final db = await database;
    final rows = await db.query('records', orderBy: 'id DESC');
    return rows.map(DaftarRecord.fromMap).toList();
  }

  Future<int> addRecord(DaftarRecord record) async {
    final db = await database;
    return db.insert('records', record.toMap()..remove('id'));
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> totalFor(String module) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM records WHERE module = ?',
      [module],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<int> countFor(String module) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM records WHERE module = ?',
      [module],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
