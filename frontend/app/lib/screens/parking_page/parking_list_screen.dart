import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/services/parking_service.dart';

class ParkingListScreen extends StatefulWidget {
  const ParkingListScreen({super.key});

  @override
  State<ParkingListScreen> createState() => _ParkingListScreenState();
}

class _ParkingListScreenState extends State<ParkingListScreen> {
  late Future<List<dynamic>> _parkingListFuture;
  List<dynamic> _originalList = [];
  List<dynamic> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  DateTime? _selectedDate;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _fetchParkingList();
    _searchController.addListener(_filterList);
  }

  void _fetchParkingList() {
    _parkingListFuture = ParkingService().getAllParking();
    _parkingListFuture.then((list) {
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
        final plate = item['plate']?.toLowerCase() ?? '';
        final timeIn = item['timeIn'] != null ? DateTime.tryParse(item['timeIn']) : null;

        final matchesPlate = query.isEmpty || plate.contains(query);
        final matchesDate = _selectedDate == null || (timeIn != null &&
          timeIn.year == _selectedDate!.year &&
          timeIn.month == _selectedDate!.month &&
          timeIn.day == _selectedDate!.day);

        return matchesPlate && matchesDate;
      }).toList();  
    });
  }


  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredList = _originalList;
        _selectedDate = null;
      }
    });
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '---';
    final time = DateTime.tryParse(timeStr);
    return time != null ? _dateFormat.format(time) : '---';
  }

  Widget _buildListItem(dynamic item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.two_wheeler, color: Colors.black, size: 30),
                const SizedBox(width: 10),
                Text(
                  item['plate'] ?? 'Không rõ',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('👤 Chủ xe: ${item['name'] ?? '---'}', style: const TextStyle(fontSize: 16)),
            Text('🏢 Công ty: ${item['companyName'] ?? '---'} (Tầng ${item['companyFloor'] ?? '-'})', style: const TextStyle(fontSize: 16)),
            Text('📞 SĐT: ${item['phone'] ?? '---'}', style: const TextStyle(fontSize: 16)),
            Text('🕓 Vào: ${_formatTime(item['timeIn'])}', style: const TextStyle(fontSize: 16)),
            Text('🕓 Ra: ${_formatTime(item['timeOut'])}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? formattedDate = _selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Nhập biển số...',
                  border: InputBorder.none,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Danh sách bãi đỗ'),
                  if (formattedDate != null)
                    Text(
                      'Ngày: $formattedDate',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
                _filterList();
              }
            },
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _parkingListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (_filteredList.isEmpty) {
            return const Center(child: Text('Không tìm thấy kết quả phù hợp.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchParkingList();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                return _buildListItem(_filteredList[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
