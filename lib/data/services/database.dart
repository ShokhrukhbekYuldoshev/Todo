import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DB {
  static late final Database _instance;
  static const String _databaseName = 'todo.db';
  static const int _databaseVersion = 1;

  static Future<void> initialize() async {
    sqfliteFfiInit();
    final databasePath = await getApplicationDocumentsDirectory();
    final databaseFactory = databaseFactoryFfi;
    final databasePathString = databasePath.path;
    _instance = await databaseFactory.openDatabase(
      '$databasePathString/$_databaseName',
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
      ),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        color INTEGER NOT NULL,
        completed INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        dueAt INTEGER,
        completedAt INTEGER,
        priority INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> close() async {
    await _instance.close();
  }

  static Future<List<Map<String, Object?>>> query(String table) async {
    return await _instance.query(table);
  }

  static Future<List<Map<String, Object?>>> queryWhere(
    String table,
    String where,
    List<Object?> whereArgs,
  ) async {
    return await _instance.query(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  static Future<int> insert(String table, Map<String, Object?> values) async {
    return await _instance.insert(table, values);
  }

  static Future<int> update(
    String table,
    Map<String, Object?> values,
    String where,
    List<Object?> whereArgs,
  ) async {
    return await _instance.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // update by id
  static Future<int> updateById(
    String table,
    Map<String, Object?> values,
    int id,
  ) async {
    return await _instance.update(
      table,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> delete(
    String table,
    String where,
    List<Object?> whereArgs,
  ) async {
    return await _instance.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // delete by id
  static Future<int> deleteById(
    String table,
    int id,
  ) async {
    return await _instance.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
