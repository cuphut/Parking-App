import 'dart:convert';
import 'package:http/http.dart' as http;

class ParkingService {
  static const String _baseUrl = 'http://192.168.100.145:8000';

  // Lấy danh sách bãi đỗ
  Future<List<dynamic>> getAllParking() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/parking/'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['parking'] as List<dynamic>;
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bãi đỗ: $e');
    }
  }
}