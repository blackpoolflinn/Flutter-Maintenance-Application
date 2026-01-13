import 'package:flutter/material.dart';
import '../../../widgets/sidebar.dart';
import 'dashboard_widgets.dart';
import '../../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.darkBlue,
              title: const Text("Maintenance Application", style: TextStyle(color: AppColors.textWhite)),
              iconTheme: const IconThemeData(color: AppColors.textWhite),
            ),
      drawer: !isDesktop ? const Sidebar() : null,
      body: Row(
        children: [
          // sidebar visible only on desktop
          if (isDesktop) const SizedBox(width: 250, child: Sidebar()),
          
          // main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) ...[
                    const HeaderDesktop(),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}