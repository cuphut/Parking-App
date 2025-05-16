import 'package:flutter/material.dart';
import '../../models/vehicle_info.dart';
import '../../services/vehicle_service.dart';

class AddVehicleScreen extends StatefulWidget {
  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyFloorController = TextEditingController();
  final _phoneController = TextEditingController();
  final VehicleService _vehicleService = VehicleService();

  Future<void> _submitVehicle() async {
    if (_formKey.currentState!.validate()) {
      final vehicle = VehicleInfo(
        plate: _plateController.text,
        name: _nameController.text,
        companyName: _companyNameController.text,
        companyFloor: _companyFloorController.text,
        phone: _phoneController.text,
      );

      try {
        // Kiểm tra xem biển số đã tồn tại hay chưa
        bool vehicleExists = await _vehicleService.checkVehicleExists(vehicle.plate);
        if (vehicleExists) {
          // Nếu biển số đã tồn tại, hiển thị thông báo "Không thành công"
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Không thành công: Biển số đã tồn tại',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange, // Màu cảnh báo
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 3),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          );
          return; // Dừng hàm nếu biển số đã tồn tại
        }

        // Nếu biển số chưa tồn tại, tiếp tục thêm phương tiện
        final response = await _vehicleService.addVehicle(vehicle);
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
            backgroundColor: Colors.green, // Màu thành công
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
        Navigator.pop(context); // Quay lại màn hình trước sau khi thêm thành công
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
            backgroundColor: Colors.red, // Màu lỗi
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
      appBar: AppBar(title: Text('Thêm phương tiện')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _plateController,
                decoration: InputDecoration(labelText: 'Biển số'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập biển số' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Tên chủ xe'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(labelText: 'Tên công ty'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên công ty' : null,
              ),
              TextFormField(
                controller: _companyFloorController,
                decoration: InputDecoration(labelText: 'Tầng công ty'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tầng' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitVehicle,
                child: Text('Thêm phương tiện'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}