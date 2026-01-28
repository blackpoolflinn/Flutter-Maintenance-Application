import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/tasks_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TasksProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createTask() {
    if (_titleController.text.isNotEmpty) {
      context.read<TasksProvider>().createTask(
            _titleController.text,
            _descriptionController.text,
          );
      _titleController.clear();
      _descriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment, color: Colors.grey[800], size: 28),
                      const SizedBox(width: 10),
                      Text(
                        "Tasks",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
            ],
            // Create Task Form
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Task',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Task title',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Description (optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _createTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amberAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Add Task'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tasks List
            const Text(
              'Tasks List',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<TasksProvider>(
              builder: (context, tasksProvider, _) {
                if (tasksProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (tasksProvider.tasks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No tasks yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasksProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasksProvider.tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.status == 'completed',
                          onChanged: (value) {
                            tasksProvider.updateTaskStatus(
                              task,
                              value == true ? 'completed' : 'pending',
                            );
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.status == 'completed'
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: task.description.isNotEmpty
                            ? Text(task.description)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            tasksProvider.deleteTask(task.id!);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
