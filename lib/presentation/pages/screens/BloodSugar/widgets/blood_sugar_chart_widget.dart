import 'package:doctor_care/domain/entities/blood_sugar.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BloodSugarChartWidget extends StatefulWidget {
  final List<BloodSugar> records;

  const BloodSugarChartWidget({super.key, required this.records});

  @override
  State<BloodSugarChartWidget> createState() => _BloodSugarChartWidgetState();
}

class _BloodSugarChartWidgetState extends State<BloodSugarChartWidget> {
  String _selectedFilter = 'all'; // 'all', 'fasting', 'before_meal', 'after_meal', 'random'

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sắp xếp theo ngày tăng dần
    final sorted = List<BloodSugar>.from(widget.records)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Lọc theo trạng thái bữa ăn
    final filtered = _selectedFilter == 'all'
        ? sorted
        : sorted.where((r) => r.mealStatus == _selectedFilter).toList();

    // Lấy tối đa 10 bản ghi gần nhất
    final displayRecords = filtered.length > 10
        ? filtered.sublist(filtered.length - 10)
        : filtered;

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
          // Header: tiêu đề + giá trị mới nhất
          Row(
            children: [
              Icon(Icons.water_drop, size: 20, color: Colors.teal.shade600),
              const Gap(8),
              Text(
                "Biểu đồ đường huyết",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              if (displayRecords.isNotEmpty) _buildLatestValue(displayRecords.last),
            ],
          ),
          const Gap(12),

          // Filter tabs theo trạng thái bữa ăn
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 'all'),
                const Gap(6),
                _buildFilterChip('Lúc đói', 'fasting'),
                const Gap(6),
                _buildFilterChip('Trước ăn', 'before_meal'),
                const Gap(6),
                _buildFilterChip('Sau ăn 2h', 'after_meal'),
                const Gap(6),
                _buildFilterChip('Ngẫu nhiên', 'random'),
              ],
            ),
          ),
          const Gap(16),

          // Biểu đồ
          if (displayRecords.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  context.tr('no_data_for_filter'),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: _buildChart(displayRecords),
            ),

          const Gap(8),
          // Chú thích vùng đường huyết
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.teal.shade700 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildLatestValue(BloodSugar latest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              latest.value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: latest.statusColor,
              ),
            ),
            const Gap(3),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                "mg/dL",
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        Text(
          latest.status,
          style: TextStyle(fontSize: 11, color: latest.statusColor),
        ),
      ],
    );
  }

  Widget _buildChart(List<BloodSugar> records) {
    final spots = <FlSpot>[];
    for (int i = 0; i < records.length; i++) {
      spots.add(FlSpot(i.toDouble(), records[i].value));
    }

    final allValues = records.map((r) => r.value).toList();
    final dataMin = allValues.reduce((a, b) => a < b ? a : b);
    final dataMax = allValues.reduce((a, b) => a > b ? a : b);
    final minY = (dataMin - 20).clamp(0.0, 300.0);
    final maxY = (dataMax + 20).clamp(50.0, 500.0);
    final interval = _getInterval(minY, maxY);

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) {
            // Highlight vùng ngưỡng quan trọng
            if (_isThresholdLine(value)) {
              return FlLine(
                color: Colors.orange.shade200,
                strokeWidth: 1.2,
                dashArray: [4, 4],
              );
            }
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
                if (records.length > 5 &&
                    idx % ((records.length / 5).ceil()) != 0 &&
                    idx != records.length - 1) {
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
        // Vùng nền bình thường (70–100 hoặc 70–140)
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: 70,
              y2: _selectedFilter == 'after_meal' || _selectedFilter == 'random' ? 140 : 100,
              color: Colors.green.withValues(alpha: 0.06),
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.teal.shade600,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final record = records[index];
                return FlDotCirclePainter(
                  radius: 4,
                  color: record.statusColor,
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
                  Colors.teal.shade200.withValues(alpha: 0.3),
                  Colors.teal.shade50.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          // Đường ngưỡng 70 mg/dL (hạ đường huyết)
          if (minY <= 70 && maxY >= 70)
            LineChartBarData(
              spots: [FlSpot(0, 70), FlSpot(records.length - 1, 70)],
              isCurved: false,
              color: Colors.blue.shade300,
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
          // Đường ngưỡng trên (100 hoặc 140 tuỳ filter)
          _buildUpperThresholdLine(records.length),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.teal.shade800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                if (idx < 0 || idx >= records.length) return null;
                final record = records[idx];
                return LineTooltipItem(
                  "${record.value.toStringAsFixed(0)} mg/dL\n"
                  "${record.mealStatusLabel} • ${DateFormat('dd/MM/yyyy').format(record.timestamp)}",
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildUpperThresholdLine(int length) {
    final threshold = (_selectedFilter == 'after_meal' || _selectedFilter == 'random') ? 140.0 : 100.0;
    return LineChartBarData(
      spots: [FlSpot(0, threshold), FlSpot(length - 1, threshold)],
      isCurved: false,
      color: Colors.orange.shade300,
      barWidth: 1,
      dotData: const FlDotData(show: false),
      dashArray: [5, 5],
    );
  }

  bool _isThresholdLine(double value) {
    return (value - 70).abs() < 2 || (value - 100).abs() < 2 || (value - 140).abs() < 2;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.blue, "Hạ ĐH"),
        const Gap(10),
        _legendItem(Colors.green, "Bình thường"),
        const Gap(10),
        _legendItem(Colors.orange, "Tiền ĐTĐ"),
        const Gap(10),
        _legendItem(Colors.red, "ĐTĐ"),
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

  double _getInterval(double minY, double maxY) {
    final range = maxY - minY;
    if (range <= 60) return 10;
    if (range <= 120) return 20;
    if (range <= 250) return 50;
    return 100;
  }
}
