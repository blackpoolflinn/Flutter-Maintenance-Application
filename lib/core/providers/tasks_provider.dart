import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import '../../data/database_helper.dart';
import '../services/audit_service.dart';

class TasksProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final AuditService _auditService = AuditService();
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  /// Initialize and load tasks from database
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _db.getTasks();
    } catch (e) {
      // Handle error silently
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Create a new task
  Future<void> createTask({
    required String title,
    required String description,
    required int aircraftId,
  }) async {
    try {
      final task = Task(
        title: title,
        description: description,
        status: 'pending',
        aircraftId: aircraftId,
        attachments: const [],
        syncedAt: null,
      );
      final taskId = await _db.insertTask(task);
      await _auditService.logTaskCreated(title, taskId);
      await loadTasks();
    } catch (e) {
      // Log error for debugging
      print('Error creating task: $e');
      // Refresh task list even on error to maintain consistency
      await loadTasks();
      rethrow; // Re-throw to allow UI to handle the error
    }
  }

  /// Delete a task
  Future<void> deleteTask(int id) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == id);
      await _db.deleteTask(id);
      await _auditService.logTaskDeleted(task.title, id);
      await loadTasks();
    } catch (e) {
      await loadTasks();
    }
  }

  /// Update task status
  Future<void> updateTaskStatus(Task task, String newStatus) async {
    try {
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        status: newStatus,
        aircraftId: task.aircraftId,
        attachments: task.attachments,
        syncedAt: null,  // Reset to trigger sync on next sync operation
        createdAt: task.createdAt,
      );
      await _db.updateTask(updatedTask);
      await _auditService.logTaskUpdated(task.title, task.id, newStatus);
      await loadTasks();
    } catch (e) {
      await loadTasks();
    }
  }

  /// Update task aircraft link
  Future<void> updateTaskAircraft(Task task, int aircraftId) async {
    try {
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        status: task.status,
        aircraftId: aircraftId,
        attachments: task.attachments,
        syncedAt: null,  // Reset to trigger sync on next sync operation
        createdAt: task.createdAt,
      );
      await _db.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      await loadTasks();
    }
  }

  /// Update task attachments
  Future<void> updateTaskAttachments(Task task, List<String> attachments) async {
    try {
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        status: task.status,
        aircraftId: task.aircraftId,
        attachments: attachments,
        syncedAt: null, // Reset to trigger sync on next sync operation
        createdAt: task.createdAt,
      );
      await _db.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      await loadTasks();
    }
  }
}
