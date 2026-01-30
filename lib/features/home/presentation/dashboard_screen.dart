import 'package:flutter/material.dart';
import 'dashboard_widgets.dart';

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
            if (!isDesktop) ...[
              const SyncStatusHeader(),
              const SizedBox(height: 24),
            ],

            if (isDesktop)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: MyTasksCard()),
                  SizedBox(width: 24),
                  Expanded(child: AircraftOverviewCard()),
                ],
              )
            else
              const Column(
                children: [
                  MyTasksCard(),
                  SizedBox(height: 24),
                  AircraftOverviewCard(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}