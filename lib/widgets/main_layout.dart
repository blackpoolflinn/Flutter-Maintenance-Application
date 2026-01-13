import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/auth_provider.dart';
import 'sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // The specific screen (Dashboard, Tasks, etc.)
  
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This calls the logout method in AuthProvider.
          // If main.dart is set up with a Consumer, this will automatically 
          // switch the screen back to LoginScreen.
          context.read<AuthProvider>().logout();
        },
        backgroundColor: Colors.red,
        tooltip: 'Logout',
        child: const Icon(Icons.logout),
      ),

      body: Row(
        children: [
          const Sidebar(), // Always visible
          Expanded(child: child), // The feature screen goes here
        ],
      ),
    );
  }
}