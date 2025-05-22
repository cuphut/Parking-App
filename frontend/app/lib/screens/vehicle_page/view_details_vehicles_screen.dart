import 'package:flutter/material.dart';
import '../../models/vehicle_info.dart';
import '../../services/vehicle_service.dart';
import 'edit_vehicle_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String plate;
  final bool role;

  const VehicleDetailScreen({
    required this.plate,
    required this.role,
    super.key,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late Future<VehicleInfo> _vehicleDetail;
  bool _isDeleting = false; // Added for delete loading state

  String formatLicensePlate(String plate) {
    if (plate.length < 7) return plate;
    String part1 = plate.substring(0, 2);
    String part2 = plate.substring(2, 4);
    String part3 = plate.substring(4);
    return '$part1-$part2 $part3';
  }

  @override
  void initState() {
    super.initState();
    _vehicleDetail = VehicleService.fetchVehicleByPlate(widget.plate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết phương tiện',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: FutureBuilder<VehicleInfo>(
          future: _vehicleDetail,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'Không tìm thấy thông tin phương tiện.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final vehicle = snapshot.data!;
            final baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
            final imageName = '${vehicle.licensePlate}.jpg';
            final imageUrl = '$baseUrl/uploads/vehicles/$imageName';

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Preview
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[400]!),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 70,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 32, thickness: 1),
                      // Vehicle Info
                      _buildInfoRow(
                        icon: Icons.two_wheeler,
                        label: 'Biển số xe',
                        value: formatLicensePlate(vehicle.licensePlate),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.person,
                        label: 'Tên chủ xe',
                        value: vehicle.ownerName,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.business,
                        label: 'Công ty',
                        value: vehicle.company,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.apartment,
                        label: 'Số tầng',
                        value: vehicle.floor_number.toString(),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.phone,
                        label: 'Số điện thoại',
                        value: vehicle.phoneNumber,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton:
          widget.role
              ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'editBtn',
                    onPressed: _handleEdit,
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit, semanticLabel: 'Chỉnh sửa'),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    heroTag: 'deleteBtn',
                    onPressed: _isDeleting ? null : _handleDelete,
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        _isDeleting
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.delete, semanticLabel: 'Xoá'),
                  ),
                ],
              )
              : null,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24, semanticLabel: label),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            elevation: 4,
            title: Row(
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 28,
                  semanticLabel: 'Cảnh báo',
                ),
                const SizedBox(width: 8),
                const Text(
                  'Xác nhận xoá',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Bạn có chắc chắn muốn xoá phương tiện này? Hành động này không thể hoàn tác.',
              style: TextStyle(
                fontSize: 16,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Xoá',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        _isDeleting = true;
      });
      try {
        await VehicleService.deleteVehicleByPlate(widget.plate);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_forever, color: Colors.white, size: 24),
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

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 24),
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
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: _handleDelete,
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
        }
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
