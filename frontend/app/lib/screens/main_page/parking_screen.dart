import 'package:flutter/material.dart';
import '../../services/parking_service.dart';
import 'package:intl/intl.dart';

class ParkingScreen extends StatefulWidget {
  final String searchQuery;

  const ParkingScreen({super.key, required this.searchQuery});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  final ParkingService _parkingService = ParkingService();
  List<dynamic> _parkingList = [];
  List<dynamic> _filteredParkingList = [];
  bool _isLoading = false;
  String? _errorMessage;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  
  @override
  void initState() {
    super.initState();
    _fetchParkingList();
  }

  @override
  void didUpdateWidget(covariant ParkingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _filterParkingList();
    }
  }

  Future<void> _fetchParkingList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final parkingData = await _parkingService.getAllParking();
      setState(() {
        _parkingList = parkingData;
        _filterParkingList(); // Lọc dựa trên searchQuery
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterParkingList() {
    final query = widget.searchQuery.toLowerCase();
    setState(() {
      _filteredParkingList = _parkingList.where((parking) {
        final plate = (parking['plate'] ?? '').toLowerCase();
        final timeOut = parking['timeOut'];
        final isStillParked = timeOut == null || timeOut.toString().isEmpty;

        final matchesQuery = query.isEmpty || plate.contains(query);
        return isStillParked && matchesQuery;
      }).toList();
    });
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '---';
    final time = DateTime.tryParse(timeStr);
    return time != null ? _dateFormat.format(time) : '---';
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : _filteredParkingList.isEmpty
                ? const Center(child: Text('Không tìm thấy bản ghi nào'))
                : RefreshIndicator(
                    onRefresh: _fetchParkingList,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredParkingList.length,
                      itemBuilder: (context, index) {
                        final parking = _filteredParkingList[index];
                        final plate = parking['plate'] ?? '';
                        final name = parking['name'] ?? '';
                        final companyName = parking['companyName'] ?? '';
                        final companyFloor = parking['companyFloor'] ?? '';
                        final phone = parking['phone'] ?? '';
                        final timeIn = parking['timeIn'] ?? '';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Biển số: $plate",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text("Tên: $name", style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("Công ty: $companyName, Tầng: $companyFloor", style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("SĐT: $phone", style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("Thời gian vào: ${_formatTime("$timeIn")}", style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
  }
}
