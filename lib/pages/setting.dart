import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("System Settings", 
          style: TextStyle(color: Color(0xFF195A64), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // القسم الأول: الملف الشخصي
          _buildSectionTitle("Admin Profile"),
          _buildSettingCard(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFC8ACBB),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text("Rafah Saleh"),
              subtitle: const Text("Super Admin"),
              trailing: const Icon(Icons.edit_outlined, size: 20),
            ),
          ),
          
          const SizedBox(height: 25),

          // القسم الثاني: إعدادات النظام
          _buildSectionTitle("System Preferences"),
          _buildSettingCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Push Notifications"),
                  secondary: const Icon(Icons.notifications_none, color: Color(0xFFE06399)),
                  value: _notificationsEnabled,
                  activeColor: const Color(0xFFE06399),
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
                const Divider(indent: 50),
                SwitchListTile(
                  title: const Text("Dark Mode"),
                  secondary: const Icon(Icons.dark_mode_outlined, color: Color(0xFF195A64)),
                  value: _darkMode,
                  activeColor: const Color(0xFF195A64),
                  onChanged: (val) => setState(() => _darkMode = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // القسم الثالث: التحكم في البيانات والدعم
          _buildSectionTitle("Support & Security"),
          _buildSettingCard(
            child: Column(
              children: [
                _buildClickableRow(Icons.lock_outline, "Privacy & Security"),
                const Divider(indent: 50),
                _buildClickableRow(Icons.help_outline, "Help Center"),
                const Divider(indent: 50),
                _buildClickableRow(Icons.logout, "Logout", textColor: Colors.red),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          const Center(
            child: Text("ParkLi Admin v1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ويدجت لبناء عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  // ويدجت للبطاقة البيضاء
  Widget _buildSettingCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: child,
    );
  }

  // ويدجت للسطور القابلة للضغط
  Widget _buildClickableRow(IconData icon, String title, {Color? textColor}) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? const Color(0xFF195A64)),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}