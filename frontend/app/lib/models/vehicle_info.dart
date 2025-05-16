class VehicleInfo {
  final String plate;
  final String name;
  final String companyName;
  final String companyFloor;
  final String phone;

  VehicleInfo({
    required this.plate,
    required this.name,
    required this.companyName,
    required this.companyFloor,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'plate': plate,
        'name': name,
        'companyName': companyName,
        'companyFloor': companyFloor,
        'phone': phone,
      };

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      plate: json['plate'],
      name: json['name'],
      companyName: json['companyName'],
      companyFloor: json['companyFloor'],
      phone: json['phone'],
    );
  }
}