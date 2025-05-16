import 'package:flutter/material.dart';
import '../../models/vehicle_info.dart';
import '../../services/vehicle_service.dart';
import 'view_details_vehicles_screen.dart';

class ViewVehiclesScreen extends StatefulWidget {
  final String role; // Thêm role vào constructor

  const ViewVehiclesScreen({required this.role, super.key});

  @override
  State<ViewVehiclesScreen> createState() => _ViewVehiclesScreenState();
}

class _ViewVehiclesScreenState extends State<ViewVehiclesScreen> {
  late Future<List<VehicleInfo>> _vehicles;

  @override
  void initState() {
    super.initState();
    _vehicles = VehicleService.fetchVehicles();
  }

  void _fetchVehicles() {
    setState(() {
      _vehicles = VehicleService.fetchVehicles();
    });
  }

  void _navigateToDetail(String plate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDetailScreen(
          plate: plate,
          role: widget.role, // Truyền role vào VehicleDetailScreen
        ),
      ),
    );

    if (result == true) {
      _fetchVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách phương tiện')),
      body: FutureBuilder<List<VehicleInfo>>(
        future: _vehicles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có phương tiện nào.'));
          }

          final vehicles = snapshot.data!;
          return ListView.separated(
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const Icon(Icons.two_wheeler, size: 36),
                    title: Text(
                      vehicle.plate,
                      style: const TextStyle(fontSize: 17,   fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${vehicle.name}',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400)),
                        const SizedBox(height: 4),
                        Text('${vehicle.companyName} (Tầng ${vehicle.companyFloor})',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      _navigateToDetail(vehicle.plate); 
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}