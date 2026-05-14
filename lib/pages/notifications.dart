import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../app_data.dart';
import 'dart:ui' as ui; 

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _bodyController = TextEditingController();
  
  // اللي ترجم الاشعار على حسب اللغة اللي يختارها المستخدم بالتطبيق
  String _selectedType = 'general_alert'; 
  String? _selectedUserId; // القيمة NULL يعني تلقائي يرسل لكل المستخدمين
  List<Map<String, dynamic>> _usersList = []; //  اختيار المستخدمين

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // يجيب قائمة المستخدمين من  قاعدة البيانات سوبابيس عند فتح الصفحة
  }

  // جلب المستخدمين Dropdown
  Future<void> _fetchUsers() async {
    try {
      final data = await supabase.from('profiles').select('id, name, email');
      setState(() {
        _usersList = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  // دالة الإرسال لقاعدة الباينات سوبابيس
  Future<void> _sendNotification() async {
    if (_bodyController.text.isEmpty) return;

    // تحديد عنوان ثابت كمفتاح بناءً على النوع ليترجمه الجوال 
    String titleKey = _selectedType; 

    try {
      await supabase.from('notifications').insert({
        'title': titleKey, // يرسل المفتاح الكودي والجوال يترجمه
        'body': _bodyController.text, // تفاصيل إضافية أو يترجم بالكامل بالجوال
        'type': _selectedType,
        'user_id': _selectedUserId, // إذا كان null يروح للكل، وإذا اخترتي مستخدم يروح له هو بس
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      _bodyController.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppData.translate("Notification Sent Successfully!"))),
        );
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
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
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bgColor,
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF195A64),
              onPressed: () => _showAddDialog(cardColor, textColor),
              child: const Icon(Icons.add_alert, color: Colors.white),
            ),
            appBar: AppBar(
              title: Text(
                AppData.translate("Notifications Management"), 
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: cardColor,
              elevation: 0,
              centerTitle: true,
            ),
            body: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('notifications').stream(primaryKey: ['id']).order('created_at'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final notes = snapshot.data!;
                
                if (notes.isEmpty) {
                  return Center(
                    child: Text(
                      AppData.translate("No notifications sent yet."),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    String rawDate = DateFormat('MM/dd HH:mm').format(DateTime.parse(notes[index]['created_at']));
                    String displayDate = AppData.formatNumbers(rawDate);

                    // فحص إذا كان الإشعار لليوزر محدد أو عام للكل للعرض باللوحة
                    String targetUser = notes[index]['user_id'] == null 
                        ? AppData.translate("All Users") 
                        : AppData.translate("Specific User");

                    return Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFC8ACBB).withOpacity(0.2),
                          child: const Icon(Icons.notifications_active, color: Color(0xFF195A64)),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppData.translate(notes[index]['title'] ?? 'No Title'), 
                              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: notes[index]['user_id'] == null ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                targetUser,
                                style: TextStyle(fontSize: 10, color: notes[index]['user_id'] == null ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        subtitle: Text(
                          notes[index]['body'] ?? '',
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                        trailing: Text(
                          displayDate,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog(Color cardColor, Color textColor) {
    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<bool>(
          valueListenable: AppData.languageNotifier,
          builder: (context, isArabic, child) {
            return Directionality(
              textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: StatefulBuilder( // لتحديث  Dropdowns داخل الدايلوج 
                builder: (context, setDialogState) {
                  return AlertDialog(
                    backgroundColor: cardColor,
                    title: Text(AppData.translate("Create New Notification"), style: TextStyle(color: textColor)),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //قائمة لختيار (مستخدم معين أو إرسال للكل)
                          DropdownButtonFormField<String?>(
                            value: _selectedUserId,
                            dropdownColor: cardColor,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: AppData.translate("Send To"),
                              labelStyle: const TextStyle(color: Colors.grey),
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(AppData.translate("All Users (Broadcast)")),
                              ),
                              ..._usersList.map((user) {
                                return DropdownMenuItem<String?>(
                                  value: user['id'].toString(),
                                  child: Text(user['name'] ?? user['email'] ?? 'User'),
                                );
                              }),
                            ],
                            onChanged: (newValue) {
                              setDialogState(() { _selectedUserId = newValue; });
                            },
                          ),
                          const SizedBox(height: 15),
                          
                          // قائمة اختيار نوع ومفتاح الإشعار للترجمة بالجوال
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            dropdownColor: cardColor,
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: AppData.translate("Notification Event Type"),
                              labelStyle: const TextStyle(color: Colors.grey),
                            ),
                            items: [
                              DropdownMenuItem(value: 'general_alert', child: Text(AppData.translate("General System Alert"))),
                              DropdownMenuItem(value: 'violation_issued', child: Text(AppData.translate("New Violation Issued ⚠️"))),
                              DropdownMenuItem(value: 'reservation_confirmed', child: Text(AppData.translate("Reservation Confirmed ✅"))),
                              DropdownMenuItem(value: 'complaint_solved', child: Text(AppData.translate("Complaint Solved 🛠️"))),
                            ],
                            onChanged: (newValue) {
                              setDialogState(() { _selectedType = newValue!; });
                            },
                          ),
                          const SizedBox(height: 15),

                          //  الملاحظات أو نص الرسالة الإضافي
                          TextField(
                            controller: _bodyController, 
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: AppData.translate("Message Details"),
                              labelStyle: const TextStyle(color: Colors.grey),
                              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: Text(AppData.translate("Cancel")),
                      ),
                      ElevatedButton(
                        onPressed: _sendNotification,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)),
                        child: Text(AppData.translate("Send")),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}