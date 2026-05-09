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

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await supabase.from('bookings').update({'status': 'cancelled'}).eq('id', bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking cancelled successfully"),
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
            Text("Bookings History", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('bookings').stream(primaryKey: ['id']).order('booked_at', ascending: false),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Error loading bookings"));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final bookings = snapshot.data!;
                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      
                      return FutureBuilder(
                        future: Future.wait([
                          supabase.from('profiles').select('full_name').eq('id', booking['user_id']).maybeSingle(),
                          supabase.from('vehicles').select('car_model').eq('user_id', booking['user_id']).maybeSingle(),
                        ]),
                        builder: (context, AsyncSnapshot<List<dynamic>> multiSnapshot) {
                          String userName = "Loading...";
                          String vehicle = "Loading...";

                          if (multiSnapshot.hasData) {
                            final profileData = multiSnapshot.data![0];
                            final vehicleData = multiSnapshot.data![1];
                            
                            userName = profileData?['full_name'] ?? "Unknown User";
                            vehicle = vehicleData?['car_model'] ?? "No Vehicle Info";
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
    
    Color statusColor = status == 'upcoming' ? Colors.blue : (status == 'completed' ? Colors.green : Colors.red);
    
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Spot: ${booking['spot_label'] ?? 'N/A'}", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            if (status == 'upcoming')
              TextButton.icon(
                onPressed: () => _cancelBooking(booking['id']),
                icon: const Icon(Icons.cancel, size: 16, color: Colors.red),
                label: const Text("CANCEL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("User: $userName", style: TextStyle(color: textColor.withOpacity(0.8), fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("Vehicle: $vehicle", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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