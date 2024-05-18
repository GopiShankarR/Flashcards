import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// DBHelper is a Singleton class (only one instance)
class DBHelper {
  static const String _databaseName = 'decks.db1';
  static const int _databaseVersion = 1;

  DBHelper._();

  static final DBHelper _singleton = DBHelper._();

  factory DBHelper() => _singleton;

  Database? _database;

  get db async {
    _database ??= await _initDatabase();
    
    return _database;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final dbPath = path.join(appDocumentsDir.path, "databases", "decks_db1.db");
          // await deleteDatabase(dbPath);

      final winLinuxDB = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE deck_info(
                deck_id INTEGER PRIMARY KEY,
                title TEXT
              )
            ''');

            await db.execute('''
              CREATE TABLE card_info(
                    id INTEGER PRIMARY KEY,
                deck_id INTEGER,
                question TEXT,
                answer TEXT,
                FOREIGN KEY (deck_id) REFERENCES CardInfo(deck_id)
              )
            ''');
          },
        ),
      );
      return winLinuxDB;
    } else {

    var dbDir = await getApplicationDocumentsDirectory();

    var dbPath = path.join(dbDir.path, _databaseName);

    // await deleteDatabase(dbPath);

    // open the database
    var db = await openDatabase(
      dbPath, 
      version: _databaseVersion, 

      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE deck_info(
            deck_id INTEGER PRIMARY KEY,
            title TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE card_info(
            id INTEGER,
            deck_id INTEGER,
            question TEXT,
            answer TEXT,
            FOREIGN KEY (deck_id) REFERENCES CardInfo(deck_id)
          )
        ''');
      }
    );

    return db;
  }
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where}) async {
    final db = await this.db;
    return where == null ? db.query(table)
                         : db.query(table, where: where);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int id = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

    Future<int> insertDeck(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int deck_id= await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return deck_id;
  }

  Future<void> update(String table, Map<String, dynamic> data, int id) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDeck(String table, Map<String, dynamic> data, int deck_id) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: 'deck_id = ?',
      whereArgs: [deck_id],
    );
  }

  Future<void> delete(String table, int id) async {
    final db = await this.db;
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDeck(String table, int deck_id) async {
    final db = await this.db;
    await db.delete(
      table,
      where: 'deck_id = ?',
      whereArgs: [deck_id],
    );
  }

  Future<int?> count(int deck_id) async {
    final db = await this.db;
     final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM card_info WHERE deck_id = ?', 
        [deck_id]
      )
    );
    return count;
  }
}
