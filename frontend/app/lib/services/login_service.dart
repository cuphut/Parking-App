import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginService {

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
    final url = Uri.parse('$baseUrl/api/v1/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Đăng nhập thất bại');
    }
  }
}
