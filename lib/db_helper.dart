import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'photos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE photos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertPhoto(String path) async {
    final db = await database;
    await db.insert('photos', {'path': path});
  }

  Future<List<Map<String, dynamic>>> getPhotos() async {
    final db = await database;
    return await db.query('photos');
  }

  Future<void> deletePhoto(int id) async {
    final db = await database;
    await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }
}
