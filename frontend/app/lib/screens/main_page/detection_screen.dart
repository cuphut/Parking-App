import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/services/detect_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final DetectService _vehicleService = DetectService(); // Khởi tạo service

  String? _resultText;
  bool _isLoading = false;

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isLoading = true;
      _resultText = null;
    });

    try {
      File file = File(image.path);
      String? result = await _vehicleService.uploadImage(file);

      setState(() {
        _resultText = result;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : _resultText != null
                ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildResultWidget(),
                )
                : const Text('Chọn ảnh để nhận diện biển số xe'),
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: _pickAndUploadImage,
        fillColor: Colors.blueAccent,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.blueAccent),
        ),
        constraints: const BoxConstraints.tightFor(width: 70, height: 70),
        child: const Icon(Icons.camera_alt, size: 36, color: Colors.white),
      ),
    );
  }

  Widget _buildResultWidget() {
    // Parse JSON string thành List<dynamic>
    final List<dynamic> results = json.decode(_resultText!);
    
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            final plate = item['plate'] ?? '';
            final message = item['message'] ?? '';
            final valid = item['valid'] ?? false;
            final name = item['name'] ?? '';
            final companyName = item['companyName'] ?? '';
            final companyFloor = item['companyFloor'] ?? '';
            final phone = item['phone'] ?? '';

            String cleanPlate = item['plate'].replaceAll('-', '').replaceAll(' ', '');
            final operation = item['operation'] ?? 'invalid';
            final imageName = '$cleanPlate.jpg'; // hoặc theo logic của bạn
            final baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
            final imageUrl =
                '$baseUrl/uploads/vehicles/$imageName';
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color:
                  valid
                      ? Colors.green
                      : const Color.fromARGB(
                        255,
                        255,
                        90,
                        78,
                      ), // Màu nền khác nhau cho hợp lệ/không hợp lệ
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(valid) ...[
                      if(operation == 'entry') ...[
                          Text(
                          "Xe vào bãi",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                      ],
                      if(operation == 'exit') ...[
                          Text(
                          "Xe ra bãi",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                      ],
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )],
                    Text(
                      "Biển số $plate",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (message.isNotEmpty && !valid) ...[
                      const SizedBox(height: 8),
                      Text(
                        message.toLowerCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (valid) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Tên: $name",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Công ty: $companyName, Tầng: $companyFloor",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "SĐT: $phone",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            "Nếu kết quả không đúng vui lòng chụp lại !!!",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
