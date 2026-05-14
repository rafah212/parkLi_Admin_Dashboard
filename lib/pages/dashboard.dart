import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart'; 
import '../app_data.dart'; 
import 'users.dart'; 
import 'violations.dart'; 
import 'complations.dart'; 
import 'places.dart';
import 'parking_spots.dart';
import 'pricing.dart';
import 'reservations.dart';
import 'reports.dart';
import 'setting.dart';
import 'notifications.dart';

class DashboardPage extends StatefulWidget {
  final String adminName;
  const DashboardPage({super.key, required this.adminName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _activeRoute = 'Dashboard';
  final Color primaryBlue = const Color(0xFF195A64);
  final supabase = Supabase.instance.client;

  late final MapController _mapController;
  LatLng? _adminLatLng;
  bool _isLoadingLocation = true;
  static const LatLng _defaultLocation = LatLng(26.0827, 43.9750); 

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getAdminLocation(); 
  }

  Future<void> _getAdminLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _adminLatLng = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_adminLatLng != null && mounted) {
          _mapController.move(_adminLatLng!, 13);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    Color sidebarColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);
    

    // اللي قلب الاتجاه على حسب اللغه المختاره
    return ValueListenableBuilder<bool>(
      valueListenable: AppData.languageNotifier,
      builder: (context, isArabic, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bgColor,
            body: Row(
              children: [
                _buildSidebar(sidebarColor, textColor),
                Expanded(child: _buildCurrentPage()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPage() {
    switch (_activeRoute) {
      case 'Users': return const UsersPage();
      case 'Violations': return const ViolationsPage();
      case 'Complations': return const ComplaintsPage();
      case 'Places': return const PlacesPage();
      case 'Parking Spots': return const ParkingSpotsPage();  
      case 'Pricing': return const PricingPage();
      case 'Reservations': return const ReservationsPage();
      case 'Reports': return const ReportsPage();
      case 'Notifications': return const NotificationsPage();
      case 'Setting': return const SettingsPage();
      default: return _buildMainDashboard();
    }
  }

  Widget _buildSidebar(Color sidebarColor, Color textColor) {
    return Container(
      width: 240,
      color: sidebarColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_parking_rounded, color: primaryBlue, size: 32),
                const SizedBox(width: 8),
                Text("ParkLi", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
            const SizedBox(height: 40),
            _sidebarItem(Icons.dashboard_outlined, "Dashboard", textColor),
            _sidebarItem(Icons.location_on_outlined, "Parking Spots", textColor),
            _sidebarItem(Icons.people_outline, "Users", textColor),
            _sidebarItem(Icons.layers_outlined, "Places", textColor),
            _sidebarItem(Icons.monetization_on_outlined, "Pricing", textColor),
            _sidebarItem(Icons.event_available_outlined, "Reservations", textColor),
            _sidebarItem(Icons.assessment_outlined, "Reports", textColor),
            _sidebarItem(Icons.gavel_outlined, "Violations", textColor),
            _sidebarItem(Icons.chat_bubble_outline, "Complations", textColor),
            _sidebarItem(Icons.notification_important_outlined, "Notifications", textColor),
            _sidebarItem(Icons.settings_outlined, "Setting", textColor),
            const SizedBox(height: 40),
            _sidebarItem(Icons.logout, "Logout", Colors.red),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, Color defaultTextColor) {
    bool isSelected = _activeRoute == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? primaryBlue : Colors.grey, size: 22),
      title: Text(
        AppData.translate(title), // ترجمة القائمة الجانبية من app_data
        style: TextStyle(
          color: isSelected ? primaryBlue : defaultTextColor, 
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
          fontSize: 14,
        ),
      ),
      onTap: () async {
        if (title == "Logout") {
          await supabase.auth.signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/loginadmin', (route) => false);
          }
        } else {
          setState(() => _activeRoute = title);
        }
      },
    );
  }

  Widget _buildMainDashboard() {
    Color textColor = AppData.isDarkMode ? Colors.white : Colors.black;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${AppData.translate('Welcome')}, ${widget.adminName}", // ترحيب الي على حسب الادمن اللي دخل مترجم
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 24),
          _buildStatCards(),
          const SizedBox(height: 24),
          _buildMapSection(),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return FutureBuilder<List<int>>(
      future: Future.wait([
        supabase.from('profiles').select('*').count(CountOption.exact).then((res) => res.count ?? 0),
        supabase.from('complaints').select('*').count(CountOption.exact).then((res) => res.count ?? 0),
        supabase.from('violations').select('*').count(CountOption.exact).then((res) => res.count ?? 0),
        supabase.from('bookings').select('*').count(CountOption.exact).then((res) => res.count ?? 0),
      ]),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               _StatCard(title: AppData.translate("Loading..."), value: "-"),
               _StatCard(title: AppData.translate("Loading..."), value: "-"),
               _StatCard(title: AppData.translate("Loading..."), value: "-"),
               _StatCard(title: AppData.translate("Loading..."), value: "-"),
             ],
           );
        }

        // تنسيق الأرقام للعربي (١، ٢، ٣) مع تبديل لغة اللوحة
        String users = snapshot.hasData ? AppData.formatNumbers(snapshot.data![0].toString()) : AppData.formatNumbers("0");
        String complaints = snapshot.hasData ? AppData.formatNumbers(snapshot.data![1].toString()) : AppData.formatNumbers("0");
        String violations = snapshot.hasData ? AppData.formatNumbers(snapshot.data![2].toString()) : AppData.formatNumbers("0");
        String bookings = snapshot.hasData ? AppData.formatNumbers(snapshot.data![3].toString()) : AppData.formatNumbers("0");

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatCard(title: AppData.translate("Total Users"), value: users),
            _StatCard(title: AppData.translate("Complaints"), value: complaints),
            _StatCard(title: AppData.translate("Violations"), value: violations),
            _StatCard(title: AppData.translate("Total Bookings"), value: bookings),
          ],
        );
      },
    );
  }

  Widget _buildMapSection() {
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    LatLng currentCenter = _adminLatLng ?? _defaultLocation;

    return Container(
      height: 500, 
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            StreamBuilder(
              stream: supabase.from('places').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                List<Marker> markers = [];

                if (snapshot.hasData) {
                  for (var place in snapshot.data!) {
                    if (place['lat'] != null && place['lng'] != null) {
                      markers.add(
                        Marker(
                          point: LatLng(place['lat'], place['lng']),
                          width: 52,
                          height: 52,
                          child: Tooltip(
                            message: place['name'] ?? '',
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryBlue, width: 2),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3)),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/parkli_logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      color: const Color(0xFFEAF4F5),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.local_parking_rounded,
                                        color: primaryBlue,
                                        size: 24,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }
                }

                if (_adminLatLng != null) {
                  markers.add(
                    Marker(
                      point: _adminLatLng!,
                      width: 42,
                      height: 42,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F80ED),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentCenter, 
                    initialZoom: _adminLatLng != null ? 14 : 12,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.parkliapp',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
            ),
            
            Positioned(
              right: AppData.isArabic ? null : 14,
              left: AppData.isArabic ? 14 : null,
              bottom: 14,
              child: FloatingActionButton.small(
                heroTag: 'admin_location_btn',
                backgroundColor: Colors.white,
                onPressed: _getAdminLocation,
                child: Icon(
                  Icons.my_location,
                  color: primaryBlue,
                ),
              ),
            ),
            
            if (_isLoadingLocation)
              Positioned(
                top: 14,
                right: AppData.isArabic ? null : 14,
                left: AppData.isArabic ? 14 : null,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return Container(
      width: MediaQuery.of(context).size.width * 0.18,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 6),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}