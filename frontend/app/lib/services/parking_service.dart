import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParkingService {
  final baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
  // Lấy danh sách bãi đỗ
  Future<List<dynamic>> getParking() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parking-lot/no-exit-time'),
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
        Uri.parse('$baseUrl/parking-lot/'),
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
