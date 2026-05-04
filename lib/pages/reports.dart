import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart'; // تأكدي من المسار الصحيح

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    // تعريف الألوان بناءً على الدارك مود
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("System Analytics", 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quick Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            
            // القسم الأول: بطاقات الملخص الحية
            _buildLiveStatCards(supabase, textColor, cardColor),

            const SizedBox(height: 35),

            // القسم الثاني: تحليلات الإشغال اللحظية
            Text("Live Occupancy Rate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            _buildOccupancySection(supabase, cardColor, textColor),
          ],
        ),
      ),
    );
  }

  // ويجيت لجلب أعداد البيانات حية من جداول مختلفة
  Widget _buildLiveStatCards(SupabaseClient supabase, Color textColor, Color cardColor) {
    return Column(
      children: [
        Row(
          children: [
            // جلب عدد المواقف
            _buildFutureStatCard(supabase.from('parking_spots').count(), "Total Spots", const Color(0xFFC8D8C3), textColor, cardColor),
            const SizedBox(width: 15),
            // جلب عدد المستخدمين
            _buildFutureStatCard(supabase.from('profiles').count(), "Active Users", const Color(0xFFC8ACBB), textColor, cardColor),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            // جلب عدد الأماكن
            _buildFutureStatCard(supabase.from('places').count(), "Places", const Color(0xFFE06399), textColor, cardColor),
            const SizedBox(width: 15),
            // جلب عدد الشكاوى (بافتراض وجود جدول complaints)
            _buildFutureStatCard(supabase.from('complaints').count(), "Complaints", Colors.orange.shade200, textColor, cardColor),
          ],
        ),
      ],
    );
  }

  // ويجيت مساعد لجلب العدد من سوبابيس
  Widget _buildFutureStatCard(PostgrestFilterBuilder query, String title, Color accentColor, Color textColor, Color cardColor) {
    return Expanded(
      child: FutureBuilder(
        future: query,
        builder: (context, snapshot) {
          String value = "0";
          if (snapshot.hasData) {
            value = snapshot.data.toString();
          }
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppData.isDarkMode ? accentColor.withOpacity(0.1) : accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: accentColor.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.7))),
                const SizedBox(height: 10),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          );
        },
      ),
    );
  }
 // ويجيت حساب نسبة الإشغال حية (Stream)
  Widget _buildOccupancySection(SupabaseClient supabase, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('parking_spots').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LinearProgressIndicator();
          
          final total = snapshot.data!.length;
          if (total == 0) return const Center(child: Text("No spots found"));

          final occupied = snapshot.data!.where((s) => s['status'] == 'occupied' || s['status'] == 'reserved').length;
          final available = total - occupied;
          final occupancyPercent = (occupied / total * 100).toStringAsFixed(1);

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Real-time Availability", style: TextStyle(color: textColor)),
                  Text("$occupancyPercent% Occupied", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: occupied / total,
                  minHeight: 12,
                  backgroundColor: AppData.isDarkMode ? Colors.white10 : const Color(0xFFF0F0F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE06399)),
                ),
              ),
              const SizedBox(height: 10),
              Text("$available spots currently free out of $total", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          );
        },
      ),
    );
  }
}