import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/vehicle_info.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VehicleService {
  final baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';

  Future<bool> checkVehicleExists(String licensePlate) async {
    String cleanPlate = licensePlate.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final response = await http.get(
      Uri.parse('$baseUrl/registered_vehicle/$cleanPlate'),
    );

    if (response.statusCode == 200) {
      // Biển số tồn tại
      return true;
    } else if (response.statusCode == 404) {
      // Biển số không tồn tại
      return false;
    } else {
      throw Exception('Lỗi kiểm tra biển số: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addVehicle(
    VehicleInfo vehicle,
    File imageFile,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/registered_vehicle/'),
    );

    request.fields['license_plate'] = vehicle.licensePlate;
    request.fields['owner_name'] = vehicle.ownerName;
    request.fields['company'] = vehicle.company;
    request.fields['floor_number'] = vehicle.floor_number.toString();
    request.fields['phone_number'] = vehicle.phoneNumber;

    final imageStream = http.ByteStream(imageFile.openRead());
    final imageLength = await imageFile.length();
    final multipartFile = http.MultipartFile(
      'image',
      imageStream,
      imageLength,
      filename: path.basename(imageFile.path),
    );
    request.files.add(multipartFile);

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(responseBody);
    } else {
      throw Exception(
        jsonDecode(responseBody)['detail'] ?? 'Lỗi thêm phương tiện',
      );
    }
  }

  Future<Map<String, dynamic>> uploadExcelFile(File file) async {
    final uri = Uri.parse('$baseUrl/registered_vehicle/import_excel');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw jsonDecode(responseBody)['detail'] ?? 'Lỗi không xác định';
    }
  }

  static Future<List<VehicleInfo>> fetchVehicles() async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
    final response = await http.get(
      Uri.parse('$baseUrl/registered_vehicle/vehicles'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> vehiclesJson = jsonDecode(response.body);
      return vehiclesJson.map((json) => VehicleInfo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  static Future<VehicleInfo> fetchVehicleByPlate(String plate) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
    final response = await http.get(
      Uri.parse('$baseUrl/registered_vehicle/$plate'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return VehicleInfo.fromJson(data);
    } else {
      throw Exception('Không tìm thấy phương tiện với biển số $plate');
    }
  }

  static Future<void> deleteVehicleByPlate(String plate) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
    final url = Uri.parse('$baseUrl/registered_vehicle/$plate');

    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Xoá thất bại: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateVehicle(VehicleInfo vehicle) async {
    final url = Uri.parse(
      '$baseUrl/registered_vehicle/${vehicle.licensePlate}',
    );
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
