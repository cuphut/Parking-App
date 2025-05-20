import 'dart:convert';
import 'package:http/http.dart' as http;

class ParkingService {
  static const String _baseUrl = 'http://192.168.100.145:8001';

  // Lấy danh sách bãi đỗ
  Future<List<dynamic>> getParking() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/parking-lot/no-exit-time'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData as List<dynamic>;
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bãi đỗ: $e');
    }
  }

  Future<List<dynamic>> getAllParking() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/parking-lot/'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData as List<dynamic>;
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bãi đỗ: $e');
    }
  }
}
