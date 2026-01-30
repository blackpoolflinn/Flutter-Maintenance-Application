import 'package:flutter/material.dart';
import '../../data/models/job.dart';

class TasksProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
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
      await _db.insertTask(task);
      await loadTasks();
    } catch (e) {
      print('Error creating task: $e');
      // Fail silently and refresh
      await loadTasks();
    }
  }

  /// Delete a task
  Future<void> deleteTask(int id) async {
    try {
      await _db.deleteTask(id);
      await loadTasks();
    } catch (e) {
      print('Error deleting task: $e');
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
      await loadTasks();
    } catch (e) {
      print('Error updating task: $e');
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
      print('Error updating task aircraft: $e');
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
      print('Error updating task attachments: $e');
      await loadTasks();
    }
  }
}
