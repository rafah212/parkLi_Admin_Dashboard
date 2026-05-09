import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart'; 
import 'pages/loginadmin.dart';
import 'pages/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
   url: 'https://bpvrhoqnwjgrnuevlofk.supabase.co',
   anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwdnJob3Fud2pncm51ZXZsb2ZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUwNzM1MDksImV4cCI6MjA5MDY0OTUwOX0.thlqWQUzr9v0Kj9-wIaubmwDiZ5GNAs4dkGkLXfCSMM',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  void changeTheme() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ParkLi Admin Dashboard',
      theme: ThemeData(
        brightness: AppData.isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: const Color(0xFF195A64),
        scaffoldBackgroundColor: AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD),
      ),
      
      initialRoute: '/loginadmin', 
      routes: {
        '/loginadmin': (context) => const LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final String name = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => DashboardPage(adminName: name),
          );
        }
        return null;
      },
    );
  }
}