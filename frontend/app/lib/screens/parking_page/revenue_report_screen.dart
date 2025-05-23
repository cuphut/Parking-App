import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:app/services/parking_service.dart'; // Ensure this is correctly set up

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  late Future<List<dynamic>> _parkingListFuture;
  List<dynamic> _parkingData = [];

  // Bộ lọc thời gian
  String filterType = 'Ngày'; // Ngày, Tháng, or Khoảng thời gian
  DateTime selectedDate = DateTime.now();
  DateTime? startDate;
  DateTime? endDate;

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

  // Hàm lọc dữ liệu theo ngày/tháng/khoảng thời gian
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
    } else if (filterType == 'Tháng') {
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
    } else if (filterType == 'Khoảng thời gian') {
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
                    startDate != null &&
                    endDate != null &&
                    entryTime.isAfter(startDate!.subtract(Duration(days: 1))) &&
                    entryTime.isBefore(endDate!.add(Duration(days: 1)));

                bool matchesExit =
                    exitTime != null &&
                    startDate != null &&
                    endDate != null &&
                    exitTime.isAfter(startDate!.subtract(Duration(days: 1))) &&
                    exitTime.isBefore(endDate!.add(Duration(days: 1)));

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
                      : filterType == 'Tháng'
                      ? DateTime.tryParse(record['entry_time'])!.month ==
                          selectedDate.month
                      : startDate != null &&
                          endDate != null &&
                          DateTime.tryParse(
                            record['entry_time'],
                          )!.isAfter(startDate!.subtract(Duration(days: 1))) &&
                          DateTime.tryParse(
                            record['entry_time'],
                          )!.isBefore(endDate!.add(Duration(days: 1)))),
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
                      : filterType == 'Tháng'
                      ? DateTime.tryParse(record['exit_time'])!.month ==
                          selectedDate.month
                      : startDate != null &&
                          endDate != null &&
                          DateTime.tryParse(
                            record['exit_time'],
                          )!.isAfter(startDate!.subtract(Duration(days: 1))) &&
                          DateTime.tryParse(
                            record['exit_time'],
                          )!.isBefore(endDate!.add(Duration(days: 1)))),
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
              : filterType == 'Tháng'
              ? entryTime.month == selectedDate.month
              : startDate != null &&
                  endDate != null &&
                  entryTime.isAfter(startDate!.subtract(Duration(days: 1))) &&
                  entryTime.isBefore(endDate!.add(Duration(days: 1))))) {
        companyStats[company]!['entries'] += 1;
      }

      if (exitTime != null &&
          (filterType == 'Ngày'
              ? exitTime.day == selectedDate.day
              : filterType == 'Tháng'
              ? exitTime.month == selectedDate.month
              : startDate != null &&
                  endDate != null &&
                  exitTime.isAfter(startDate!.subtract(Duration(days: 1))) &&
                  exitTime.isBefore(endDate!.add(Duration(days: 1))))) {
        companyStats[company]!['exits'] += 1;
      }
    }

    return {
      'totalEntries': totalEntries,
      'totalExits': totalExits,
      'companyStats': companyStats,
      'filteredData': filteredData, // For Excel export
    };
  }

  // Chọn ngày/tháng
  Future<void> _selectDate(
    BuildContext context, {
    bool isStartDate = false,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? (startDate ?? DateTime.now())
              : (endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else if (filterType == 'Ngày' || filterType == 'Tháng') {
          selectedDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // Legend Widget
  Widget _buildLegend(Gradient gradient, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  double _calculateMaxY(Map<String, dynamic> companyStats) {
    double maxY = 0;
    for (var data in companyStats.values) {
      final entries = (data['entries'] as num?)?.toDouble() ?? 0;
      final exits = (data['exits'] as num?)?.toDouble() ?? 0;
      maxY = max(maxY, max(entries, exits));
    }
    return maxY;
  }

  // Xuất báo cáo Excel
  Future<void> _exportToExcel(Map<String, dynamic> stats) async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Headers
    sheet.appendRow([
      TextCellValue('Công ty'),
      TextCellValue('Số lượt vào'),
      TextCellValue('Số lượt ra'),
    ]);

    // Data
    stats['companyStats'].forEach((company, data) {
      sheet.appendRow([
        TextCellValue(company),
        TextCellValue(data['entries'].toString()),
        TextCellValue(data['exits'].toString()),
      ]);
    });

    // Tổng quát
    sheet.appendRow([
      TextCellValue('Tổng cộng'),
      TextCellValue(stats['totalEntries'].toString()),
      TextCellValue(stats['totalExits'].toString()),
    ]);

    // Lưu file
    String? outputPath = await FilePicker.platform.getDirectoryPath();
    if (outputPath != null) {
      final file = File(
        '$outputPath/revenue_report_${DateTime.now().toIso8601String()}.xlsx',
      );
      await file.writeAsBytes(excel.encode()!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xuất báo cáo tại ${file.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thống kê',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _exportToExcel(filterData()),
            tooltip: 'Xuất Excel',
          ),
        ],
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
                          ['Ngày', 'Tháng', 'Khoảng thời gian'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          filterType = value!;
                          startDate = null;
                          endDate = null;
                        });
                      },
                    ),
                    if (filterType == 'Khoảng thời gian') ...[
                      TextButton(
                        onPressed:
                            () => _selectDate(context, isStartDate: true),
                        child: Text(
                          startDate != null
                              ? DateFormat('dd/MM/yyyy').format(startDate!)
                              : 'Từ ngày',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          endDate != null
                              ? DateFormat('dd/MM/yyyy').format(endDate!)
                              : 'Đến ngày',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ] else
                      Text(
                        filterType == 'Ngày'
                            ? DateFormat('dd/MM/yyyy').format(selectedDate)
                            : DateFormat('MM/yyyy').format(selectedDate),
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Biểu đồ
                Text(
                  'Biểu đồ thống kê',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 3,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child:
                      stats['companyStats'].isEmpty
                          ? const Center(
                            child: Text(
                              'Không có dữ liệu để hiển thị biểu đồ.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : Column(
                            children: [
                              Expanded(
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceBetween,
                                    barGroups:
                                        stats['companyStats'].entries
                                            .toList()
                                            .asMap()
                                            .entries
                                            .map<BarChartGroupData>((entry) {
                                              final index = entry.key;
                                              final data = entry.value.value;
                                              return BarChartGroupData(
                                                x: index,
                                                barsSpace: 6,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY:
                                                        (data['entries']
                                                                as num?)
                                                            ?.toDouble() ??
                                                        0,
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            Color(0xFF4FC3F7),
                                                            Color(0xFF0288D1),
                                                          ],
                                                          begin:
                                                              Alignment
                                                                  .bottomCenter,
                                                          end:
                                                              Alignment
                                                                  .topCenter,
                                                        ),
                                                    width: 14,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    backDrawRodData:
                                                        BackgroundBarChartRodData(
                                                          show: true,
                                                          toY: 0,
                                                          color: Colors.grey
                                                              .withOpacity(0.1),
                                                        ),
                                                  ),
                                                  BarChartRodData(
                                                    toY:
                                                        (data['exits'] as num?)
                                                            ?.toDouble() ??
                                                        0,
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            Color(0xFFFF8A80),
                                                            Color(0xFFD81B60),
                                                          ],
                                                          begin:
                                                              Alignment
                                                                  .bottomCenter,
                                                          end:
                                                              Alignment
                                                                  .topCenter,
                                                        ),
                                                    width: 14,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    backDrawRodData:
                                                        BackgroundBarChartRodData(
                                                          show: true,
                                                          toY: 0,
                                                          color: Colors.grey
                                                              .withOpacity(0.1),
                                                        ),
                                                  ),
                                                ],
                                              );
                                            })
                                            .toList(),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 48,
                                          interval:
                                              1, // Force ticks at intervals of 1
                                          getTitlesWidget: (value, meta) {
                                            if (value == meta.max) {
                                              return const SizedBox.shrink(); // Hide the topmost label to avoid overlap
                                            }
                                            return Text(
                                              value.toInt().toString(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF333333),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 32,
                                          getTitlesWidget: (value, meta) {
                                            final companies =
                                                stats['companyStats'].keys
                                                    .toList();
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Text(
                                                companies[value.toInt()],
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF333333),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval:
                                          1, // Match the Y-axis tick interval
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.withOpacity(0.2),
                                          strokeWidth: 1,
                                          dashArray: [5, 5],
                                        );
                                      },
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        tooltipPadding: const EdgeInsets.all(8),
                                        tooltipBorder: BorderSide.none,
                                        getTooltipItem: (
                                          group,
                                          groupIndex,
                                          rod,
                                          rodIndex,
                                        ) {
                                          final companies =
                                              stats['companyStats'].keys
                                                  .toList();
                                          final label =
                                              rodIndex == 0
                                                  ? 'Lượt vào'
                                                  : 'Lượt ra';
                                          return BarTooltipItem(
                                            '$label: ${rod.toY.toInt()}\n${companies[group.x]}',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    extraLinesData: ExtraLinesData(),
                                    minY: 0, // Ensure the Y-axis starts at 0
                                    maxY:
                                        _calculateMaxY(stats['companyStats']) +
                                        0.5,
                                  ),
                                  swapAnimationDuration: const Duration(
                                    milliseconds: 800,
                                  ),
                                  swapAnimationCurve: Curves.easeOutQuart,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegend(
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFF4FC3F7),
                                        Color(0xFF0288D1),
                                      ],
                                    ),
                                    'Lượt vào',
                                  ),
                                  const SizedBox(width: 24),
                                  _buildLegend(
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFFF8A80),
                                        Color(0xFFD81B60),
                                      ],
                                    ),
                                    'Lượt ra',
                                  ),
                                ],
                              ),
                            ],
                          ),
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
