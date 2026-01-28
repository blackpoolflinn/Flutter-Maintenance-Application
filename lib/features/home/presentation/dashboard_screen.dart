import 'package:flutter/material.dart';
import 'dashboard_widgets.dart';
import '../../../widgets/stats_grid.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              const HeaderDesktop(),
              const SizedBox(height: 24),
            ],

            const StatsGrid(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}