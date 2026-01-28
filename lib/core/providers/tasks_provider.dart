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
  Future<void> createTask(String title, String description) async {
    try {
      final task = Task(
        title: title,
        description: description,
        status: 'pending',
      );
      await _db.insertTask(task);
      await loadTasks();
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  /// Delete a task
  Future<void> deleteTask(int id) async {
    try {
      await _db.deleteTask(id);
      await loadTasks();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
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
        createdAt: task.createdAt,
      );
      await _db.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
}
