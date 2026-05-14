import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart'; 

class ParkingSpotsPage extends StatefulWidget {
  const ParkingSpotsPage({super.key});

  @override
  State<ParkingSpotsPage> createState() => _ParkingSpotsPageState();
}

class _ParkingSpotsPageState extends State<ParkingSpotsPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  String? _selectedPlaceId; // لتخزين معرف الموقع المختار
  List<Map<String, dynamic>> _placesList = []; // لتخزين قائمة المواقع حياً

  @override
  void initState() {
    super.initState();
    _fetchPlaces(); // جلب المواقع أول ما تفتح الصفحة لتغذية الـ Dropdown
  }

  // دالة ذكية لسحب المواقع المتاحة في النظام
  Future<void> _fetchPlaces() async {
    try {
      final data = await supabase.from('places').select('id, name');
      if (data != null && data.isNotEmpty) {
        setState(() {
          _placesList = List<Map<String, dynamic>>.from(data);
          _selectedPlaceId = _placesList.first['id'].toString(); // اختيار أول موقع تلقائياً
        });
      }
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  // دالة تحديد ألوان حالات المواقف بناءً على البليتة المعتمدة
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available': 
        return const Color(0xFFC8D8C3); // الأخضر الفاتح المتاح
      case 'occupied': 
        return const Color.fromARGB(255, 127, 34, 48); // البرغندي/العنابي للممتلئ
      case 'reserved': 
        return AppData.isDarkMode ? Colors.orange.shade700 : Colors.orange.shade200; // البرتقالي للمحجوز
      default: 
        return AppData.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return ValueListenableBuilder<bool>(
      valueListenable: AppData.languageNotifier,
      builder: (context, isArabic, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: Text(
                AppData.translate("Real-time Parking Spots"), 
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: cardColor,
              elevation: 0,
              centerTitle: true,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏢 شريط علوي أنيق لاختيار الموقع وتصفية المواقف بناءً عليه
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
                      ],
                      border: Border.all(color: textColor.withOpacity(0.1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPlaceId,
                        dropdownColor: cardColor,
                        isExpanded: true,
                        icon: Icon(Icons.business_rounded, color: textColor),
                        hint: Text(
                          AppData.translate("Select Parking Location"),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                        items: _placesList.map((place) {
                          return DropdownMenuItem<String>(
                            value: place['id'].toString(),
                            child: Text(place['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPlaceId = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                // 🚗 شبكة عرض المواقف التابعة للموقع المختار حياً
                Expanded(
                  child: _selectedPlaceId == null
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder<List<Map<String, dynamic>>>(
                          // الاستعلام الذكي: نجلب المواقف اللي تطابق الـ place_id المختار بس!
                          stream: supabase
                              .from('parking_spots')
                              .stream(primaryKey: ['id'])
                              .eq('place_id', _selectedPlaceId!)
                              .order('label'),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "${AppData.translate('Error')}: ${snapshot.error}", 
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }
                            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                            final spots = snapshot.data!;

                            if (spots.isEmpty) {
                              return Center(
                                child: Text(
                                  AppData.translate("No parking spots assigned to this location."),
                                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              );
                            }

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
                                String spotLabel = AppData.formatNumbers(spot['label'] ?? '??');

                                return Container(
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(spot['status'] ?? ''),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppData.isDarkMode ? Colors.black26 : Colors.white, 
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.directions_car, 
                                          size: 20, 
                                          color: AppData.isDarkMode ? Colors.white70 : const Color(0xFF195A64),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          spotLabel,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 12,
                                            color: AppData.isDarkMode ? Colors.white : Colors.black87,
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}