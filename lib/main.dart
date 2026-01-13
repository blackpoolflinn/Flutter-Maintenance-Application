import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'widgets/main_layout.dart';
import 'features/home/presentation/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maintenance Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // show loading indicator while checking auth status
          if (auth.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // if authenticated send to home screen
          if (auth.isAuthenticated) {
            return const MainLayout(child: DashboardScreen());
          }

          // else show login screen
          return const LoginScreen();
        },
      ),
    );
  }
}