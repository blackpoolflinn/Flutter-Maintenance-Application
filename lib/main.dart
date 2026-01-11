import 'package:flutter/material.dart';
import 'features/auth/presentation/login_screen.dart';
import 'widgets/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maintenance Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      
      // Define the "Big Jumps" here
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainLayout(child: Placeholder()),
      },
    );
  }
}