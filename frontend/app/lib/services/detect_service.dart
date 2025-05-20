import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DetectService {

  Future<String?> uploadImage(File image) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
      String mimeType = image.path.endsWith('.png') ? 'png' : 'jpeg';
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detech-image/'));
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          contentType: MediaType('image', mimeType),
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var jsonData = json.decode(respStr);
        return jsonEncode(jsonData["results"]);
      } else {
        return 'Lỗi server: ${response.statusCode}';
      }
    } catch (e) {
      return 'Lỗi khi gửi ảnh: $e';
    }
  }
}