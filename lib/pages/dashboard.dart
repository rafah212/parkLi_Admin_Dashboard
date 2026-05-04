import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'users.dart'; 
import 'violations.dart'; 
import 'complations.dart'; // تأكدي من تسمية الملف الصحيحة عندك
import 'sites.dart';
import 'parking_spots.dart';
import 'pricing.dart';
import 'reservations.dart';
import 'reports.dart';
import 'setting.dart';
import 'notifications.dart';

class DashboardPage extends StatefulWidget {
  final String adminName; // الترحيب المخصص
  const DashboardPage({super.key, required this.adminName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _activeRoute = 'Dashboard';
  final Color primaryBlue = const Color(0xFF195A64); // لونكم المعتمد

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // خلفية هادئة
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _buildCurrentPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_activeRoute) {
      case 'Users': return const UsersPage();
      case 'Violations': return const ViolationsPage();
      case 'Complations': return const ComplaintsPage();
      case 'Sites': return const SitesPage();
      case 'Parking Spots': return const ParkingSpotsPage();
      case 'Dashboard': return _buildMainDashboard();
      case 'Pricing': return const PricingPage();
      case 'Reservations': return const ReservationsPage();
      case 'Reports': return const ReportsPage();
      case 'Notifications': return const NotificationsPage();
      case 'Setting': return const SettingsPage();
      default:
        return _buildMainDashboard();
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_parking_rounded, color: primaryBlue, size: 32),
                const SizedBox(width: 8),
                Text("ParkLi", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue)),
              ],
            ),
            const SizedBox(height: 40),
            _sidebarItem(Icons.dashboard_outlined, "Dashboard"),
            _sidebarItem(Icons.location_on_outlined, "Parking Spots"),
            _sidebarItem(Icons.people_outline, "Users"),
            _sidebarItem(Icons.layers_outlined, "Sites"),
            _sidebarItem(Icons.monetization_on_outlined, "Pricing"),
            _sidebarItem(Icons.event_available_outlined, "Reservations"),
            _sidebarItem(Icons.assessment_outlined, "Reports"),
            _sidebarItem(Icons.gavel_outlined, "Violations"),
            _sidebarItem(Icons.settings_outlined, "Setting"),
            const SizedBox(height: 40),
            _sidebarItem(Icons.logout, "Logout"),
            _sidebarItem(Icons.chat_bubble_outline, "Complations"), 
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title) {
    bool isSelected = _activeRoute == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? primaryBlue : Colors.grey, size: 22),
      title: Text(title, style: TextStyle(color: isSelected ? primaryBlue : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
      onTap: () {
        if (title == "Logout") {
          Navigator.pushReplacementNamed(context, '/loginadmin');
        } else {
          setState(() => _activeRoute = title);
        }
      },
    );
  }

  Widget _buildMainDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الترحيب المخصص باسمك أو اسم أسيل
          Text("Welcome, ${widget.adminName}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildStatCards(), // المربعات الـ 4 الذكية
          const SizedBox(height: 24),
          _buildMapSection(), // الخريطة التفاعلية الحقيقية
          const SizedBox(height: 24),
          _buildTablesSection(), // جداول البيانات
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(26.0827, 43.9750), 
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.parkliapp',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(26.0827, 43.9750),
                  width: 45,
                  height: 45,
                  child: Icon(Icons.location_on, color: primaryBlue, size: 45), 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    final supabase = Supabase.instance.client;
    return StreamBuilder(
      stream: supabase.from('bookings').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        int total = snapshot.hasData ? snapshot.data!.length : 0;
        int active = snapshot.hasData ? snapshot.data!.where((b) => b['status'] == 'active').length : 0;
        int completed = snapshot.hasData ? snapshot.data!.where((b) => b['status'] == 'completed').length : 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatCard(title: "Active Bookings", value: "$active"),
            const _StatCard(title: "Open Complaints", value: "2"), // يمكن ربطها بجدول الشكاوى بنفس الطريقة
            _StatCard(title: "Completed", value: "$completed"),
            _StatCard(title: "Total Bookings", value: "$total"),
          ],
        );
      },
    );
  }

  Widget _buildTablesSection() {
    return Row(
      children: [
        Expanded(child: _buildSimpleTable("Live Violations")),
        const SizedBox(width: 20),
        Expanded(child: _buildSimpleTable("Recent Complaints")),
      ],
    );
  }

  Widget _buildSimpleTable(String title) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 30),
          const SizedBox(height: 120, child: Center(child: Text("Fetching live data...", style: TextStyle(color: Colors.grey)))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.18, // متوافق مع العرض
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF195A64))),
          const SizedBox(height: 6),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}