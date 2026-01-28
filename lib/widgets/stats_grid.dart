import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/providers/tasks_provider.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;

  const StatCard({super.key, required this.title, required this.count, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    final titleFontSize = width < 600 ? 11.0 : 13.0;
    final countFontSize = width < 600 ? 20.0 : 28.0;
    final iconSize = width < 600 ? 24.0 : 32.0;
    
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: AppColors.textWhite, fontSize: titleFontSize, fontWeight: FontWeight.w500)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(count, style: TextStyle(color: AppColors.textWhite, fontSize: countFontSize, fontWeight: FontWeight.bold)),
              ),
              Icon(icon, color: AppColors.textWhite.withValues(alpha: 0.5), size: iconSize),
            ],
          )
        ],
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, _) {
        // Calculate task statistics
        final total = tasksProvider.tasks.length;
        final pending = tasksProvider.tasks.where((t) => t.status == 'pending').length;
        final inProgress = tasksProvider.tasks.where((t) => t.status == 'inProgress').length;
        final completed = tasksProvider.tasks.where((t) => t.status == 'completed').length;

        List<Widget> cards = [
          StatCard(title: "Total Tasks", count: total.toString(), color: const Color(0xFFEAB308), icon: Icons.handyman),
          StatCard(title: "In Progress", count: inProgress.toString(), color: const Color(0xFF3B82F6), icon: Icons.loop),
          StatCard(title: "Completed", count: completed.toString(), color: const Color(0xFF22C55E), icon: Icons.check_circle),
          StatCard(title: "Pending", count: pending.toString(), color: const Color(0xFFEF4444), icon: Icons.bolt),
        ];

        if (width > 900) {
          return Row(
            children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0), child: c))).toList(),
          );
        } else {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: cards,
          );
        }
      },
    );
  }
}