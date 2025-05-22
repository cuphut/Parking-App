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
  String? _selectedCompany;
  List<String> _companyList = [];
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
        _isSearching = false;
        _searchController.clear();
        _selectedDate = null;
        _selectedCompany = null;

        // Trích danh sách công ty duy nhất
        final companies =
            list
                .map<String?>(
                  (item) => item['registered_vehicles']?['company'] as String?,
                )
                .whereType<String>()
                .toSet()
                .toList();

        companies.sort(); // sắp xếp cho gọn
        _companyList = companies;
      });
    });
  }

  String formatLicensePlate(String plate) {
    if (plate.length < 7) return plate;
    String part1 = plate.substring(0, 2);
    String part2 = plate.substring(2, 4);
    String part3 = plate.substring(4);
    return '$part1-$part2 $part3';
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredList =
          _originalList.where((item) {
            final plate = item['license_plate']?.toLowerCase() ?? '';
            final timeIn =
                item['entry_time'] != null
                    ? DateTime.tryParse(item['entry_time'])
                    : null;
            final company = item['registered_vehicles']?['company'] ?? '';

            final matchesPlate = query.isEmpty || plate.contains(query);
            final matchesDate =
                _selectedDate == null ||
                (timeIn != null &&
                    timeIn.year == _selectedDate!.year &&
                    timeIn.month == _selectedDate!.month &&
                    timeIn.day == _selectedDate!.day);
            final matchesCompany =
                _selectedCompany == null || _selectedCompany == company;

            return matchesPlate && matchesDate && matchesCompany;
          }).toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;

      if (!_isSearching) {
        _searchController.clear();
        _filterList();
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.two_wheeler,
                  color: Colors.black,
                  size: 30,
                  semanticLabel: 'Phương tiện',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formatLicensePlate(item['license_plate'] ?? 'Không rõ'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '👤 Chủ xe: ${item['registered_vehicles']?['owner_name'] ?? '---'}',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '🏢 Công ty: ${item['registered_vehicles']?['company'] ?? '---'} (Tầng ${item['registered_vehicles']?['floor_number'] ?? '-'})',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '📞 SĐT: ${item['registered_vehicles']?['phone_number'] ?? '---'}',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '🕓 Vào: ${_formatTime(item['entry_time'])}',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '🕓 Ra: ${_formatTime(item['exit_time'])}',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
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
    String? formattedDate =
        _selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
            : null;

    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Nhập biển số...',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danh sách bãi đỗ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    if (formattedDate != null)
                      Text(
                        'Ngày: $formattedDate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, semanticLabel: 'Chọn ngày'),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.blueAccent,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
                _filterList();
              }
            },
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(
                Icons.filter_alt_off,
                semanticLabel: 'Hủy chọn ngày',
              ),
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
                _filterList();
              },
            ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              semanticLabel: _isSearching ? 'Đóng tìm kiếm' : 'Tìm kiếm',
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_companyList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    isScrollControlled: true, // Cho phép cuộn nếu danh sách dài
                    builder: (context) {
                      return Container(
                        height:
                            MediaQuery.of(context).size.height *
                            0.5, // Chiếm 50% chiều cao màn hình
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tiêu đề của bottom sheet
                            Text(
                              'Chọn công ty',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Danh sách công ty
                            Expanded(
                              child: ListView(
                                children: [
                                  ListTile(
                                    title: Text(
                                      'Tất cả công ty',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedCompany = null;
                                      });
                                      _filterList();
                                      Navigator.pop(context);
                                    },
                                    tileColor:
                                        _selectedCompany == null
                                            ? Colors.grey[200]
                                            : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  ..._companyList.map((company) {
                                    return ListTile(
                                      title: Text(
                                        company,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedCompany = company;
                                        });
                                        _filterList();
                                        Navigator.pop(context);
                                      },
                                      tileColor:
                                          _selectedCompany == company
                                              ? Colors.grey[200]
                                              : null,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Chọn công ty',
                    labelStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.business,
                      color: Colors.blueAccent,
                      semanticLabel: 'Công ty',
                    ),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                  ),
                  child: Text(
                    _selectedCompany ?? 'Tất cả công ty',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder(
              future: _parkingListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lỗi: ${snapshot.error}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchParkingList,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Thử lại',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (_filteredList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy kết quả phù hợp.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _fetchParkingList();
                    await _parkingListFuture;
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 20.0,
                    ),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildListItem(_filteredList[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
