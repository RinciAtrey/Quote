import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBFavorite {
  final int? id;
  final String text;
  final String author;

  DBFavorite({this.id, required this.text, required this.author});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'author': author,
    };
  }

  factory DBFavorite.fromMap(Map<String, dynamic> map) {
    return DBFavorite(
      id: map['id'] as int?,
      text: map['text'] as String,
      author: map['author'] as String? ?? 'Unknown',
    );
  }
}

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  final StreamController<void> _favoritesChangeController = StreamController<void>.broadcast();

  Stream<void> get favoritesStream => _favoritesChangeController.stream;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quotes_favs.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            author TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertFavorite(DBFavorite fav) async {
    final db = await database;
    final existing = await db.query(
      'favorites',
      where: 'text = ? AND author = ?',
      whereArgs: [fav.text, fav.author],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    final id = await db.insert('favorites', fav.toMap());
    _favoritesChangeController.add(null);
    return id;
  }

  Future<List<DBFavorite>> getFavorites() async {
    final db = await database;
    final rows = await db.query('favorites', orderBy: 'id DESC');
    return rows.map((r) => DBFavorite.fromMap(r)).toList();
  }

  Future<int> deleteFavoriteById(int id) async {
    final db = await database;
    final res = await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
    _favoritesChangeController.add(null);
    return res;
  }

  Future<int> deleteFavoriteByTextAuthor(String text, String author) async {
    final db = await database;
    final res = await db.delete('favorites', where: 'text = ? AND author = ?', whereArgs: [text, author]);
    _favoritesChangeController.add(null);
    return res;
  }

  Future<bool> isFavorite(String text, String author) async {
    final db = await database;
    final rows = await db.query('favorites', where: 'text = ? AND author = ?', whereArgs: [text, author], limit: 1);
    return rows.isNotEmpty;
  }

  Future<void> dispose() async {
    await _favoritesChangeController.close();
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
