import 'package:flutter/material.dart';
import '../../models/vehicle_info.dart';
import '../../services/vehicle_service.dart';
import 'edit_vehicle_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String plate;
  final String role;

  const VehicleDetailScreen({required this.plate, required this.role, super.key});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late Future<VehicleInfo> _vehicleDetail;

  @override
  void initState() {
    super.initState();
    _vehicleDetail = VehicleService.fetchVehicleByPlate(widget.plate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết phương tiện')),
      body: FutureBuilder<VehicleInfo>(
        future: _vehicleDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Không tìm thấy thông tin phương tiện.'),
            );
          }

          final vehicle = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car,
                      size: 70,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 30),
                    const Divider(height: 32, thickness: 1),
                    _buildInfoRow(
                      Icons.two_wheeler,
                      "Biển số xe",
                      vehicle.plate,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.person, "Tên chủ xe", vehicle.name),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.business,
                      "Công ty",
                      vehicle.companyName,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.apartment,
                      "Số tầng",
                      vehicle.companyFloor.toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.phone, "Số điện thoại", vehicle.phone),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: widget.role.toLowerCase() == 'admin'
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'editBtn',
                  onPressed: _handleEdit,
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.edit),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'deleteBtn',
                  onPressed: _handleDelete,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.delete),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Text('$label: $value', style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  void _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              'Xác nhận xoá',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xoá phương tiện này? Hành động này không thể hoàn tác.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Huỷ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Xoá',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await VehicleService.deleteVehicleByPlate(widget.plate);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đã xoá phương tiện thành công.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );

        Navigator.pop(context, true); // Trở về và báo là đã xoá
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lỗi khi xoá: $e',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
      }
    }
  }

  void _handleEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditVehicleScreen(plate: widget.plate),
      ),
    );

    if (result == true) {
      setState(() {
        _vehicleDetail = VehicleService.fetchVehicleByPlate(widget.plate);
      });
    }
  }
}