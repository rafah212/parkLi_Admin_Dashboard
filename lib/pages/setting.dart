import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart';
import '../main.dart'; // استدعاء المين لتحديث الثيم العام
import 'package:url_launcher/url_launcher.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final supabase = Supabase.instance.client;
  String adminName = "Rafah Saleh";

  // دالة لفتح تطبيق الإيميل
  Future<void> _sendEmail(String email) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request - ParkLi Admin',
    );
    try {
      if (await canLaunchUrl(params)) {
        await launchUrl(params);
      } else {
        throw 'Could not launch $email';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open email app: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("System Settings", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle("Admin Profile"),
          _buildSettingCard(
            cardColor: cardColor,
            child: ListTile(
              leading: const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFC8ACBB),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(adminName, style: TextStyle(color: textColor)),
              subtitle: const Text("Super Admin", style: TextStyle(color: Colors.grey)),
              trailing: IconButton(
                icon: Icon(Icons.edit_outlined, size: 20, color: textColor),
                onPressed: () => _showEditNameDialog(cardColor, textColor),
              ),
            ),
          ),
          
          const SizedBox(height: 25),

          _buildSectionTitle("System Preferences"),
          _buildSettingCard(
            cardColor: cardColor,
            child: SwitchListTile(
              title: Text("Dark Mode", style: TextStyle(color: textColor)),
              secondary: Icon(Icons.dark_mode_outlined, color: textColor),
              value: AppData.isDarkMode,
              activeColor: const Color(0xFF195A64),
              onChanged: (val) {
                setState(() {
                  AppData.isDarkMode = val;
                });
                // تحديث الثيم في تطبيق المين كاملاً
                MyApp.of(context)?.changeTheme();
              },
            ),
          ),

          const SizedBox(height: 25),

          _buildSectionTitle("Support & Security"),
          _buildSettingCard(
            cardColor: cardColor,
            child: Column(
              children: [
                _buildClickableRow(Icons.lock_outline, "Privacy & Security", textColor, onTap: () {
                  _showPrivacyDialog(user?.email ?? "N/A", cardColor, textColor);
                }),
                const Divider(indent: 50),
                _buildClickableRow(Icons.help_outline, "Help Center", textColor, onTap: () => _showHelpCenterDialog(cardColor, textColor)),
                const Divider(indent: 50),
                _buildClickableRow(Icons.logout, "Logout", Colors.red, onTap: () async {
                  await supabase.auth.signOut();
                  if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/loginadmin', (route) => false);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Dialogs المعدلة لدعم الثيم ---

  void _showEditNameDialog(Color cardColor, Color textColor) {
    TextEditingController _nameController = TextEditingController(text: adminName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text("Edit Admin Name", style: TextStyle(color: textColor)),
        content: TextField(
          controller: _nameController,
          style: TextStyle(color: textColor),
          decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () {
            setState(() => adminName = _nameController.text);
            Navigator.pop(context);
          }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)), child: const Text("Save")),
        ],
      ),
    );
  }

  void _showHelpCenterDialog(Color cardColor, Color textColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text("Help Center", style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Click an email to contact support:", style: TextStyle(color: textColor.withOpacity(0.7))),
              const SizedBox(height: 15),
              _buildEmailTile("Rafah Aljabri", "rafahsaljabri@gmail.com", textColor),
              _buildEmailTile("Asail Faleh", "asailfaleh@gmail.com", textColor),
              _buildEmailTile("Mona Alzunidi", "mona.alzunidi17@gmail.com", textColor),
              _buildEmailTile("Ghada", "ghd22344@gmail.com", textColor),
              _buildEmailTile("Norah", "n.mu@gmail.com", textColor), // الإيميل الخامس
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  Widget _buildEmailTile(String name, String email, Color textColor) {
    return ListTile(
      title: Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      leading: const Icon(Icons.email_outlined, color: Color(0xFFE06399), size: 20),
      onTap: () => _sendEmail(email),
    );
  }

  void _showPrivacyDialog(String email, Color cardColor, Color textColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text("Privacy & Security", style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Admin: $adminName", style: TextStyle(color: textColor)),
            Text("Email: $email", style: TextStyle(color: textColor)),
            Text("Role: Super Admin", style: TextStyle(color: textColor)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildSettingCard({required Widget child, required Color cardColor}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: child,
    );
  }
  Widget _buildClickableRow(IconData icon, String title, Color color, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}