import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart'; 

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _deleteUser(String userId) async {
    try {
      await supabase.from('profiles').delete().eq('id', userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppData.translate("User deleted successfully")),
            backgroundColor: const Color(0xFF195A64),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppData.translate('Error')}: $e"), 
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<bool>(
          valueListenable: AppData.languageNotifier,
          builder: (context, isArabic, child) {
            return Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                backgroundColor: AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                title: Text(AppData.translate("Confirm Deletion")),
                content: Text(
                  "${AppData.translate('Are you sure you want to delete')} $userName?\n${AppData.translate('All associated data will be removed.')}"
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppData.translate("Cancel"), style: const TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteUser(userId);
                    },
                    child: Text(AppData.translate("Delete"), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return ValueListenableBuilder<bool>(
      valueListenable: AppData.languageNotifier,
      builder: (context, isArabic, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: Text(
                AppData.translate("Users Management"), 
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: cardColor,
              elevation: 0,
              centerTitle: true,
            ),
            body: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('profiles').stream(primaryKey: ['id']).order('created_at'),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "${AppData.translate('Error')}: ${snapshot.error}", 
                      style: TextStyle(color: textColor),
                    ),
                  );
                }
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final users = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(user, cardColor, textColor);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, Color cardColor, Color textColor) {
    String? avatarUrl = user['avatars_url']; 
    
    // تحديث ارقام الجوال على حسب اللغة
    String displayPhone = AppData.formatNumbers(user['phone_number'] ?? AppData.translate("No Phone"));

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF195A64).withOpacity(0.1),
          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) 
              ? NetworkImage(avatarUrl) 
              : null,
          child: (avatarUrl == null || avatarUrl.isEmpty)
              ? Text(
                  (user['full_name'] ?? "U")[0].toUpperCase(),
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          user['full_name'] ?? AppData.translate("Unknown User"), 
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Text(user['email'] ?? AppData.translate("No Email"), style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Text(displayPhone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _showDeleteDialog(user['id'], user['full_name'] ?? AppData.translate("User")),
        ),
      ),
    );
  }
}