import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart'; //

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final supabase = Supabase.instance.client;

  // دالة لتحديث السعر في سوبابيس
  Future<void> _updatePrice(String id, String newPrice) async {
    try {
      await supabase.from('places').update({'price_label': newPrice}).match({'id': id}); //
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Price updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating price: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // تعريف الألوان بناءً على حالة الدارك مود
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Pricing Management", 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // الربط مع نفس جدول الأماكن ليتم التحديث فورياً عند الإضافة أو الحذف
        stream: supabase.from('places').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: textColor)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final places = snapshot.data!;
          if (places.isEmpty) return Center(child: Text("No places available to price.", style: TextStyle(color: textColor)));

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return Card(
                color: cardColor, //
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFC8D8C3).withOpacity(0.4),
                    child: Icon(Icons.payments_outlined, color: textColor),
                  ),
                  title: Text(place['name'] ?? 'Place', 
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  subtitle: Text("Current: ${place['price_label']}", 
                    style: const TextStyle(color: Colors.grey)),
                  trailing: ElevatedButton(
                    onPressed: () => _showEditPriceDialog(place['id'], place['price_label'] ?? '', cardColor, textColor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE06399).withOpacity(0.1),
                      elevation: 0,
                    ),
                    child: const Text("Edit", style: TextStyle(color: Color(0xFFE06399))),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditPriceDialog(String id, String currentPrice, Color cardColor, Color textColor) {
    final TextEditingController controller = TextEditingController(text: currentPrice);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor, //
        title: Text("Update Rate", style: TextStyle(color: textColor)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: textColor),
          decoration: const InputDecoration(
            hintText: "e.g. 5 SAR/Hour or FREE",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _updatePrice(id, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}