import 'package:path/path.dart';
import '../data_models/task_model.dart';
import 'package:sqflite/sqflite.dart';

class TasksDatabase {
  static final TasksDatabase instance = TasksDatabase._init();
  static Database? _database;
  TasksDatabase._init();

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
    const textType = 'TEXT NOTNULL';
    //const boolType = 'BOOLEAN NOT NULL';
    //const integerType = 'INTEGER NOT NULL';

    await db.execute(
        '''CREATE TABLE $tableTasks(${TaskFields.id} $idType,${TaskFields.email} $textType,${TaskFields.unique_id} $textType,  ${TaskFields.taskState} $textType,${TaskFields.title} $textType,${TaskFields.startDate} $textType,${TaskFields.endDate} $textType,${TaskFields.catagory} $textType,${TaskFields.description} $textType,${TaskFields.status} $textType,${TaskFields.updatedOn} $textType)''');
  }

  Future<Task> create(Task task) async {
    final db = await instance.database;
    final id = await db.insert(tableTasks, task.toJson());
    return task.copy(id: id);
  }

  Future<Task> readTask(int id) async {
    final db = await instance.database;

    final maps = await db.query(tableTasks,
        columns: TaskFields.values,
        where: '${TaskFields.id} = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Task.fromJson(maps.first);
    } else {
      throw Exception('ID $id not foun');
    }
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;
    const orderBy = '${TaskFields.endDate} ASC';
    final result = await db.query(tableTasks, orderBy: orderBy);
    return result.map((e) => Task.fromJson(e)).toList();
  }

  Future<List<Task>> readAllTasksbyStatus(String taskStatus, String status) async {
    final db = await instance.database;
    final result = await db
        .query(tableTasks, where: 'taskStatus = ? AND status', whereArgs: [taskStatus, status]);
    return result.map((e) => Task.fromJson(e)).toList();
  }

  Future<int> update(Task task) async {
    final db = await instance.database;
    return db.update(
      tableTasks,
      task.toJson(),
      where: '${TaskFields.id} = ?',
      whereArgs: [task.id] 
    );
  }

  Future<int> changeStatus(Task task) async{
    final db = await instance.database;
    return db.update(
      tableTasks,
      task.toJson(),
      where: '${TaskFields.unique_id} = ?',
      whereArgs: [task.unique_id] 
    );
  }

  Future<int> delete(String uniqueId) async{
        final db = await instance.database;
    return db.delete(
      tableTasks,
      where: '${TaskFields.unique_id} = ?',
      whereArgs: [uniqueId] 
    );

  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
