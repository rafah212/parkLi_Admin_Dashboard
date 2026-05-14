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
  
  Timer? _deleteTimer;

  Future<int> _getSpotsCount(String placeId) async {
    final response = await supabase
        .from('parking_spots')
        .select('id')
        .eq('place_id', placeId);
    return (response as List).length;
  }

  // دالة الحذف مع عد تنازلي خليته 5 ثواني وتدعم اللغتين  
  void _confirmDelete(String placeId, String placeName) async {
    int spotsCount = await _getSpotsCount(placeId);
    bool isCancelled = false;

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    String displayCount = AppData.formatNumbers(spotsCount.toString());

    final snackBar = SnackBar(
      content: Row(
        children: [
          const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "${AppData.translate('Deleting')} '$placeName' ($displayCount ${AppData.translate('spots')}) ${AppData.translate('in 5s...')}"
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: AppData.translate("UNDO"),
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
              SnackBar(content: Text(AppData.translate("Place deleted successfully"))),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${AppData.translate('Error')}: $e"), backgroundColor: Colors.red),
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

    return ValueListenableBuilder<bool>(
      valueListenable: AppData.languageNotifier,
      builder: (context, isArabic, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: Text(
                AppData.translate("Manage Places"), 
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            body: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('places').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("${AppData.translate('Error')}: ${snapshot.error}"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final places = snapshot.data!;
                if (places.isEmpty) {
                  return Center(
                    child: Text(
                      AppData.translate("No places found."), 
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    
                    // الارقام على حسب اللغة اللي اخترتها
                    String displayPrice = AppData.formatNumbers(place['price_label'] ?? 'N/A');

                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: Color(0xFF195A64)),
                        title: Text(
                          place['name'] ?? AppData.translate('Unnamed'), 
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        ),
                        subtitle: Text(
                          "${AppData.translate('Price')}: $displayPrice", 
                          style: const TextStyle(color: Colors.grey),
                        ),
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
          ),
        );
      },
    );
  }

  void _showAddPlaceDialog(Color cardColor, Color textColor) {
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
                title: Text(AppData.translate("Add New Place"), style: TextStyle(color: textColor)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: AppData.translate("Place Name"), 
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      ),
                    ),
                    TextField(
                      controller: _priceController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: AppData.translate("Price (e.g. 10 SAR/h)"), 
                        labelStyle: const TextStyle(color: Colors.grey),
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
                    onPressed: () async {
                      if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;
                      await supabase.from('places').insert({
                        'name': _nameController.text,
                        'price_label': _priceController.text,
                        'id': _nameController.text.toLowerCase().replaceAll(' ', '_'),
                      });
                      _nameController.clear();
                      _priceController.clear();
                      if (mounted) Navigator.pop(context);
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
}