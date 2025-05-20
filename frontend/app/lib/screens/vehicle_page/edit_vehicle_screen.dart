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
  bool _isLoading = false; // Added for loading state
  late Future<VehicleInfo> _vehicleFuture;
  VehicleInfo? _initialVehicle;

  @override
  void initState() {
    super.initState();
    _vehicleFuture = VehicleService.fetchVehicleByPlate(widget.plate);
  }

  Future<void> _submitEdit() async {
    if (_formKey.currentState!.validate()) {
      final vehicle = VehicleInfo(
        licensePlate: widget.plate,
        ownerName: _nameController.text,
        company: _companyNameController.text,
        floor_number: int.tryParse(_companyFloorController.text) ?? 0,
        phoneNumber: _phoneController.text,
        image: _initialVehicle?.image ?? '', // Keep existing image
      );

      if (_initialVehicle != null &&
          _initialVehicle!.ownerName == vehicle.ownerName &&
          _initialVehicle!.company == vehicle.company &&
          _initialVehicle!.floor_number == vehicle.floor_number &&
          _initialVehicle!.phoneNumber == vehicle.phoneNumber) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white, size: 24),
                const SizedBox(width: 10),
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
            backgroundColor: Colors.blueGrey,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _vehicleService.updateVehicle(vehicle);
        final message = response['message'] as String? ?? 'Cập nhật thành công';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
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
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lỗi: $e',
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
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa phương tiện',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: FutureBuilder<VehicleInfo>(
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
            _initialVehicle = vehicle; // Store initial vehicle data
            _nameController.text = vehicle.ownerName;
            _companyNameController.text = vehicle.company;
            _companyFloorController.text = vehicle.floor_number.toString();
            _phoneController.text = vehicle.phoneNumber;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // License Plate (Disabled)
                          TextFormField(
                            initialValue: vehicle.licensePlate,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Biển số',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.directions_car),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Owner Name
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Tên chủ xe',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: const Color.fromARGB(255, 245, 245, 245),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Company Name
                          TextFormField(
                            controller: _companyNameController,
                            decoration: InputDecoration(
                              labelText: 'Tên công ty',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.business),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên công ty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Company Floor
                          TextFormField(
                            controller: _companyFloorController,
                            decoration: InputDecoration(
                              labelText: 'Tầng công ty',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.stairs),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tầng';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Vui lòng nhập số hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Phone Number
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              if (!RegExp(r'^\d+$').hasMatch(value)) {
                                return 'Số điện thoại chỉ chứa các chữ số';
                              }
                              if (value.length < 10 || value.length > 11) {
                                return 'Số điện thoại phải có 10 hoặc 11 chữ số';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Image Preview (if available)
                          if (vehicle.image.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ảnh phương tiện',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    vehicle.image,
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
                                          child: Text(
                                            'Không thể tải ảnh',
                                            style: TextStyle(color: Colors.grey, fontSize: 16),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitEdit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Lưu thay đổi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _companyFloorController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}