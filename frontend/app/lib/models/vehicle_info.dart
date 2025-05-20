class VehicleInfo {
  final String licensePlate;
  final String ownerName;
  final String company;
  final int floor_number;
  final String phoneNumber;
  final String image; // Base64 hoặc URL

  VehicleInfo({
    required this.licensePlate,
    required this.ownerName,
    required this.company,
    required this.floor_number,
    required this.phoneNumber,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'license_plate': licensePlate,
      'owner_name': ownerName,
      'company': company,
      'floor_number': floor_number,
      'phone_number': phoneNumber,
      'image': image,
    };
  }

    factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      licensePlate: json['license_plate']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      floor_number: json['floor_number'] is int
          ? json['floor_number']
          : int.tryParse(json['floor_number'].toString()) ?? 0,
      phoneNumber: json['phone_number']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
}
