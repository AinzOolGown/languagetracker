import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('language_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // bumped version for migration
      onCreate: _createDB,
    );
  }

  // create db
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      type TEXT,
      dueDate TEXT,
      difficulty INTEGER,
      comments TEXT,
      completed INTEGER,
      createdAt TEXT,
      deleted INTEGER DEFAULT 0
    )
    ''');

    await db.execute('''
    CREATE TABLE xp_history(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      taskName TEXT,
      type TEXT,
      xp INTEGER,
      timestamp TEXT
    )
    ''');
  }

  // CRUD
  Future<int> createTask(Task task) async {
    final db = await instance.database;

    final taskMap = task.toMap();
    taskMap['createdAt'] = DateTime.now().toIso8601String();
    taskMap['deleted'] = 0;

    return await db.insert('tasks', taskMap);
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;

    final result = await db.query(
      'tasks',
      where: 'deleted = ?',
      whereArgs: [0],
    );

    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<List<Task>> readActiveTasks() async {
    final db = await instance.database;

    final result = await db.query(
      'tasks',
      where: 'completed = ? AND deleted = ?',
      whereArgs: [0, 0],
    );

    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;

    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // soft delete instead of hard delete
  Future<int> deleteTask(int id) async {
    final db = await instance.database;

    return await db.update(
      'tasks',
      {'deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // XP TRACKING

  Future<void> insertXp({
    required String taskName,
    required String type,
    required int xp,
  }) async {
    final db = await instance.database;

    await db.insert('xp_history', {
      'taskName': taskName,
      'type': type, // 🔥 key addition
      'xp': xp,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getXpHistory() async {
    final db = await instance.database;

    return await db.query(
      'xp_history',
      orderBy: 'timestamp DESC',
    );
  }

  // ANALYTICS / STATS

  Future<int> getLifetimeXp() async {
    final db = await instance.database;

    final result =
        await db.rawQuery('SELECT SUM(xp) as total FROM xp_history');

    return result.first['total'] == null
        ? 0
        : (result.first['total'] as int);
  }

  Future<int> getTotalTasksAdded() async {
    final db = await instance.database;

    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM tasks');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalTasksRemoved() async {
    final db = await instance.database;

    final result = await db.rawQuery(
        'SELECT COUNT(*) FROM tasks WHERE deleted = 1');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // XP by type 
  Future<Map<String, int>> getXpByType() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT type, SUM(xp) as totalXp
      FROM xp_history
      GROUP BY type
    ''');

    Map<String, int> xpByType = {};

    for (var row in result) {
      final type = row['type'] as String;
      final xp = row['totalXp'] as int? ?? 0;
      xpByType[type] = xp;
    }

    return xpByType;
  }
}