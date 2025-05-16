import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_info.dart';

class VehicleService {
  static const String baseUrl = 'http://192.168.100.145:8000';

  Future<bool> checkVehicleExists(String plate) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vehicles/$plate'));
      if (response.statusCode == 200) {
        // Nếu tìm thấy phương tiện với biển số, trả về true
        return true;
      } else if (response.statusCode == 404) {
        // Nếu không tìm thấy (404), trả về false
        return false;
      } else {
        throw Exception('Lỗi khi kiểm tra biển số: ${response.statusCode}');
      }
    } catch (e) {
      // Nếu có lỗi (ví dụ: không kết nối được server), ném ngoại lệ
      throw Exception('Không thể kiểm tra biển số: $e');
    }
  }
  
  Future<Map<String, dynamic>> addVehicle(VehicleInfo vehicle) async {
    final url = Uri.parse('$baseUrl/vehicles/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle.toJson()),
      );

      if (response.statusCode == 200) {
        // Thay đổi decode UTF-8 ở đây
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Lỗi: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Thêm phương tiện thất bại: $e');
    }
  }
  
  static Future<List<VehicleInfo>> fetchVehicles() async {
    final response = await http.get(Uri.parse('$baseUrl/vehicles/'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> vehiclesJson = jsonData['vehicles'];
      return vehiclesJson.map((json) => VehicleInfo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

   static Future<VehicleInfo> fetchVehicleByPlate(String plate) async {
    final response = await http.get(Uri.parse('$baseUrl/vehicles/$plate'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return VehicleInfo.fromJson(data);
    } else {
      throw Exception('Không tìm thấy phương tiện với biển số $plate');
    }
  }
  
   static Future<void> deleteVehicleByPlate(String plate) async {
    final url = Uri.parse('$baseUrl/vehicles/$plate');

    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Xoá thất bại: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateVehicle(VehicleInfo vehicle) async {
    final url = Uri.parse('$baseUrl/vehicles/${vehicle.plate}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vehicle.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Không thể cập nhật phương tiện.');
    }
  }
}
