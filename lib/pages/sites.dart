import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SitesPage extends StatefulWidget {
  const SitesPage({super.key});

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  // دالة إضافة مكان جديد لقاعدة البيانات
  Future<void> _addNewSite() async {
    await supabase.from('sites').insert({
      'name': _nameController.text,
      'price_label': _priceController.text,
      'category': _categoryController.text,
      // يمكنك إضافة حقول الإحداثيات هنا أيضاً
    });
    _nameController.clear();
    _priceController.clear();
    _categoryController.clear();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Manage Sites", style: TextStyle(color: Color(0xFF195A64), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('sites').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final sites = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: sites.length,
            itemBuilder: (context, index) {
              final site = sites[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.location_city, color: Color(0xFF195A64)),
                  title: Text(site['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Price: ${site['price_label']} | Category: ${site['category']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async => await supabase.from('sites').delete().match({'id': site['id']}),
                  ),
                ),
              );
            },
          );
        },
      ),
      // زر الإضافة العائم
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF195A64),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddSiteDialog(),
      ),
    );
  }

  // واجهة إدخال بيانات المكان الجديد
  void _showAddSiteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Site"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Site Name")),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Price (e.g. 5 SAR/h)")),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: "Category")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: _addNewSite,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)),
            child: const Text("Add Site"),
          ),
        ],
      ),
    );
  }
}