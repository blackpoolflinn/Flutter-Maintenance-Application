import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../core/providers/aircraft_provider.dart';
import '../../../data/models/job.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedAircraftId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TasksProvider>().loadTasks();
      context.read<AircraftProvider>().loadAircraft();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addAttachments(Task task) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    final pickedPaths = result.paths.whereType<String>().toList();
    if (pickedPaths.isEmpty) return;

    final updated = List<String>.from(task.attachments);
    for (final filePath in pickedPaths) {
      if (!updated.contains(filePath)) {
        updated.add(filePath);
      }
    }

    if (mounted) {
      await context.read<TasksProvider>().updateTaskAttachments(task, updated);
    }
  }

  Future<void> _removeAttachment(Task task, String attachmentPath) async {
    final updated = task.attachments.where((path) => path != attachmentPath).toList();
    if (mounted) {
      await context.read<TasksProvider>().updateTaskAttachments(task, updated);
    }
  }

  bool _isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return extension == '.png' ||
        extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.gif' ||
        extension == '.bmp' ||
        extension == '.webp';
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'inProgress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.statusPending;
      case 'inProgress':
        return AppColors.statusInProgress;
      case 'completed':
        return AppColors.statusCompleted;
      default:
        return AppColors.textSecondary;
    }
  }

  void _createTask() {
    final aircraftProvider = context.read<AircraftProvider>();

    if (aircraftProvider.aircraft.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create an aircraft before adding a task.')),
      );
      return;
    }

    if (_selectedAircraftId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an aircraft for this task.')),
      );
      return;
    }

    if (_titleController.text.isNotEmpty) {
      context.read<TasksProvider>().createTask(
            title: _titleController.text,
            description: _descriptionController.text,
            aircraftId: _selectedAircraftId!,
          );
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedAircraftId = null;
      });
    }
  }

  String _getAircraftLabel(int? aircraftId, List aircraftList) {
    if (aircraftId == null) {
      return 'Unassigned';
    }
    for (final aircraft in aircraftList) {
      if (aircraft.id == aircraftId) {
        return '${aircraft.registrationNumber} - ${aircraft.model}';
      }
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    final aircraftProvider = context.watch<AircraftProvider>();
    final hasAircraft = aircraftProvider.aircraft.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Row(
                children: [
                  Icon(Icons.assignment, color: AppColors.textPrimary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    "Tasks",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            // Create Task Form
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
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
                  DropdownButtonFormField<int>(
                    value: _selectedAircraftId,
                    items: aircraftProvider.aircraft
                        .where((aircraft) => aircraft.id != null)
                        .map(
                          (aircraft) => DropdownMenuItem<int>(
                            value: aircraft.id,
                            child: Text('${aircraft.registrationNumber} - ${aircraft.model}'),
                          ),
                        )
                        .toList(),
                    decoration: InputDecoration(
                      hintText: 'Select aircraft',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    disabledHint: const Text('No aircraft available'),
                    onSaved: (_) {},
                    onChanged: hasAircraft
                        ? (value) {
                            setState(() {
                              _selectedAircraftId = value;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 12),
                  if (!hasAircraft)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Create an aircraft first to add tasks.',
                        style: TextStyle(color: AppColors.warningDark),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: hasAircraft ? _createTask : null,
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
                      child: ExpansionTile(
                        leading: PopupMenuButton<String>(
                          initialValue: task.status,
                          onSelected: (String status) {
                            tasksProvider.updateTaskStatus(task, status);
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'inProgress',
                              child: Text('In Progress'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'completed',
                              child: Text('Completed'),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(task.status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusLabel(task.status),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.status == 'completed'
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          'Aircraft: ${_getAircraftLabel(task.aircraftId, aircraftProvider.aircraft)}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text('Description: ${task.description}'),
                                  ),
                                if (task.aircraftId == null && aircraftProvider.aircraft.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: DropdownButton<int>(
                                      value: null,
                                      hint: const Text('Assign aircraft'),
                                      items: aircraftProvider.aircraft
                                          .where((aircraft) => aircraft.id != null)
                                          .map(
                                            (aircraft) => DropdownMenuItem<int>(
                                              value: aircraft.id,
                                              child: Text('${aircraft.registrationNumber} - ${aircraft.model}'),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          tasksProvider.updateTaskAircraft(task, value);
                                        }
                                      },
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Attachments',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _addAttachments(task),
                                      icon: const Icon(Icons.attach_file, size: 16),
                                      label: const Text('Add'),
                                    ),
                                  ],
                                ),
                                if (task.attachments.isEmpty)
                                  Text(
                                    'No attachments',
                                    style: TextStyle(color: AppColors.textTertiary),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: task.attachments.map((attachmentPath) {
                                      final fileName = path.basename(attachmentPath);
                                      final isImage = _isImageFile(attachmentPath);
                                      return Chip(
                                        avatar: isImage
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Image.file(
                                                  File(attachmentPath),
                                                  width: 24,
                                                  height: 24,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.image, size: 18);
                                                  },
                                                ),
                                              )
                                            : const Icon(Icons.attach_file, size: 18),
                                        label: Text(fileName),
                                        deleteIcon: const Icon(Icons.close, size: 16),
                                        onDeleted: () => _removeAttachment(task, attachmentPath),
                                      );
                                    }).toList(),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => tasksProvider.deleteTask(task.id!),
                                      icon: const Icon(Icons.delete, color: AppColors.error),
                                      label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
