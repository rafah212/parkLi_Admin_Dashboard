import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../app_data.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  // دالة الإلغاء التي سيراقبها تطبيق المستخدم
  Future<void> _cancelBooking(String bookingId) async {
    try {
      // تحديث الحالة إلى 'cancelled' ليراها الـ Stream في تطبيق المستخدم
      await supabase.from('bookings').update({'status': 'cancelled'}).eq('id', bookingId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إلغاء الحجز وإرسال التنبيه للمستخدم"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error cancelling: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Reservations Management", 
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
            Text("All Bookings History", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('bookings').stream(primaryKey: ['id']).order('booked_at'),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: textColor)));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final bookings = snapshot.data!;
                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return FutureBuilder(
                        // جلب تفاصيل المستخدم والمركبة ديناميكياً لكل حجز
                        future: supabase.from('profiles').select('full_name, car_model').eq('id', booking['user_id']).single(),
                        builder: (context, userSnapshot) {
                          String userName = "جاري التحميل...";
                          String vehicle = "لا يوجد بيانات";
                          if (userSnapshot.hasData) {
                            userName = userSnapshot.data!['full_name'] ?? "مستخدم غير معروف";
                            vehicle = userSnapshot.data!['car_model'] ?? "بدون مركبة";
                          }
                          return _buildBookingCard(booking, userName, vehicle, cardColor, textColor);
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

  Widget _buildBookingCard(Map<String, dynamic> booking, String userName, String vehicle, Color cardColor, Color textColor) {
    DateTime bookedAt = DateTime.parse(booking['booked_at']);
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(bookedAt);
    
    String status = (booking['status'] ?? 'pending').toLowerCase();
    
    // تحديد لون الحالة بناءً على النص
    Color statusColor;
    if (status == 'upcoming') {
      statusColor = Colors.blue;
    } else if (status == 'completed') {
      statusColor = Colors.green;
    } else if (status == 'cancelled') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: statusColor, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.directions_car_filled, color: statusColor),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Spot: ${booking['spot_label'] ?? 'N/A'}", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            
            // يظهر زر الإلغاء فقط إذا كان الحجز قائماً (Upcoming)
            if (status == 'upcoming')
              ElevatedButton.icon(
                onPressed: () => _cancelBooking(booking['id']),
                icon: const Icon(Icons.cancel_outlined, size: 14, color: Colors.white),
                label: const Text("إلغاء", style: TextStyle(fontSize: 11, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("User: $userName", style: TextStyle(color: textColor.withOpacity(0.8), fontWeight: FontWeight.w600)),
              Text("Vehicle: $vehicle", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}