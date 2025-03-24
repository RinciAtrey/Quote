import 'package:path/path.dart';
import 'package:quotes_daily/model/CustomQuote/custom_quote_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper{
  static final DatabaseHelper _instance= DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper()=> _instance;
  DatabaseHelper._internal();


  Future<Database> get database async {
    if(_database!= null)
      return _database!;
    _database= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    String path= join(await getDatabasesPath(),"quotes_db.db" );
    return await openDatabase(path, version: 1, onCreate: _onCreate);
}
  Future<void> _onCreate(Database db, int version) async{

    await db.execute(
      '''
      CREATE TABLE quotes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      content TEXT,
      color TEXT,
      dateTime TEXT)
      '''
      );
  }

  Future<int> insertQuote(CustomQuoteModel quote) async{
    final db= await database;
    return await db.insert('quotes', quote.toMap());
  }

  Future<List<CustomQuoteModel>> getQuotes() async{
    final db= await database;
    final List<Map<String, dynamic>> maps = await db.query('quotes');
    return List.generate(maps.length, (i)=> CustomQuoteModel.fromMap(maps[i]));
  }

  Future<int> updateQuote(CustomQuoteModel quote) async{
    final db= await database;
    return await db.update('quotes',
        quote.toMap(),
    where: 'id= ?',
    whereArgs: [quote.id]
    );
  }

  Future<int> deleteQuote(int id) async{
    final db= await database;
    return await db.delete('quotes',
        where: 'id= ?',
        whereArgs: [id]
    );
  }


}

