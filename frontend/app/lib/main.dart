import 'package:flutter/material.dart';
import 'screens/main_page/home_screen.dart';
import 'screens/main_page/login_screen.dart';
import 'screens/main_page/main_app_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Giữ Xe',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => MainAppScreen(
              username: args?['username'] ?? 'Unknown',
              role: args?['role'] ?? 'Unknown',
            ),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}