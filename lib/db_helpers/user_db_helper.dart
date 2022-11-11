import 'dart:developer';

import 'package:path/path.dart';
import '../data_models/task_model.dart';
import '../data_models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UsersDatabase {
  static final UsersDatabase instance = UsersDatabase._init();
  static Database? _database;
  UsersDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    //const boolType = 'BOOLEAN NOT NULL';
    //const integerType = 'INTEGER NOT NULL';

    await db.execute(
        '''CREATE TABLE $tableUsers(${UserFields.id} $idType, ${UserFields.email} $textType, ${UserFields.password} $textType)''');
        await db.execute(
        '''CREATE TABLE $tableTasks(${TaskFields.id} $idType, ${TaskFields.email} $textType,${TaskFields.unique_id} $textType , ${TaskFields.taskState} $textType,${TaskFields.title} $textType,${TaskFields.startDate} $textType,${TaskFields.endDate} $textType,${TaskFields.catagory} $textType,${TaskFields.description} $textType,${TaskFields.status} $textType,${TaskFields.updatedOn} $textType)''');
  }

  Future<User> create(User user) async {
    final db = await instance.database;
    final id = await db.insert(tableUsers, user.toJson());
    return user.copy(id: id);
  }

  Future<User> readUser(String email) async {
    final db = await instance.database;

    final maps = await db.query(tableUsers,
        columns: UserFields.values,
        where: '${UserFields.email} = ?',
        whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      throw Exception('a new User');
    }
  }
    Future<User> loginUser(String email, String password) async {
    final db = await instance.database;

    final maps = await db.query(tableUsers,
        columns: UserFields.values,
        where: '${UserFields.email} = ? AND ${UserFields.password} = ?',
        whereArgs: [email, password]);
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      throw Exception('a new User');
    }
  }
  Future<int?> userExistance(String email) async {
    final db = await instance.database;

    int? count = Sqflite.firstIntValue(await db.query(tableUsers,
        columns: UserFields.values,
        where: '${UserFields.email} = ?',
        whereArgs: [email]));

    log("Total Users$count");
    return count;
  }


  Future<int> update(User user) async {
    final db = await instance.database;
    return db.update(tableUsers, user.toJson(),
        where: '${UserFields.id} = ?', whereArgs: [user.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db
        .delete(tableUsers, where: '${UserFields.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
