import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../model/CustomQuote/custom_quote_model.dart';

class DatabaseHelper {
  static final _dbName = 'quotes.db';
  static final _dbVersion = 1;
  static final tableName = 'quotes';

  static final columnId = 'id';
  static final columnQuote = 'quote';
  static final columnAuthor = 'author';
  static final columnColor = 'color';
  static final columnIsBold = 'isBold';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE $tableName (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnQuote TEXT NOT NULL,
          $columnAuthor TEXT NOT NULL,
          $columnColor INTEGER NOT NULL,
          $columnIsBold INTEGER NOT NULL
        )
      ''');
    });
  }

  Future<int> insertQuote(CustomQuoteModel quote) async {
    Database db = await database;
    return await db.insert(
      tableName,
      quote.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CustomQuoteModel>> getAllQuotes() async {
    Database db = await database;
    final maps = await db.query(tableName);
    return maps.map((map) => CustomQuoteModel.fromMap(map)).toList();
  }

  Future<int> deleteQuote(int id) async {
    Database db = await database;
    return await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
