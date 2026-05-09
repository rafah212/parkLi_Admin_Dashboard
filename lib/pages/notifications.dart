import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String _selectedType = 'general'; 

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) return;

    try {
      await supabase.from('notifications').insert({
        'title': _titleController.text,
        'body': _bodyController.text,
        'type': _selectedType,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      _titleController.clear();
      _bodyController.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification Sent Successfully!")),
        );
      }
    } catch (e) {
      print("Error sending: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF195A64),
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add_alert, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text("Notifications Management", 
          style: TextStyle(color: Color(0xFF195A64), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('notifications').stream(primaryKey: ['id']).order('created_at'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notes = snapshot.data!;
          
          if (notes.isEmpty) {
            return const Center(child: Text("No notifications sent yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: notes.length,
            itemBuilder: (context, index) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 183, 198, 241).withOpacity(0.2),
                  child: const Icon(Icons.notifications_active, color: Color(0xFF195A64)),
                ),
                title: Text(notes[index]['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(notes[index]['body'] ?? ''),
                trailing: Text(
                  DateFormat('MM/dd HH:mm').format(DateTime.parse(notes[index]['created_at'])),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Notification"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: _bodyController, decoration: const InputDecoration(labelText: "Body/Message")),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: ['general', 'alert', 'update'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) {
                  setState(() { _selectedType = newValue!; });
                },
                decoration: const InputDecoration(labelText: "Type"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: _sendNotification,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)),
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}