import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'calorie_app.db';
  static const _databaseVersion = 1;

  DatabaseHelper._();
  static final instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, _databaseName),
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        image_local_uri TEXT NOT NULL,
        total_calorie REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE record_items (
        id TEXT PRIMARY KEY,
        record_id TEXT NOT NULL,
        food_name TEXT NOT NULL,
        confidence REAL NOT NULL,
        weight_grams REAL NOT NULL,
        calorie_per_gram REAL NOT NULL,
        item_calorie REAL NOT NULL,
        FOREIGN KEY (record_id) REFERENCES records(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE food_nutrition (
        food_name TEXT PRIMARY KEY,
        calorie_per_gram REAL NOT NULL,
        source TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('record_items');
    await db.delete('records');
    await db.delete('food_nutrition');
  }
}
