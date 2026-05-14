import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart';
import '../main.dart'; 
import 'package:url_launcher/url_launcher.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final supabase = Supabase.instance.client;
  String adminName = "Rafah Aljabri"; // تحديث الاسم المعتمد للأدمن

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
        SnackBar(content: Text("${AppData.translate('Could not open email app')}: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    // استخدام المستمع الذكي لإعادة بناء الصفحة بالكامل وتغيير اتجاهها لحظة ضغط زر اللغة
    return ValueListenableBuilder<bool>(
      valueListenable: AppData.languageNotifier,
      builder: (context, isArabic, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: Text(
                AppData.translate("System Settings"), 
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: cardColor,
              elevation: 0,
              centerTitle: true,
            ),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionTitle(AppData.translate("Admin Profile")),
                _buildSettingCard(
                  cardColor: cardColor,
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFFC8ACBB), // استخدام درجة الموف المعتمدة لهويتكم الأنيقة
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(adminName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    subtitle: Text(AppData.translate("Super Admin"), style: const TextStyle(color: Colors.grey)),
                    trailing: IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20, color: textColor),
                      onPressed: () => _showEditNameDialog(cardColor, textColor),
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),

                _buildSectionTitle(AppData.translate("System Preferences")),
                _buildSettingCard(
                  cardColor: cardColor,
                  child: Column(
                    children: [
                      // زر الدارك مود الأساسي
                      SwitchListTile(
                        title: Text(AppData.translate("Dark Mode"), style: TextStyle(color: textColor)),
                        secondary: Icon(Icons.dark_mode_outlined, color: textColor),
                        value: AppData.isDarkMode,
                        activeColor: const Color(0xFF195A64),
                        onChanged: (val) {
                          setState(() {
                            AppData.isDarkMode = val;
                          });
                          MyApp.of(context)?.changeTheme();
                        },
                      ),
                      const Divider(height: 1, indent: 50),
                      
                      // 🌐 الميزة الجديدة: زر تغيير اللغة والتحكم الفوري بالسيستم
                      ListTile(
                        leading: Icon(Icons.language_outlined, color: textColor),
                        title: Text(AppData.translate("Language"), style: TextStyle(color: textColor)),
                        trailing: DropdownButton<bool>(
                          value: AppData.isArabic,
                          dropdownColor: cardColor,
                          underline: const SizedBox(),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                          items: [
                            DropdownMenuItem(
                              value: false,
                              child: Text(AppData.translate("English")),
                            ),
                            DropdownMenuItem(
                              value: true,
                              child: Text(AppData.translate("Arabic")),
                            ),
                          ],
                          onChanged: (bool? newValue) {
                            if (newValue != null) {
                              // إخطار المنبه المركزي لتحديث كافة صفحات وقوائم الداشبورد فوراً
                              AppData.languageNotifier.value = newValue;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                _buildSectionTitle(AppData.translate("Support & Security")),
                _buildSettingCard(
                  cardColor: cardColor,
                  child: Column(
                    children: [
                      _buildClickableRow(
                        Icons.lock_outline, 
                        AppData.translate("Privacy & Security"), 
                        textColor, 
                        onTap: () {
                          _showPrivacyDialog(user?.email ?? "N/A", cardColor, textColor);
                        },
                      ),
                      const Divider(indent: 50),
                      _buildClickableRow(
                        Icons.help_outline, 
                        AppData.translate("Help Center"), 
                        textColor, 
                        onTap: () => _showHelpCenterDialog(cardColor, textColor),
                      ),
                      const Divider(indent: 50),
                      _buildClickableRow(
                        Icons.logout, 
                        AppData.translate("Logout"), 
                        Colors.red, 
                        onTap: () async {
                          await supabase.auth.signOut();
                          if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/loginadmin', (route) => false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditNameDialog(Color cardColor, Color textColor) {
    TextEditingController _nameController = TextEditingController(text: adminName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(AppData.translate("Edit Admin Name"), style: TextStyle(color: textColor)),
        content: TextField(
          controller: _nameController,
          style: TextStyle(color: textColor),
          decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppData.translate("Cancel"))),
          ElevatedButton(
            onPressed: () {
              setState(() => adminName = _nameController.text);
              Navigator.pop(context);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)), 
            child: Text(AppData.translate("Save")),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterDialog(Color cardColor, Color textColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(AppData.translate("Help Center"), style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppData.translate("Click an email to contact support:"), style: TextStyle(color: textColor.withOpacity(0.7))),
              const SizedBox(height: 15),
              _buildEmailTile("Rafah Aljabri", "rafahsaljabri@gmail.com", textColor),
              _buildEmailTile("Asail Faleh", "asailfaleh@gmail.com", textColor),
              _buildEmailTile("Mona Alzunidi", "mona.alzunidi17@gmail.com", textColor),
              _buildEmailTile("Ghada", "ghd22344@gmail.com", textColor),
              _buildEmailTile("Norah", "n.mu@gmail.com", textColor), 
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppData.translate("Close")))],
      ),
    );
  }

  Widget _buildEmailTile(String name, String email, Color textColor) {
    return ListTile(
      title: Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      leading: const Icon(Icons.email_outlined, color: Color(0xFFC8ACBB), size: 20), // تعديل المتوافق مع لوحة الألوان
      onTap: () => _sendEmail(email),
    );
  }

  void _showPrivacyDialog(String email, Color cardColor, Color textColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(AppData.translate("Privacy & Security"), style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${AppData.translate('Admin')}: $adminName", style: TextStyle(color: textColor)),
            Text("${AppData.translate('Email')}: $email", style: TextStyle(color: textColor)),
            Text("${AppData.translate('Role')}: ${AppData.translate('Super Admin')}", style: TextStyle(color: textColor)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppData.translate("Close")))],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
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
      trailing: Icon(
        AppData.isArabic ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, 
        size: 14, 
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}