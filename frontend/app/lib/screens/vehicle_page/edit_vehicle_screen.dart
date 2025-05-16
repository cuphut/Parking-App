import 'package:flutter/material.dart';
import '../../models/vehicle_info.dart';
import '../../services/vehicle_service.dart';

class EditVehicleScreen extends StatefulWidget {
  final String plate;

  const EditVehicleScreen({required this.plate, super.key});

  @override
  _EditVehicleScreenState createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyFloorController = TextEditingController();
  final _phoneController = TextEditingController();
  final VehicleService _vehicleService = VehicleService();

  late Future<VehicleInfo> _vehicleFuture;
  VehicleInfo? _initialVehicle; // Lưu dữ liệu ban đầu

  @override
  void initState() {
    super.initState();
    _vehicleFuture = VehicleService.fetchVehicleByPlate(widget.plate);
  }

  Future<void> _submitEdit() async {
    if (_formKey.currentState!.validate()) {
      final vehicle = VehicleInfo(
        plate: widget.plate,
        name: _nameController.text,
        companyName: _companyNameController.text,
        companyFloor: _companyFloorController.text,
        phone: _phoneController.text,
      );

      // Kiểm tra xem có thay đổi không
      if (_initialVehicle != null &&
          _initialVehicle!.name == vehicle.name &&
          _initialVehicle!.companyName == vehicle.companyName &&
          _initialVehicle!.companyFloor == vehicle.companyFloor &&
          _initialVehicle!.phone == vehicle.phone) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Không có thay đổi để lưu.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blueGrey, // Màu thông báo
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
        return; // Dừng hàm nếu không có thay đổi
      }

      try {
        final response = await _vehicleService.updateVehicle(vehicle); // Sử dụng updateVehicle thay vì addVehicle
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    response['message'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
        Navigator.pop(context);
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
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lỗi: $e',
                    style: TextStyle(
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
            duration: Duration(seconds: 3),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa phương tiện')),
      body: FutureBuilder<VehicleInfo>(
        future: _vehicleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy dữ liệu.'));
          }

          final vehicle = snapshot.data!;
          _initialVehicle = vehicle; // Lưu dữ liệu ban đầu
          _nameController.text = vehicle.name;
          _companyNameController.text = vehicle.companyName;
          _companyFloorController.text = vehicle.companyFloor;
          _phoneController.text = vehicle.phone;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    initialValue: vehicle.plate,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Biển số'),
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tên chủ xe'),
                    validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(labelText: 'Tên công ty'),
                    validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên công ty' : null,
                  ),
                  TextFormField(
                    controller: _companyFloorController,
                    decoration: const InputDecoration(labelText: 'Tầng công ty'),
                    validator: (value) => value!.isEmpty ? 'Vui lòng nhập tầng' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Số điện thoại'),
                    validator: (value) => value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitEdit,
                    child: const Text('Lưu thay đổi'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}