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
    final path = join(dbPath, 'media.db'); // Renamed from images.db to media.db

    return await openDatabase(
      path,
      version: 2, // Increased version number for migration
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT NOT NULL
          )
        ''');

        db.execute('''
          CREATE TABLE pdfs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('''
            CREATE TABLE pdfs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              path TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  // Insert Image
  Future<int> insertImage(String path) async {
    final db = await database;
    return await db.insert('images', {'path': path});
  }

  // Get Images
  Future<List<String>> getImages() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('images');
    return result.map((row) => row['path'] as String).toList();
  }

  // Delete Image
  Future<int> deleteImage(int id) async {
    final db = await database;
    return await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  // Insert PDF
  Future<int> insertPDF(String path) async {
    final db = await database;
    return await db.insert('pdfs', {'path': path});
  }

  // Get PDFs
  Future<List<String>> getPDFs() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('pdfs');
    return result.map((row) => row['path'] as String).toList();
  }

  // Delete PDF
  Future<int> deletePDF(int id) async {
    final db = await database;
    return await db.delete('pdfs', where: 'id = ?', whereArgs: [id]);
  }
}
