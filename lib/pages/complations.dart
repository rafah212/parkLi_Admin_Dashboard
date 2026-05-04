import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../app_data.dart'; //

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  // تحديث الحالة وإرسال إشعار لحظي للمستخدم
  Future<void> _updateStatusAndNotify(Map<String, dynamic> item, String newStatus) async {
    try {
      await supabase
          .from('complaints')
          .update({'status': newStatus})
          .match({'id': item['id']});

      if (newStatus == 'solved') {
        await supabase.from('notifications').insert({
          'user_id': item['user_id'],
          'title': 'Complaint Solved ✅',
          'body': 'Your issue regarding "${item['category'] ?? 'Parking'}" has been fixed. Thank you!',
          'type': 'complaint',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status updated and notification sent!"),
            backgroundColor: newStatus == 'solved' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // تعريف ألوان الدارك مود
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Complaints Management", 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("User Reports & Issues", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('complaints').stream(primaryKey: ['id']).order('created_at'),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: textColor)));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final complaints = snapshot.data!;
                  if (complaints.isEmpty) {
                    return Center(child: Text("No complaints found. Clean inbox!", style: TextStyle(color: textColor)));
                  }

                  return ListView.builder(
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      final item = complaints[index];
                      return FutureBuilder(
                        future: supabase.from('profiles').select('full_name').eq('id', item['user_id']).single(),
                        builder: (context, userSnapshot) {
                          String userName = userSnapshot.hasData ? userSnapshot.data!['full_name'] : "Loading...";
                          return _buildComplaintCard(item, userName, cardColor, textColor);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> item, String userName, Color cardColor, Color textColor) {
    DateTime createdAt = DateTime.parse(item['created_at']);
    String formattedDate = DateFormat('yyyy-MM-dd').format(createdAt);
    bool isSolved = item['status'] == 'solved';

    return Card(
      color: cardColor, // دعم الدارك مود للكرت
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: textColor,
          collapsedIconColor: textColor,
          leading: Icon(Icons.warning_amber_rounded, 
            color: isSolved ? Colors.green : Colors.orange),
          title: Text(item['category'] ?? "General Issue", 
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          subtitle: Text("From: $userName | $formattedDate", 
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Message:", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  Text(item['message'] ?? "No message content", 
                    style: TextStyle(color: textColor.withOpacity(0.8))),
                  Divider(height: 30, color: textColor.withOpacity(0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isSolved)
                        TextButton(
                          onPressed: () => _updateStatusAndNotify(item, 'pending'),
                          child: const Text("Set Pending", style: TextStyle(color: Colors.orange)),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateStatusAndNotify(item, 'solved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSolved ? Colors.grey : const Color(0xFFC8D8C3),
                          elevation: 0,
                        ),
                        child: Text(isSolved ? "Solved" : "Mark Solved", 
                          style: const TextStyle(color: Color(0xFF195A64), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}