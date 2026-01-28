import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/navigation_provider.dart';
import '../core/theme/app_colors.dart';
import '../features/home/presentation/dashboard_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/aircraft/presentation/aircraft_screen.dart';
import 'sidebar.dart';

class MainLayout extends StatefulWidget {
  final Widget? child;
  
  const MainLayout({super.key, this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _sidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Consumer<NavigationProvider>(
      builder: (context, navProvider, _) {
        // Determine which page to show
        Widget pageContent;
        switch (navProvider.currentPage) {
          case 'dashboard':
            pageContent = const DashboardScreen();
            break;
          case 'tasks':
            pageContent = const TasksScreen();
            break;
          case 'aircraft':
            pageContent = const AircraftScreen();
            break;
          default:
            pageContent = const DashboardScreen();
        }

        if (isMobile) {
          // Mobile layout with full-screen sidebar overlay
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.darkBlue,
              elevation: 1,
              leading: !_sidebarOpen
                  ? IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _sidebarOpen = !_sidebarOpen;
                        });
                      },
                    )
                  : null,
              title: _sidebarOpen
                  ? Row(
                      children: const [
                        Icon(Icons.flight_takeoff, color: AppColors.amberAccent, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'RampCheck',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : const Text(
                      'RampCheck',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
            body: _sidebarOpen
                ? Sidebar(
                    onNavigate: () {
                      setState(() {
                        _sidebarOpen = false;
                      });
                    },
                  )
                : pageContent,
          );
        } else {
          // Desktop layout with permanent sidebar
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: Sidebar(onNavigate: () {}),
                ),
                Expanded(child: pageContent),
              ],
            ),
          );
        }
      },
    );
  }
}