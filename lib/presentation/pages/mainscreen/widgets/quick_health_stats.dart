import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:doctor_care/presentation/bloc/sleep_record/sleep_record_cubit.dart';
import 'package:doctor_care/presentation/bloc/step_count/step_count_cubit.dart';
import 'package:doctor_care/presentation/bloc/water_intake/water_intake_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickHealthStats extends StatelessWidget {
  const QuickHealthStats({super.key});

  /// Check if a DateTime is today
  static bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // --- Bước chân ---
          BlocBuilder<StepCountCubit, StepCountState>(
            builder: (context, state) {
              String value = '--';
              double progress = 0.0;
              if (state is StepCountLoaded && state.records.isNotEmpty) {
                final todayRecords = state.records
                    .where((r) => _isToday(r.timestamp))
                    .toList();
                if (todayRecords.isNotEmpty) {
                  final totalSteps = todayRecords.fold<int>(
                    0,
                    (sum, r) => sum + r.steps,
                  );
                  value = _formatNumber(totalSteps);
                  progress = (totalSteps / 10000).clamp(0.0, 1.0);
                }
              }
              return _StatCard(
                icon: Icons.directions_walk_rounded,
                label: 'Bước chân',
                value: value,
                unit: 'bước',
                color: const Color(0xFF2E7D32),
                progress: progress,
              );
            },
          ),
          const SizedBox(width: 12),

          // --- Nước uống ---
          BlocBuilder<WaterIntakeBloc, WaterIntakeState>(
            builder: (context, state) {
              String value = '--';
              double progress = 0.0;
              if (state is WaterIntakeLoaded && state.records.isNotEmpty) {
                final todayRecords = state.records
                    .where((r) => _isToday(r.timestamp))
                    .toList();
                if (todayRecords.isNotEmpty) {
                  final totalMl = todayRecords.fold<int>(
                    0,
                    (sum, r) => sum + r.amount,
                  );
                  value = _formatNumber(totalMl);
                  progress = (totalMl / 2000).clamp(0.0, 1.0);
                }
              }
              return _StatCard(
                icon: Icons.local_drink_outlined,
                label: 'Nước uống',
                value: value,
                unit: 'ml',
                color: const Color(0xFF039BE5),
                progress: progress,
              );
            },
          ),
          const SizedBox(width: 12),

          // --- Giấc ngủ ---
          BlocBuilder<SleepRecordCubit, SleepRecordState>(
            builder: (context, state) {
              String value = '--';
              double progress = 0.0;
              if (state is SleepRecordLoaded && state.records.isNotEmpty) {
                // Lấy record mới nhất hôm nay hoặc đêm qua
                final todayRecords = state.records
                    .where((r) => _isToday(r.timestamp))
                    .toList();
                if (todayRecords.isNotEmpty) {
                  final latest = todayRecords.first;
                  final hours = latest.durationHours;
                  value = hours.toStringAsFixed(1);
                  progress = (hours / 8.0).clamp(0.0, 1.0); // goal: 8 hours
                }
              }
              return _StatCard(
                icon: Icons.bedtime_outlined,
                label: 'Giấc ngủ',
                value: value,
                unit: 'giờ',
                color: const Color(0xFF3949AB),
                progress: progress,
              );
            },
          ),
          const SizedBox(width: 12),

          // --- Nhịp tim ---
          BlocBuilder<Spo2heartrateBloc, Spo2heartrateState>(
            builder: (context, state) {
              String value = '--';
              double progress = 0.0;
              if (state is Spo2heartrateLoaded && state.records.isNotEmpty) {
                final todayRecords = state.records
                    .where((r) => _isToday(r.timestamp))
                    .toList();
                if (todayRecords.isNotEmpty) {
                  final latest = todayRecords.first;
                  value = latest.heartRate.toString();
                  // Normal range: 60-100 bpm, normalize to 0-1
                  progress = (latest.heartRate / 100).clamp(0.0, 1.0);
                }
              }
              return _StatCard(
                icon: Icons.favorite_border_rounded,
                label: 'Nhịp tim',
                value: value,
                unit: 'bpm',
                color: const Color(0xFFE53935),
                progress: progress,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Format large numbers with dots (e.g. 10000 -> 10.000)
  static String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final double progress; // 0.0 to 1.0

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
