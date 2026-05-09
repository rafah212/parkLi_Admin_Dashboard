import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart'; 

class ViolationsPage extends StatefulWidget {
  const ViolationsPage({super.key});

  @override
  State<ViolationsPage> createState() => _ViolationsPageState();
}

class _ViolationsPageState extends State<ViolationsPage> {
  final supabase = Supabase.instance.client;
  bool _isProcessing = false;


  Future<void> _issueViolation(String userId, String plateInfo, String type, double price) async {
    setState(() => _isProcessing = true);
    try {
    // اسجل مخالفة للي مسجل سيارته
      await supabase.from('violations').insert({
        'user_id': userId,
        'violation_type': type,
        'amount': price,
        'status': 'unpaid',
      });

      // ارسل اشعار للمستخدم
      await supabase.from('notifications').insert({
        'user_id': userId,
        'title': 'New Violation Issued ⚠️',
        'body': 'You have a new violation recorded ($type). Open "My Violations" to view details and pay.',
        'type': 'violation',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$type issued and notification sent!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Issue Violations", 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isProcessing 
        ? Center(child: CircularProgressIndicator(color: textColor))
        : StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('vehicles').stream(primaryKey: ['id']),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: textColor)));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final vehicles = snapshot.data!;
              if (vehicles.isEmpty) return Center(child: Text("No vehicles found.", style: TextStyle(color: textColor)));

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final car = vehicles[index];
                  return FutureBuilder(
                    future: supabase.from('profiles').select('full_name').eq('id', car['user_id']).single(),
                    builder: (context, userSnapshot) {
                      String ownerName = userSnapshot.hasData ? userSnapshot.data!['full_name'] : "Loading...";
                      return _buildViolationActionCard(car, ownerName, cardColor, textColor);
                    },
                  );
                },
              );
            },
          ),
    );
  }

  Widget _buildViolationActionCard(Map<String, dynamic> car, String ownerName, Color cardColor, Color textColor) {
    String plateInfo = "${car['plate_letters'] ?? ''} ${car['plate_numbers'] ?? ''}";
    
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(ownerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text("Plate: $plateInfo", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Divider(height: 25, color: textColor.withOpacity(0.1)),
            Text("Select Violation Type:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _issueViolation(car['user_id'], plateInfo, "Overtime Parking", 30),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8D8C3), 
                      foregroundColor: const Color(0xFF195A64),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Overtime (30 SAR)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _issueViolation(car['user_id'], plateInfo, "Incorrect Parking", 70),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF195A64),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Place (70 SAR)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}