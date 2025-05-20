import 'package:flutter/material.dart';
import '../../models/vehicle_info.dart';
import '../../services/vehicle_service.dart';
import 'view_details_vehicles_screen.dart';

class ViewVehiclesScreen extends StatefulWidget {
  final bool role;

  const ViewVehiclesScreen({required this.role, super.key});

  @override
  State<ViewVehiclesScreen> createState() => _ViewVehiclesScreenState();
}

class _ViewVehiclesScreenState extends State<ViewVehiclesScreen> {
  late Future<List<VehicleInfo>> _vehicles;
  List<VehicleInfo> _originalList = [];
  List<VehicleInfo> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
    _searchController.addListener(_filterList);
  }

  void _fetchVehicles() {
    _vehicles = VehicleService.fetchVehicles();
    _vehicles.then((list) {
      setState(() {
        _originalList = list;
        _filteredList = list;
      });
    });
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredList = _originalList.where((item) {
        final plate = item.licensePlate.toLowerCase();
        return query.isEmpty || plate.contains(query);
      }).toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredList = _originalList;
      }
    });
  }

  String formatLicensePlate(String plate) {
    if (plate.length < 7) return plate;
    String part1 = plate.substring(0, 2);
    String part2 = plate.substring(2, 4);
    String part3 = plate.substring(4);
    return '$part1-$part2 $part3';
  }

  void _navigateToDetail(String plate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDetailScreen(
          plate: plate,
          role: widget.role,
        ),
      ),
    );

    if (result == true) {
      _fetchVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nhập biển số...',
                  hintStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              )
            : const Text(
                'Danh sách phương tiện',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              semanticLabel: _isSearching ? 'Đóng tìm kiếm' : 'Tìm kiếm',
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<VehicleInfo>>(
          future: _vehicles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lỗi: ${snapshot.error}',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchVehicles,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text(
                        'Thử lại',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            } else if (_filteredList.isEmpty) {
              return const Center(
                child: Text(
                  'Không tìm thấy phương tiện nào.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              itemCount: _filteredList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vehicle = _filteredList[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Icon(
                      Icons.two_wheeler,
                      size: 36,
                      color: Colors.black,
                      semanticLabel: 'Phương tiện',
                    ),
                    title: Text(
                      formatLicensePlate(vehicle.licensePlate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          vehicle.ownerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vehicle.company} (Tầng ${vehicle.floor_number})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.black,
                      semanticLabel: 'Xem chi tiết',
                    ),
                    onTap: () {
                      _navigateToDetail(vehicle.licensePlate);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}