import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key});

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  
  // عشان اقدر الغي قبل ينتهي الوقت
  Timer? _deleteTimer;

  Future<int> _getSpotsCount(String placeId) async {
    final response = await supabase
        .from('parking_spots')
        .select('id')
        .eq('place_id', placeId);
    return (response as List).length;
  }

  // الحذف و حطيت عد تنازلي 5 ثواني 
  void _confirmDelete(String placeId, String placeName) async {
    int spotsCount = await _getSpotsCount(placeId);
    bool isCancelled = false;

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // التراجع عن الحذف قبل الخمس ثواني
    final snackBar = SnackBar(
      content: Row(
        children: [
          const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(child: Text("Deleting '$placeName' ($spotsCount spots) in 5s...")),
        ],
      ),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: "UNDO",
        textColor: Colors.yellow,
        onPressed: () {
          isCancelled = true;
          _deleteTimer?.cancel();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    _deleteTimer = Timer(const Duration(seconds: 5), () async {
      if (!isCancelled) {
        try {
          await supabase.from('places').delete().match({'id': placeId});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Place deleted successfully")),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Manage Places", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('places').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final places = snapshot.data!;
          if (places.isEmpty) return Center(child: Text("No places found.", style: TextStyle(color: textColor)));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return Card(
                color: cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Color(0xFF195A64)),
                  title: Text(place['name'] ?? 'Unnamed', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  subtitle: Text("Price: ${place['price_label'] ?? 'N/A'}", style: const TextStyle(color: Colors.grey)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(place['id'], place['name'] ?? ""),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF195A64),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddPlaceDialog(cardColor, textColor),
      ),
    );
  }

  void _showAddPlaceDialog(Color cardColor, Color textColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text("Add New Place", style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(labelText: "Place Name", labelStyle: const TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: _priceController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(labelText: "Price (e.g. 10 SAR/h)", labelStyle: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;
              await supabase.from('places').insert({
                'name': _nameController.text,
                'price_label': _priceController.text,
                'id': _nameController.text.toLowerCase().replaceAll(' ', '_'), // توليد ID بسيط
              });
              _nameController.clear();
              _priceController.clear();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}