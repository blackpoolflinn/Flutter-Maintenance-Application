import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/auth_provider.dart';
import 'sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This calls the logout method in AuthProvider.
          context.read<AuthProvider>().logout();
        },
        backgroundColor: Colors.red,
        tooltip: 'Logout',
        child: const Icon(Icons.logout),
      ),

      body: Row(
        children: [
          Expanded(child: child),
        ],
      ),
    );
  }
}