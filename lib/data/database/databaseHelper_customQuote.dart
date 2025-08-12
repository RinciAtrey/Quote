import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../model/CustomQuote/custom_quote_model.dart';

class DBCustomQuote {
  static final _dbName     = 'quotes.db';
  static final _dbVersion  = 3;
  static final tableName   = 'quotes';

  static final columnId         = 'id';
  static final columnQuote      = 'quote';
  static final columnAuthor     = 'author';
  static final columnColor      = 'color';
  static final columnIsBold     = 'isBold';
  static final columnFontFamily = 'fontFamily';
  static const columnFontColor  = 'fontColor';

  DBCustomQuote._privateConstructor();
  static final DBCustomQuote instance = DBCustomQuote._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnQuote TEXT    NOT NULL,
        $columnAuthor TEXT   NOT NULL,
        $columnColor INTEGER NOT NULL,
        $columnIsBold INTEGER NOT NULL,
        $columnFontFamily TEXT              
        $columnFontColor  INTEGER
      )
    ''');
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // if (oldVersion < 2) {
    //   await db.execute('''
    //     ALTER TABLE $tableName
    //     ADD COLUMN $columnFontFamily TEXT DEFAULT 'Open Sans'
    //   ''');
    // }
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE $tableName
        ADD COLUMN $columnFontColor INTEGER DEFAULT ${0xFFFFFFFF}
      ''');
    }
  }

  Future<int> insertQuote(CustomQuoteModel quote) async {
    final db = await database;
    return await db.insert(
      tableName,
      quote.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CustomQuoteModel>> getAllQuotes() async {
    final db   = await database;
    final maps = await db.query(tableName);
    return maps.map((m) => CustomQuoteModel.fromMap(m)).toList();
  }

  Future<int> deleteQuote(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
