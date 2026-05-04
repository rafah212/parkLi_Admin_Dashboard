import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViolationsPage extends StatefulWidget {
  const ViolationsPage({super.key});

  @override
  State<ViolationsPage> createState() => _ViolationsPageState();
}

class _ViolationsPageState extends State<ViolationsPage> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Registered Vehicles", 
          style: TextStyle(color: Color(0xFF195A64), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('vehicles').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final vehicles = snapshot.data!;
          
          if (vehicles.isEmpty) {
            return const Center(child: Text("No vehicles registered yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final car = vehicles[index];
              return _buildVehicleCard(car);
            },
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> car) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFC8D8C3).withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.directions_car, color: Color(0xFF195A64)),
        ),
        title: Text("${car['plate_letters']} ${car['plate_numbers']}", 
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        subtitle: Text("Type: ${car['plate_type']} | ${car['country']}"),
        trailing: car['is_saudi'] == true 
          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
          : null,
      ),
    );
  }
}