import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

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
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 64, color: AppColors.amberAccent),
                  SizedBox(height: 16),
                  Text(
                    'Tasks Page',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Coming soon...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
