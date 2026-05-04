import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  // دالة لتحديث حالة الشكوى في سوبابيس
  Future<void> _updateStatus(String id, String newStatus) async {
    await supabase
        .from('complaints')
        .update({'status': newStatus})
        .match({'id': id});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to $newStatus")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Complaints Management", 
          style: TextStyle(color: Color(0xFF195A64), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("User Reports & Issues", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('complaints').stream(primaryKey: ['id']).order('created_at'),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final complaints = snapshot.data!;
                  
                  if (complaints.isEmpty) {
                    return const Center(child: Text("No complaints found. Clean inbox!"));
                  }

                  return ListView.builder(
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      final item = complaints[index];
                      return _buildComplaintCard(item);
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

  Widget _buildComplaintCard(Map<String, dynamic> item) {
    DateTime createdAt = DateTime.parse(item['created_at']);
    String formattedDate = DateFormat('yyyy-MM-dd').format(createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: Icon(Icons.warning_amber_rounded, 
          color: item['status'] == 'pending' ? Colors.orange : Colors.green),
        title: Text(item['category'] ?? "General Issue", 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("From: ${item['user_id'].toString().substring(0, 8)}... | $formattedDate"),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Message:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(item['message'] ?? "No message content"),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _updateStatus(item['id'], 'pending'),
                      child: const Text("Set Pending", style: TextStyle(color: Colors.orange)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _updateStatus(item['id'], 'solved'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC8D8C3)),
                      child: const Text("Mark Solved", style: TextStyle(color: Color(0xFF195A64))),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}