import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart'; 

class ViolationsPage extends StatefulWidget {
  const ViolationsPage({super.key});

  @override
  State<ViolationsPage> createState() => _ViolationsPageState();
}

class _ViolationsPageState extends State<ViolationsPage> {
  final supabase = Supabase.instance.client;
  bool _isProcessing = false;

  // دالة إصدار المخالفات وحفظها وإخطار جوال المستخدم بالمفتاح المشفر المترجم تلقائياً
  Future<void> _issueViolation(String userId, String plateInfo, String type, double price) async {
    setState(() => _isProcessing = true);
    try {
      // 1. تسجيل المخالفة بالقيم الجديدة النشطة في قاعدة البيانات
      await supabase.from('violations').insert({
        'user_id': userId,
        'violation_type': type,
        'amount': price,
        'status': 'unpaid',
      });

      // 2. إرسال المفتاح الكودي المتكامل ليتعرف عليه الجوال ويترجمه بلغة صاحب الجوال حياً
      await supabase.from('notifications').insert({
        'user_id': userId,
        'title': 'violation_issued', // المفتاح الكودي المتزامن
        'body': 'You have a new violation recorded ($type).', 
        'type': 'violation',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppData.translate(type)} ${AppData.translate('issued and notification sent!')}"), 
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppData.translate('Error')}: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
                AppData.translate("Issue Violations"), 
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: cardColor,
              elevation: 0,
              centerTitle: true,
            ),
            body: _isProcessing 
                ? Center(child: CircularProgressIndicator(color: textColor))
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: supabase.from('vehicles').stream(primaryKey: ['id']),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Center(child: Text("${AppData.translate('Error')}: ${snapshot.error}", style: TextStyle(color: textColor)));
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      
                      final vehicles = snapshot.data!;
                      if (vehicles.isEmpty) {
                        return Center(
                          child: Text(
                            AppData.translate("No vehicles found."), 
                            style: TextStyle(color: textColor),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) {
                          final car = vehicles[index];
                          return FutureBuilder(
                            future: supabase.from('profiles').select('full_name').eq('id', car['user_id']).maybeSingle(),
                            builder: (context, userSnapshot) {
                              String ownerName = userSnapshot.hasData && userSnapshot.data != null 
                                  ? userSnapshot.data!['full_name'] 
                                  : AppData.translate("Loading...");
                              return _buildViolationActionCard(car, ownerName, cardColor, textColor);
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildViolationActionCard(Map<String, dynamic> car, String ownerName, Color cardColor, Color textColor) {
    String plateInfo = "${car['plate_letters'] ?? ''} ${car['plate_numbers'] ?? ''}";
    String displayPlate = AppData.formatNumbers(plateInfo);
    
    // قيم وعروض الأزرار المحدثة حياً بالعملة الوطنية والأرقام المتزامنة
    String fixedPriceLabel = AppData.formatNumbers("15");

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(ownerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text("${AppData.translate('Plate')}: $displayPlate", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Divider(height: 25, color: textColor.withOpacity(0.1)),
            Text(AppData.translate("Select Violation Type:"), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
            const SizedBox(height: 12),
            Row(
              children: [
                // 1. زر حساب مخالفة الوقت الإضافي تصاعدياً بطلب إدخال الساعات يدوياً
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showOvertimeCalculationDialog(car['user_id'], plateInfo, cardColor, textColor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8D8C3), 
                      foregroundColor: const Color(0xFF195A64),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      AppData.translate("Overtime Dynamic"), 
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 2. زر تسجيل مخالفة تغيير الموقف الثابتة بقيمة 15 ريال
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _issueViolation(car['user_id'], plateInfo, "Incorrect Parking", 15),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF195A64),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      "${AppData.translate('Incorrect Parking')} ($fixedPriceLabel ${AppData.translate('SAR')})", 
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // نافذة تفاعلية تطلب من الأدمن عدد الساعات لحساب الحسبة التصاعدية حياً (ساعة = 5 ريال)
  void _showOvertimeCalculationDialog(String userId, String plateInfo, Color cardColor, Color textColor) {
    final TextEditingController hoursController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<bool>(
          valueListenable: AppData.languageNotifier,
          builder: (context, isArabic, child) {
            return Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                backgroundColor: cardColor,
                title: Text(AppData.translate("Calculate Overtime Penalty")),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppData.translate("Enter extra hours stayed (5 SAR per hour):"),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hoursController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: AppData.translate("e.g. 2"),
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppData.translate("Cancel"), style: const TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      int hours = int.tryParse(hoursController.text) ?? 1;
                      double calculatedAmount = hours * 5.0; // حسبتك المعتمدة: ساعة إضافية = 5 ريال
                      Navigator.pop(context);
                      _issueViolation(userId, plateInfo, "Overtime Parking (${hours}h)", calculatedAmount);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)),
                    child: Text(AppData.translate("Issue"), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}