import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html; // للتحميل
import '../app_data.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  // تحميل من قاعدة البيانات csv
  Future<void> _exportToCSV(BuildContext context, List<Map<String, dynamic>> spotsData) async {
    try {
      // الجدول والبيانات
      List<List<dynamic>> rows = [
        ["Spot ID", "Spot Name", "Zone/Place ID", "Current Status", "Last Updated"]
      ];

      for (var spot in spotsData) {
        rows.add([
          spot['id'] ?? '',
          spot['name'] ?? spot['number'] ?? '',
          spot['place_id'] ?? '',
          spot['status'] ?? 'Available',
          spot['updated_at'] ?? ''
        ]);
      }

      // تحويل المصفوفات إلى نص CSV 
      String csvContent = const JsonEncoder().convert(rows)
          .replaceAll('[', '')
          .replaceAll(']', '\n')
          .replaceAll('"', '');

      // تجهيز الرابط  وتحميل الملف على جهاز الادمن
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "ParkLi_Occupancy_Report_${DateTime.now().millisecondsSinceEpoch}.csv")
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppData.translate("CSV Report downloaded successfully!"))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error exporting CSV: $e")),
      );
    }
  }

  // ايقونة الحفظ بيصغة pdf
  void _exportToPDF(BuildContext context) {
    try {
      html.window.print(); //طبعا اللي يطلع عشان يحفظه بي دي اف هي الصفحة اللي تظهر قدامه مو البيانات اللي تحفظ البيانات بصيغة  csv
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error launching PDF printer: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          AppData.translate("System Analytics"), 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        // ازرار الحفظ لل pdb - csv
        actions: [
          //   تحميل  PDF 
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('parking_spots').stream(primaryKey: ['id']),
            builder: (context, snapshot) {
              final spots = snapshot.hasData ? snapshot.data! : <Map<String, dynamic>>[];
              return IconButton(
                icon: const Icon(Icons.insert_drive_file_outlined),
                tooltip: AppData.translate("Export PDF"),
                color: textColor,
                onPressed: () => _exportToPDF(context),
              );
            }
          ),
          //   تحميل CSV 
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('parking_spots').stream(primaryKey: ['id']),
            builder: (context, snapshot) {
              final spots = snapshot.hasData ? snapshot.data! : <Map<String, dynamic>>[];
              return IconButton(
                icon: const Icon(Icons.grid_on_outlined),
                tooltip: AppData.translate("Export CSV"),
                color: textColor,
                onPressed: spots.isEmpty ? null : () => _exportToCSV(context, spots),
              );
            }
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppData.translate("Quick Summary"), 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 20),
            
            _buildLiveStatCards(supabase, textColor, cardColor),

            const SizedBox(height: 35),

            Text(
              AppData.translate("Live Occupancy Rate"), 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 20),
            
            _buildOccupancySection(supabase, cardColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatCards(SupabaseClient supabase, Color textColor, Color cardColor) {
    return Column(
      children: [
        Row(
          children: [
            _buildStreamStatCard(supabase, 'parking_spots', "Total Spots", const Color(0xFFC8D8C3), textColor),
            const SizedBox(width: 15),
            _buildStreamStatCard(supabase, 'profiles', "Active Users", const Color(0xFFC8ACBB), textColor),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildStreamStatCard(supabase, 'places', "Total Places", const Color(0xFFE06399), textColor),
            const SizedBox(width: 15),
            _buildStreamStatCard(supabase, 'complaints', "Complaints", Colors.orange.shade200, textColor),
          ],
        ),
      ],
    );
  }

  Widget _buildStreamStatCard(SupabaseClient supabase, String table, String title, Color accentColor, Color textColor) {
    return Expanded(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from(table).stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          int count = snapshot.hasData ? snapshot.data!.length : 0;
          // تنسيق الأرقام للغة اللي مختارتها 
          String displayCount = AppData.formatNumbers(count.toString());
          
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppData.isDarkMode ? accentColor.withOpacity(0.1) : accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: accentColor.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppData.translate(title), 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.7)),
                ),
                const SizedBox(height: 10),
                Text(displayCount, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOccupancySection(SupabaseClient supabase, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('parking_spots').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppData.translate("No tracking data available")));
          }
          
          final allSpots = snapshot.data!;
          final total = allSpots.length;
          
          final occupied = allSpots.where((s) => s['status'].toString().toLowerCase() != 'available').length;
          final available = total - occupied;
          
          double percent = total > 0 ? (occupied / total) : 0.0;
          String displayPercent = AppData.formatNumbers((percent * 100).toStringAsFixed(1));

          String displayAvailable = AppData.formatNumbers(available.toString());
          String displayOccupied = AppData.formatNumbers(occupied.toString());

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppData.translate("Live Status"), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        "$displayAvailable ${AppData.translate('Free Spots')}", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                      ),
                    ],
                  ),
                  Text("$displayPercent%", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 15,
                  backgroundColor: AppData.isDarkMode ? Colors.white10 : const Color(0xFFF0F0F0),
                  valueColor: AlwaysStoppedAnimation<Color>(percent > 0.8 ? Colors.red : const Color(0xFF195A64)),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend(Colors.green, "${AppData.translate('Available')}: $displayAvailable"),
                  const SizedBox(width: 20),
                  _buildLegend(
                    percent > 0.8 ? Colors.red : const Color(0xFF195A64), 
                    "${AppData.translate('Occupied')}: $displayOccupied",
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}