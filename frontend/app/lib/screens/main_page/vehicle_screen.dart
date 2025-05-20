import 'package:app/screens/parking_page/parking_list_screen.dart';
import 'package:flutter/material.dart';
import '../vehicle_page/add_vehicle_screen.dart';
import '../vehicle_page/view_vehicle_screen.dart';

class VehicleScreen extends StatelessWidget {
  final bool role;

  const VehicleScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          if (role) ...[
            ListTile(
              leading: const Icon(Icons.add, color: Colors.blue),
              title: const Text('Thêm phương tiện'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddVehicleScreen()),
                );
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.two_wheeler, color: Color.fromARGB(255, 83, 214, 88)),
            title: const Text('Xem tất cả phương tiện'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewVehiclesScreen(role: role)),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.local_parking, color: Color.fromARGB(221, 233, 216, 63)),
            title: const Text('Xem lịch sử ra vào'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ParkingListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}