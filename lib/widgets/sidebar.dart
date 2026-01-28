import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/providers/navigation_provider.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback? onNavigate;
  
  const Sidebar({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkBlue,
      child: Column(
        children: [
          // Menu Items
          Expanded(
            child: Consumer<NavigationProvider>(
              builder: (context, navProvider, _) {
                return ListView(
                  children: [
                    SidebarItem(
                      icon: Icons.dashboard,
                      label: "Dashboard",
                      page: "dashboard",
                      isSelected: navProvider.currentPage == "dashboard",
                      onTap: () {
                        navProvider.navigateTo("dashboard");
                        onNavigate?.call();
                      },
                    ),
                    SidebarItem(
                      icon: Icons.assignment,
                      label: "Tasks",
                      page: "tasks",
                      isSelected: navProvider.currentPage == "tasks",
                      onTap: () {
                        navProvider.navigateTo("tasks");
                        onNavigate?.call();
                      },
                    ),
                    SidebarItem(
                      icon: Icons.airplanemode_active,
                      label: "Aircraft",
                      page: "aircraft",
                      isSelected: navProvider.currentPage == "aircraft",
                      onTap: () {
                        navProvider.navigateTo("aircraft");
                        onNavigate?.call();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String page;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.page,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? AppColors.selectedBlue : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppColors.amberAccent : Colors.white70, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        shape: isSelected ? const Border(left: BorderSide(color: AppColors.amberAccent, width: 4)) : null,
        onTap: onTap,
      ),
    );
  }
}