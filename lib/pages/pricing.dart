import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final supabase = Supabase.instance.client;

  // دالة لتحديث السعر في سوبابيس
  Future<void> _updatePrice(String id, String newPrice) async {
    await supabase.from('places').update({'price_label': newPrice}).match({'id': id});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Price updated for $id")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Pricing Management", 
          style: TextStyle(color: Color(0xFF195A64), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('places').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final places = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFC8D8C3).withOpacity(0.4),
                    child: const Icon(Icons.payments_outlined, color: Color(0xFF195A64)),
                  ),
                  title: Text(place['name'] ?? 'Place', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Current: ${place['price_label']}"),
                  trailing: ElevatedButton(
                    onPressed: () => _showEditPriceDialog(place['id'], place['price_label']),
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

  void _showEditPriceDialog(String id, String currentPrice) {
    final TextEditingController controller = TextEditingController(text: currentPrice);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Rate"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "e.g. 5 SAR/Hour or FREE"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _updatePrice(id, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}