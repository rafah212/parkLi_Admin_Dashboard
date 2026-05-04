import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart'; // استدعاء ملف AppData للثيم

class ParkingSpotsPage extends StatefulWidget {
  const ParkingSpotsPage({super.key});

  @override
  State<ParkingSpotsPage> createState() => _ParkingSpotsPageState();
}

class _ParkingSpotsPageState extends State<ParkingSpotsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  // دالة لتحديد لون الموقف بناءً على حالته (مع مراعاة الدارك مود للألوان الفاتحة)
  Color _getStatusColor(String status) {
    switch (status) {
      case 'available': 
        return const Color(0xFFC8D8C3); 
      case 'occupied': 
        return const Color.fromARGB(255, 127, 34, 48); 
      case 'reserved': 
        return AppData.isDarkMode ? Colors.orange.shade700 : Colors.orange.shade200; 
      default: 
        return AppData.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    // تعريف ألوان الصفحة بناءً على الثيم
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color appBarColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Real-time Parking Spots", 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarColor,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('parking_spots').stream(primaryKey: ['id']).order('label'),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: textColor)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final spots = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, 
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
                  // تغيير لون الحدود ليتناسب مع الخلفية الداكنة
                  border: Border.all(color: AppData.isDarkMode ? Colors.black26 : Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
                  ]
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // لون الأيقونة يتغير ليكون واضحاً في الدارك مود
                      Icon(Icons.directions_car, size: 20, color: AppData.isDarkMode ? Colors.white70 : const Color(0xFF195A64)),
                      const SizedBox(height: 4),
                      Text(
                        spot['label'] ?? '??',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 12,
                          color: AppData.isDarkMode ? Colors.white : Colors.black87
                        ),
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