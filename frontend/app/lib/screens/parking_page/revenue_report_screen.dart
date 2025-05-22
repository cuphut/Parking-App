import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/services/parking_service.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  late Future<List<dynamic>> _parkingListFuture;
  List<dynamic> _parkingData = [];

  // Bộ lọc thời gian
  String filterType = 'Ngày'; // Ngày hoặc Tháng
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchParkingData();
  }

  void _fetchParkingData() {
    _parkingListFuture = ParkingService().getAllParking();
    _parkingListFuture
        .then((data) {
          setState(() {
            _parkingData = data;
          });
        })
        .catchError((error) {
          print('Error fetching parking data: $error');
        });
  }

  // Hàm lọc dữ liệu theo ngày/tháng
  Map<String, dynamic> filterData() {
    List<Map<String, dynamic>> filteredData = [];

    if (filterType == 'Ngày') {
      filteredData =
          _parkingData
              .where((record) {
                final entryTime =
                    record['entry_time'] != null
                        ? DateTime.tryParse(record['entry_time'])
                        : null;
                final exitTime =
                    record['exit_time'] != null
                        ? DateTime.tryParse(record['exit_time'])
                        : null;

                bool matchesEntry =
                    entryTime != null &&
                    entryTime.day == selectedDate.day &&
                    entryTime.month == selectedDate.month &&
                    entryTime.year == selectedDate.year;

                bool matchesExit =
                    exitTime != null &&
                    exitTime.day == selectedDate.day &&
                    exitTime.month == selectedDate.month &&
                    exitTime.year == selectedDate.year;

                return matchesEntry || matchesExit;
              })
              .cast<Map<String, dynamic>>()
              .toList();
    } else {
      filteredData =
          _parkingData
              .where((record) {
                final entryTime =
                    record['entry_time'] != null
                        ? DateTime.tryParse(record['entry_time'])
                        : null;
                final exitTime =
                    record['exit_time'] != null
                        ? DateTime.tryParse(record['exit_time'])
                        : null;

                bool matchesEntry =
                    entryTime != null &&
                    entryTime.month == selectedDate.month &&
                    entryTime.year == selectedDate.year;

                bool matchesExit =
                    exitTime != null &&
                    exitTime.month == selectedDate.month &&
                    exitTime.year == selectedDate.year;

                return matchesEntry || matchesExit;
              })
              .cast<Map<String, dynamic>>()
              .toList();
    }

    // Tính toán tổng quát
    int totalEntries =
        filteredData
            .where(
              (record) =>
                  record['entry_time'] != null &&
                  DateTime.tryParse(record['entry_time']) != null &&
                  (filterType == 'Ngày'
                      ? DateTime.tryParse(record['entry_time'])!.day ==
                          selectedDate.day
                      : true),
            )
            .length;

    int totalExits =
        filteredData
            .where(
              (record) =>
                  record['exit_time'] != null &&
                  DateTime.tryParse(record['exit_time']) != null &&
                  (filterType == 'Ngày'
                      ? DateTime.tryParse(record['exit_time'])!.day ==
                          selectedDate.day
                      : true),
            )
            .length;

    // Tính toán theo công ty
    Map<String, Map<String, dynamic>> companyStats = {};
    for (var record in filteredData) {
      String company = record['registered_vehicles']?['company'] ?? 'Không rõ';
      if (!companyStats.containsKey(company)) {
        companyStats[company] = {'entries': 0, 'exits': 0, 'revenue': 0.0};
      }

      final entryTime =
          record['entry_time'] != null
              ? DateTime.tryParse(record['entry_time'])
              : null;
      final exitTime =
          record['exit_time'] != null
              ? DateTime.tryParse(record['exit_time'])
              : null;

      if (entryTime != null &&
          (filterType == 'Ngày'
              ? entryTime.day == selectedDate.day
              : entryTime.month == selectedDate.month)) {
        companyStats[company]!['entries'] += 1;
      }

      if (exitTime != null &&
          (filterType == 'Ngày'
              ? exitTime.day == selectedDate.day
              : exitTime.month == selectedDate.month)) {
        companyStats[company]!['exits'] += 1;
      }
    }

    return {
      'totalEntries': totalEntries,
      'totalExits': totalExits,
      'companyStats': companyStats,
    };
  }

  // Chọn ngày/tháng
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Báo cáo doanh thu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _parkingListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final stats = filterData();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bộ lọc thời gian
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: filterType,
                      items:
                          ['Ngày', 'Tháng'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          filterType = value!;
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        filterType == 'Ngày'
                            ? DateFormat('dd/MM/yyyy').format(selectedDate)
                            : DateFormat('MM/yyyy').format(selectedDate),
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Thống kê tổng quát
                Text(
                  'Thống kê tổng quát',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tổng số lượt vào:'),
                            Text('${stats['totalEntries']}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tổng số lượt ra:'),
                            Text('${stats['totalExits']}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Thống kê theo công ty
                Text(
                  'Thống kê theo công ty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                stats['companyStats'].isEmpty
                    ? Text('Không có dữ liệu cho khoảng thời gian này.')
                    : Column(
                      children:
                          stats['companyStats'].entries.map<Widget>((entry) {
                            String company = entry.key;
                            var data = entry.value;
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      company,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Số lượt vào:'),
                                        Text('${data['entries']}'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Số lượt ra:'),
                                        Text('${data['exits']}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
