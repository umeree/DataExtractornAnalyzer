import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DatabaseHelper {
    static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
    static Database? _database;
     DatabaseHelper._privateConstructor();



      Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'images.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT NOT NULL
          )
        ''');
      },
    );
  }

    Future<int> insertImage(String path) async {
    final db = await database;
    return await db.insert('images', {'path': path});
  }

   Future<List<String>> getImages() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('images');
    return result.map((row) => row['path'] as String).toList();
  }

    Future<int> deleteImage(int id) async {
    final db = await database;
    return await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }
}