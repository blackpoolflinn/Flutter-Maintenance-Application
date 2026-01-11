// lib/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // The specific screen (Dashboard, Tasks, etc.)
  
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(), // Always visible
          Expanded(child: child), // The feature screen goes here
        ],
      ),
    );
  }
}