import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Job {
  final int? id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;

  Job({
    this.id,
    required this.title,
    required this.description,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertJob(Job job) async {
    final db = await database;
    return db.insert('jobs', job.toMap());
  }

  Future<List<Job>> getJobs() async {
    final db = await database;
    final result = await db.query('jobs', orderBy: 'id DESC');
    return result.map((map) => Job.fromMap(map)).toList();
  }

  Future<int> updateJob(Job job) async {
    final db = await database;
    return db.update('jobs', job.toMap(), where: 'id = ?', whereArgs: [job.id]);
  }

  Future<int> deleteJob(int id) async {
    final db = await database;
    return db.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }
}
