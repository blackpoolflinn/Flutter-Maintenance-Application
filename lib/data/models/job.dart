import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Task {
  final int? id;
  final String title;
  final String description;
  final String status;
  final int? aircraftId;
  final DateTime? syncedAt;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.status = 'pending',
    this.aircraftId,
    this.syncedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'aircraftId': aircraftId,
      'syncedAt': syncedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      aircraftId: map['aircraftId'],
      syncedAt: map['syncedAt'] != null ? DateTime.parse(map['syncedAt']) : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class Aircraft {
  final int? id;
  final String registrationNumber;
  final String model;
  final String manufacturer;
  final int yearOfManufacture;
  final String status;
  final DateTime? syncedAt;
  final DateTime createdAt;

  Aircraft({
    this.id,
    required this.registrationNumber,
    required this.model,
    required this.manufacturer,
    required this.yearOfManufacture,
    this.status = 'active',
    this.syncedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'model': model,
      'manufacturer': manufacturer,
      'yearOfManufacture': yearOfManufacture,
      'status': status,
      'syncedAt': syncedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Aircraft.fromMap(Map<String, dynamic> map) {
    return Aircraft(
      id: map['id'],
      registrationNumber: map['registrationNumber'],
      model: map['model'],
      manufacturer: map['manufacturer'],
      yearOfManufacture: map['yearOfManufacture'],
      status: map['status'],
      syncedAt: map['syncedAt'] != null ? DateTime.parse(map['syncedAt']) : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class DatabaseHelper {
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
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        aircraftId INTEGER,
        syncedAt TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS aircraft (
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
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE tasks ADD COLUMN aircraftId INTEGER');
    }

    if (oldVersion < 5) {
      await db.execute('ALTER TABLE tasks ADD COLUMN syncedAt TEXT');
      await db.execute('ALTER TABLE aircraft ADD COLUMN syncedAt TEXT');
    }
  }

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

  Future<void> markTasksSynced(List<int> ids, DateTime syncedAt) async {
    if (ids.isEmpty) return;
    final db = await database;
    final syncedAtValue = syncedAt.toIso8601String();
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

  Future<void> markAircraftSynced(List<int> ids, DateTime syncedAt) async {
    if (ids.isEmpty) return;
    final db = await database;
    final syncedAtValue = syncedAt.toIso8601String();
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE aircraft SET syncedAt = ? WHERE id IN ($placeholders)',
      [syncedAtValue, ...ids],
    );
  }
}
