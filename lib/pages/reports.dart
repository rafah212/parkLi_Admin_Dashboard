import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("System Analytics", 
          style: TextStyle(color: Color(0xFF195A64), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Quick Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // القسم الأول: بطاقات الملخص
            Row(
              children: [
                _buildStatCard("Total Spots", "1026", const Color(0xFFC8D8C3)),
                const SizedBox(width: 15),
                _buildStatCard("Active Users", "6", const Color(0xFFC8ACBB)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildStatCard("Places", "12", const Color(0xFFE06399)),
                const SizedBox(width: 15),
                _buildStatCard("Complaints", "0", Colors.orange.shade200),
              ],
            ),

            const SizedBox(height: 35),

            // القسم الثاني: تحليلات حية من سوبابيس
            const Text("Live Occupancy Rate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('parking_spots').stream(primaryKey: ['id']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  
                  final total = snapshot.data!.length;
                  final available = snapshot.data!.where((s) => s['status'] == 'available').length;
                  final occupancyPercent = ((total - available) / total * 100).toStringAsFixed(1);

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Real-time Availability"),
                          Text("$occupancyPercent% Occupied", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (total - available) / total,
                          minHeight: 12,
                          backgroundColor: const Color(0xFFF0F0F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE06399)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("$available spots currently free out of $total", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF195A64))),
          ],
        ),
      ),
    );
  }
}