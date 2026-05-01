import 'package:flutter/material.dart';

void main() {
  runApp(const ParkliAdminApp());
}

class ParkliAdminApp extends StatelessWidget {
  const ParkliAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ParkLi Admin',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        fontFamily: 'Tajawal', 
      ),
      home: const AdminMainScreen(),
    );
  }
}

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. القائمة الجانبية (Sidebar)
          Container(
            width: 260,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 40, 24, 40),
                  child: Text(
                    'ParkLi',
                    style: TextStyle(color: Color(0xFF192242), fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                ),
                _sidebarItem(Icons.home_filled, 'Dashboard', isSelected: true),
                _sidebarItem(Icons.location_on_outlined, 'Sites'),
                _sidebarItem(Icons.person_outline, 'Users'),
                _sidebarItem(Icons.grid_view_rounded, 'Zones'),
                _sidebarItem(Icons.monetization_on_outlined, 'Pricing'),
                _sidebarItem(Icons.calendar_today_outlined, 'Reservations'),
                _sidebarItem(Icons.insert_chart_outlined, 'Reports'),
                _sidebarItem(Icons.warning_amber_rounded, 'Violations'),
                _sidebarItem(Icons.settings_outlined, 'Setting'),
                const Spacer(),
                _sidebarItem(Icons.logout, 'Logout'),
                _sidebarItem(Icons.chat_bubble_outline_rounded, 'Complations'),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // 2. المحتوى الرئيسي (المكان اللي كان فيه النص المؤقت)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: _buildDashboardContent(), // استدعاء الدالة اللي بنعرفها تحت
            ),
          ),
        ],
      ),
    );
  }

  // --- دالة محتوى الداش بورد (الكروت والخريطة والجداول) ---
  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Welcome, Admin',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF192242)),
            ),
            _buildSitesDropdown(),
          ],
        ),
        const SizedBox(height: 30),

        // صف الكروت الإحصائية
        Row(
          children: [
            _buildStatCard('300', 'Reservation'),
            _buildStatCard('\$400', 'Revenue'),
            _buildStatCard('5', 'Active Reservations'),
            _buildStatCard('2', 'Open Complaints', isLast: true),
          ],
        ),
        const SizedBox(height: 30),

        // منطقة الخريطة
        Container(
          width: double.infinity,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: const Center(
            child: Icon(Icons.map, size: 100, color: Colors.black12), // حطينا أيقونة بدل الصورة الحين
          ),
        ),
        const SizedBox(height: 30),

        // صف الجداول
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildViolationsTable()),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: _buildComplaintsTable()),
          ],
        ),
      ],
    );
  }

  // --- دوابل مساعدة (Helper Widgets) لتبسيط الكود ---

  Widget _buildStatCard(String value, String label, {bool isLast = false}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isLast ? 0 : 20),
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationsTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Violations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Table(
            children: [
              _tableHeader(['Reservations', 'Violation', 'Status']),
              _tableRow(['#12548796', 'No-Show', 'Open'], Colors.red),
              _tableRow(['#12548796', 'Overstay', 'Open'], Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Complaints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Table(
            children: [
              _tableHeader(['User', 'Location', 'Status']),
              _tableRow(['Norah', 'Site A', 'Pending'], Colors.orange),
              _tableRow(['Sara', 'Site B', 'Verified'], Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _tableHeader(List<String> cols) {
    return TableRow(
      children: cols.map((c) => Padding(padding: const EdgeInsets.all(8.0), child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
    );
  }

  TableRow _tableRow(List<String> cells, Color statusColor) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(cells[0])),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(cells[1])),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(cells[2], style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _sidebarItem(IconData icon, String title, {bool isSelected = false}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF4361EE) : Colors.grey),
      title: Text(title, style: TextStyle(color: isSelected ? const Color(0xFF4361EE) : Colors.grey)),
      onTap: () {},
    );
  }

  Widget _buildSitesDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
      child: Row(children: const [Text('All Sites'), Icon(Icons.arrow_drop_down)]),
    );
  }
}