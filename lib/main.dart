import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/loginadmin.dart';
import 'pages/dashboard.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bpvrhoqnwjgrnuevlofk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwdnJob3Fud2pncm51ZXZsb2ZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUwNzM1MDksImV4cCI6MjA5MDY0OTUwOX0.thlqWQUzr9v0Kj9-wIaubmwDiZ5GNAs4dkGkLXfCSMM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

      return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ParkLi Admin Dashboard',
    theme: ThemeData(
      primaryColor: const Color(0xFF195A64),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    ),
    home: const LoginPage(), // خليها تبدأ بصفحة اللوجن
    onGenerateRoute: (settings) {
      if (settings.name == '/dashboard') {
        final String name = settings.arguments as String; // هنا نستقبل الاسم
        return MaterialPageRoute(
          builder: (context) => DashboardPage(adminName: name),
        );
      }
          return null;
        },
      );
    }
  }