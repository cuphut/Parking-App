import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class DetectService {
  static const String _baseUrl = 'http://192.168.100.145:8000';

  Future<String?> uploadImage(File image) async {
    try {
      String mimeType = image.path.endsWith('.png') ? 'png' : 'jpeg';
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload-image'));
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