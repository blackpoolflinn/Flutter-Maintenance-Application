import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/task.dart';
import 'models/aircraft.dart';
import 'models/audit_log.dart';

class DatabaseHelper {
  // Singleton pattern ensures only one database instance across the app
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'maintenance_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Initialize database tables
  Future<void> _onCreate(Database db, int version) async {
    // Tasks table - stores maintenance tasks
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        aircraftId INTEGER,
        attachments TEXT NOT NULL DEFAULT '[]',
        syncedAt TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Aircraft table - stores aircraft registry
    await db.execute('''
      CREATE TABLE aircraft (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        registrationNumber TEXT NOT NULL,
        model TEXT NOT NULL,
        manufacturer TEXT NOT NULL,
        yearOfManufacture INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        syncedAt TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Audit logs table - tracks all user activities
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT NOT NULL,
        action TEXT NOT NULL,
        entityType TEXT NOT NULL,
        entityId TEXT,
        details TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // Task methods
  Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'id DESC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getUnsyncedTasks() async {
    final db = await database;
    final result = await db.query('tasks', where: 'syncedAt IS NULL');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  /// Marks multiple tasks as synced with the backend
  /// Uses parameterized query with dynamic placeholders for safety
  Future<void> markTasksSynced(List<int> ids, DateTime syncedAt) async {
    if (ids.isEmpty) return;
    final db = await database;
    final syncedAtValue = syncedAt.toIso8601String();
    // Create SQL placeholders (?, ?, ?) - one for each ID
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE tasks SET syncedAt = ? WHERE id IN ($placeholders)',
      [syncedAtValue, ...ids],
    );
  }

  // Aircraft methods
  Future<int> insertAircraft(Aircraft aircraft) async {
    final db = await database;
    return db.insert('aircraft', aircraft.toMap());
  }

  Future<List<Aircraft>> getAircraft() async {
    final db = await database;
    final result = await db.query('aircraft', orderBy: 'id DESC');
    return result.map((map) => Aircraft.fromMap(map)).toList();
  }

  Future<int> updateAircraft(Aircraft aircraft) async {
    final db = await database;
    return db.update('aircraft', aircraft.toMap(), where: 'id = ?', whereArgs: [aircraft.id]);
  }

  Future<int> deleteAircraft(int id) async {
    final db = await database;
    return db.delete('aircraft', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Aircraft>> getUnsyncedAircraft() async {
    final db = await database;
    final result = await db.query('aircraft', where: 'syncedAt IS NULL');
    return result.map((map) => Aircraft.fromMap(map)).toList();
  }

  /// Marks multiple aircraft as synced with the backend
  /// Uses parameterized query with dynamic placeholders for safety
  Future<void> markAircraftSynced(List<int> ids, DateTime syncedAt) async {
    if (ids.isEmpty) return;
    final db = await database;
    final syncedAtValue = syncedAt.toIso8601String();
    // Create SQL placeholders (?, ?, ?) - one for each ID
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE aircraft SET syncedAt = ? WHERE id IN ($placeholders)',
      [syncedAtValue, ...ids],
    );
  }

  // Audit log methods
  Future<int> insertAuditLog(AuditLog log) async {
    final db = await database;
    return db.insert('audit_logs', log.toMap());
  }

  Future<List<AuditLog>> getAuditLogs({int limit = 50}) async {
    final db = await database;
    final result = await db.query(
      'audit_logs',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return result.map((map) => AuditLog.fromMap(map)).toList();
  }

  Future<List<AuditLog>> getRecentAuditLogs({int limit = 10}) async {
    return getAuditLogs(limit: limit);
  }
}
