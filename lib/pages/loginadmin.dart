import 'package:flutter/material.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  //  الإيميلات المصرح لها بالدخول كأدمن
  final List<String> _authorizedAdmins = [
    'asailfaleh@gmail.com', 
    'rafahsaljabri@gmail.com',
    'mona.alzunidi17@gmail.com',
    'ghd22344@gmail.com',
    'norah.n.mu@gmail.com'
  ];

  Future<void> _login() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    if (!_authorizedAdmins.contains(email)) {
      _showError("Access Denied: Email not authorized as Admin");
      return;
    }

    if (password == "ParkLi2026") { 
      String adminName = email == 'rafahsaljabri@gmail.com' ? 'Rafah' : 'Asayl';
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(adminName: adminName),
        ),
      );
    } else {
      _showError("Incorrect Password. Please try again");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: const Color(0xFF195A64), 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 232, 232),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("ParkLi Admin", 
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Color(0xFF195A64))),
              const SizedBox(height: 8),
              const Text("Secure Admin Access", style: TextStyle(color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 50),
              
              _buildTextField(
                controller: _emailController,
                label: "Admin Email",
                icon: Icons.admin_panel_settings_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                label: "Shared Password",
                icon: Icons.lock_open_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF195A64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Text("Sign In", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF195A64)),
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF195A64), width: 2), 
        ),
      ),
    );
  }
}