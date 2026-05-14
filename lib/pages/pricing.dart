import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart'; 

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final supabase = Supabase.instance.client;

  //  تحديث السعر بداخل قاعدة البيانات للموقع المحدد
  Future<void> _updatePrice(String id, String newPrice) async {
    try {
      await supabase.from('places').update({'price_label': newPrice}).match({'id': id}); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppData.translate("Price updated successfully")),
            backgroundColor: const Color(0xFF195A64),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppData.translate('Error updating price')}: $e"), 
            backgroundColor: Colors.red,
          ),
        );
      }
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
                AppData.translate("Pricing Management"), 
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: cardColor,
              elevation: 0,
              centerTitle: true,
            ),
            body: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('places').stream(primaryKey: ['id']),
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
                
                final places = snapshot.data!;
                if (places.isEmpty) {
                  return Center(
                    child: Text(
                      AppData.translate("No places available to price."), 
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    String rawPrice = place['price_label'] ?? 'FREE';
                    
                    // تحليل لنوع التسعيرة يعرض  تصنيف (حكومي/ثابت، بالساعة، أو مجاني)
                    String priceTypeLabel = "Hourly Rate";
                    Color typeColor = const Color(0xFF195A64);

                    if (rawPrice.toLowerCase().contains('free') || rawPrice.contains('مجاني')) {
                      priceTypeLabel = "University (FREE)";
                      typeColor = Colors.green;
                    } else if (rawPrice.contains('3.25') && !rawPrice.toLowerCase().contains('/h') && !rawPrice.contains('ساعة')) {
                      priceTypeLabel = "Fixed Rate (Gov/Hospital)";
                      typeColor = Colors.purple;
                    }

                    //تنسيق الأسعار لتطابق للغة اللي اختارها الادمن
                    String displayPrice = AppData.formatNumbers(rawPrice);

                    return Card(
                      color: cardColor, 
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFC8D8C3).withOpacity(0.4),
                          child: Icon(Icons.payments_outlined, color: textColor),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              place['name'] ?? AppData.translate('Place'), 
                              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppData.translate(priceTypeLabel),
                                style: TextStyle(color: typeColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        subtitle: Text(
                          "${AppData.translate('Current Rate')}: $displayPrice", 
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _showEditPriceDialog(place['id'], rawPrice, cardColor, textColor),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE06399).withOpacity(0.1),
                            elevation: 0,
                          ),
                          child: Text(
                            AppData.translate("Edit"), 
                            style: const TextStyle(color: Color(0xFFE06399), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
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

  void _showEditPriceDialog(String id, String currentPrice, Color cardColor, Color textColor) {
    final TextEditingController controller = TextEditingController(text: currentPrice);
    
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
                title: Text(AppData.translate("Update Policy & Rate"), style: TextStyle(color: textColor)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppData.translate("Quick Templates:"),
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // الادمن يقدر يخار منهم
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTemplateButton(controller, "3.25 SAR", "Fixed (Gov)"),
                          _buildTemplateButton(controller, "3.25 SAR/h", "Hourly"),
                          _buildTemplateButton(controller, "FREE", "University"),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: controller,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: AppData.translate("e.g. 3.25 SAR/h or 3.25 SAR Fixed"),
                          hintStyle: const TextStyle(color: Colors.grey),
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), 
                    child: Text(AppData.translate("Cancel"), style: const TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updatePrice(id, controller.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)),
                    child: Text(AppData.translate("Save"), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTemplateButton(TextEditingController controller, String val, String label) {
    return InkWell(
      onTap: () {
        controller.text = val;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF195A64).withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          AppData.translate(label),
          style: const TextStyle(color: Color(0xFF195A64), fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}