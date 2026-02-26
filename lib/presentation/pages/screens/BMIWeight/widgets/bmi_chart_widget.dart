import 'package:doctor_care/domain/entities/bmi_weight.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BmiChartWidget extends StatefulWidget {
  final List<BMIWeight> records;

  const BmiChartWidget({super.key, required this.records});

  @override
  State<BmiChartWidget> createState() => _BmiChartWidgetState();
}

class _BmiChartWidgetState extends State<BmiChartWidget> {
  int _selectedTab = 0; // 0: BMI, 1: Cân nặng

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sắp xếp theo ngày tăng dần, lấy tối đa 10 bản ghi gần nhất
    final sorted = List<BMIWeight>.from(widget.records)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final displayRecords = sorted.length > 10
        ? sorted.sublist(sorted.length - 10)
        : sorted;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab chuyển đổi BMI / Cân nặng
          Row(
            children: [
              _buildTab("BMI", 0, Icons.analytics_outlined),
              const Gap(8),
              _buildTab("Cân nặng", 1, Icons.monitor_weight_outlined),
              const Spacer(),
              // Hiển thị giá trị mới nhất
              _buildLatestValue(displayRecords),
            ],
          ),
          const Gap(16),

          // Biểu đồ
          SizedBox(
            height: 180,
            child: _selectedTab == 0
                ? _buildBmiChart(displayRecords)
                : _buildWeightChart(displayRecords),
          ),

          const Gap(8),
          // Chú thích vùng BMI
          if (_selectedTab == 0) _buildBmiLegend(),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.blue : Colors.grey),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blue : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestValue(List<BMIWeight> records) {
    final latest = records.last;
    final value = _selectedTab == 0
        ? latest.bmi.toStringAsFixed(1)
        : "${latest.weight.toStringAsFixed(1)} kg";
    final color = _selectedTab == 0 ? latest.bmiColor : Colors.purple.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          _selectedTab == 0 ? latest.bmiStatus : "Mới nhất",
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }

  Widget _buildBmiChart(List<BMIWeight> records) {
    final spots = <FlSpot>[];
    for (int i = 0; i < records.length; i++) {
      spots.add(FlSpot(i.toDouble(), double.parse(records[i].bmi.toStringAsFixed(1))));
    }

    final allBmi = records.map((r) => r.bmi).toList();
    final minY = (allBmi.reduce((a, b) => a < b ? a : b) - 2).clamp(10.0, 50.0);
    final maxY = (allBmi.reduce((a, b) => a > b ? a : b) + 2).clamp(15.0, 55.0);

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getBmiInterval(minY, maxY),
          getDrawingHorizontalLine: (value) {
            Color lineColor = Colors.grey.shade200;
            double strokeWidth = 0.8;

            // Highlight vùng bình thường (18.5 - 24.9)
            if ((value - 18.5).abs() < 0.5 || (value - 24.9).abs() < 0.5) {
              lineColor = Colors.green.shade200;
              strokeWidth = 1.2;
            }

            return FlLine(color: lineColor, strokeWidth: strokeWidth);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: _getBmiInterval(minY, maxY),
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= records.length) return const SizedBox();
                // Hiển thị tối đa 5 label
                if (records.length > 5 && idx % ((records.length / 5).ceil()) != 0 && idx != records.length - 1) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('dd/MM').format(records[idx].timestamp),
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.blue.shade600,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final bmi = records[index].bmi;
                return FlDotCirclePainter(
                  radius: 4,
                  color: _getBmiDotColor(bmi),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade200.withValues(alpha: 0.3),
                  Colors.blue.shade50.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          // Đường giới hạn bình thường
          if (minY <= 18.5 && maxY >= 18.5)
            LineChartBarData(
              spots: [FlSpot(0, 18.5), FlSpot(records.length - 1, 18.5)],
              isCurved: false,
              color: Colors.green.shade300,
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
          if (minY <= 24.9 && maxY >= 24.9)
            LineChartBarData(
              spots: [FlSpot(0, 24.9), FlSpot(records.length - 1, 24.9)],
              isCurved: false,
              color: Colors.green.shade300,
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey.shade800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                if (idx < 0 || idx >= records.length) return null;
                final record = records[idx];
                return LineTooltipItem(
                  "BMI: ${record.bmi.toStringAsFixed(1)}\n${DateFormat('dd/MM/yyyy').format(record.timestamp)}",
                  const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChart(List<BMIWeight> records) {
    final spots = <FlSpot>[];
    for (int i = 0; i < records.length; i++) {
      spots.add(FlSpot(i.toDouble(), records[i].weight));
    }

    final allWeight = records.map((r) => r.weight).toList();
    final minY = (allWeight.reduce((a, b) => a < b ? a : b) - 3).clamp(20.0, 200.0);
    final maxY = (allWeight.reduce((a, b) => a > b ? a : b) + 3).clamp(25.0, 220.0);
    final interval = ((maxY - minY) / 5).ceilToDouble().clamp(1.0, 20.0);

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 0.8);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= records.length) return const SizedBox();
                if (records.length > 5 && idx % ((records.length / 5).ceil()) != 0 && idx != records.length - 1) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('dd/MM').format(records[idx].timestamp),
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.purple.shade500,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.purple.shade500,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple.shade200.withValues(alpha: 0.3),
                  Colors.purple.shade50.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.purple.shade800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                if (idx < 0 || idx >= records.length) return null;
                final record = records[idx];
                return LineTooltipItem(
                  "${record.weight.toStringAsFixed(1)} kg\n${DateFormat('dd/MM/yyyy').format(record.timestamp)}",
                  const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBmiLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.blue, "Thiếu cân"),
        const Gap(12),
        _legendItem(Colors.green, "Bình thường"),
        const Gap(12),
        _legendItem(Colors.orange, "Thừa cân"),
        const Gap(12),
        _legendItem(Colors.red, "Béo phì"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  Color _getBmiDotColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  double _getBmiInterval(double minY, double maxY) {
    final range = maxY - minY;
    if (range <= 10) return 2;
    if (range <= 20) return 4;
    return 5;
  }
}
