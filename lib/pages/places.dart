import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_data.dart'; // تأكدي من المسار

class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key});

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // تعريف الألوان بناءً على حالة الدارك مود
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage Places", 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('places').stream(primaryKey: ['id']), 
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}", 
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                    );
                  }
                  
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final places = snapshot.data!;
                  
                  if (places.isEmpty) {
                    return Center(child: Text("No places found. Click + to add.", style: TextStyle(color: textColor)));
                  }

                  return ListView.builder(
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
                            onPressed: () async {
                              await supabase.from('places').delete().match({'id': place['id']});
                            },
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
              decoration: InputDecoration(
                labelText: "Place Name", 
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textColor.withOpacity(0.5))),
              )
            ),
            TextField(
              controller: _priceController, 
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Price (e.g. 10 SAR/h)", 
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textColor.withOpacity(0.5))),
              )
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                return;
              }
              try {
                await supabase.from('places').insert({
                  'name': _nameController.text,
                  'price_label': _priceController.text,
                });
                
                _nameController.clear();
                _priceController.clear();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Place added successfully!")));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding place: $e")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}