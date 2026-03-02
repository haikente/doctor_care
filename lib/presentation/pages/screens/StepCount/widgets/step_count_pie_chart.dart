import 'package:doctor_care/domain/entities/step_count.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StepCountPieChart extends StatelessWidget {
  final List<StepCount> records;

  const StepCountPieChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const SizedBox.shrink();

    // Đếm số lượng theo từng trạng thái
    final statusCount = <String, int>{};
    for (final r in records) {
      statusCount[r.status] = (statusCount[r.status] ?? 0) + 1;
    }

    // Danh sách trạng thái theo thứ tự
    final statusOrder = [
      'Ít vận động',
      'Vận động nhẹ',
      'Vận động vừa',
      'Tốt',
      'Rất tích cực',
    ];

    final colorMap = {
      'Ít vận động': Colors.red.shade400,
      'Vận động nhẹ': Colors.orange.shade400,
      'Vận động vừa': Colors.amber.shade600,
      'Tốt': Colors.green.shade500,
      'Rất tích cực': Colors.teal.shade500,
    };

    // Tạo danh sách sections (chỉ trạng thái có dữ liệu)
    final total = records.length;
    final sections = <PieChartSectionData>[];
    final legends = <_LegendItem>[];

    for (final status in statusOrder) {
      final count = statusCount[status];
      if (count == null || count == 0) continue;

      final percent = count / total * 100;
      final color = colorMap[status] ?? Colors.grey;

      sections.add(
        PieChartSectionData(
          color: color,
          value: count.toDouble(),
          title: '${percent.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.55,
        ),
      );

      legends.add(_LegendItem(
        color: color,
        label: status,
        count: count,
        percent: percent,
      ));
    }

    // Tính tổng bước & trung bình
    final totalSteps = records.fold<int>(0, (sum, r) => sum + r.steps);
    final avgSteps = (totalSteps / total).round();

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
          // Header
          Row(
            children: [
              Icon(Icons.directions_walk, size: 20, color: Colors.blue.shade600),
              const Gap(8),
              Text(
                "Phân bố mức vận động",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const Gap(4),

          // Tổng quan
          Row(
            children: [
              _buildSummaryItem(
                "Trung bình",
                "$avgSteps bước/ngày",
                Colors.blue.shade700,
              ),
              const Gap(16),
              _buildSummaryItem(
                "Tổng bản ghi",
                "$total",
                Colors.grey.shade600,
              ),
            ],
          ),
          const Gap(16),

          // Pie Chart + Legend
          Row(
            children: [
              // Pie Chart
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 20,
                    sectionsSpace: 2,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const Gap(20),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legends
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${item.count} (${item.percent.toStringAsFixed(0)}%)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _LegendItem {
  final Color color;
  final String label;
  final int count;
  final double percent;

  _LegendItem({
    required this.color,
    required this.label,
    required this.count,
    required this.percent,
  });
}
