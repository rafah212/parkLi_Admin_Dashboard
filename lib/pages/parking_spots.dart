import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParkingSpotsPage extends StatefulWidget {
  const ParkingSpotsPage({super.key});

  @override
  State<ParkingSpotsPage> createState() => _ParkingSpotsPageState();
}

class _ParkingSpotsPageState extends State<ParkingSpotsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  // دالة لتحديد لون الموقف بناءً على حالته
  Color _getStatusColor(String status) {
    switch (status) {
      case 'available': return const Color(0xFFC8D8C3); // الأخضر الهادئ لـ RA
      case 'occupied': return const Color.fromARGB(255, 127, 34, 48); // الوردي لـ RA (مشغول)
      case 'reserved': return Colors.orange.shade200; // برتقالي للمحجوز
      default: return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Real-time Parking Spots", 
          style: TextStyle(color: Color(0xFF195A64), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // الربط المباشر مع جدول المواقف
        stream: supabase.from('parking_spots').stream(primaryKey: ['id']).order('label'),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final spots = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, // عدد المواقف في كل صف بالعرض
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: spots.length,
            itemBuilder: (context, index) {
              final spot = spots[index];
              return Container(
                decoration: BoxDecoration(
                  color: _getStatusColor(spot['status']),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
                  ]
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_car, size: 20, color: Color(0xFF195A64)),
                      const SizedBox(height: 4),
                      Text(
                        spot['label'] ?? '??',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}