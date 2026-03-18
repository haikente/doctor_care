import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/domain/entities/step_count.dart';
import 'package:doctor_care/domain/entities/water_intake.dart';
import 'package:doctor_care/domain/entities/sleep_record.dart';
import 'package:doctor_care/domain/entities/spO2heartrate.dart';
import 'package:doctor_care/presentation/bloc/step_count/step_count_cubit.dart';
import 'package:doctor_care/presentation/bloc/water_intake/water_intake_bloc.dart';
import 'package:doctor_care/presentation/bloc/sleep_record/sleep_record_cubit.dart';
import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeeklyActivityChart extends StatelessWidget {
  const WeeklyActivityChart({super.key});

  /// Calculate daily activity scores for the last 7 days.
  /// Each day gets a score 0-1 based on how well health goals were met.
  static List<double> _calculateWeeklyScores({
    required List<StepCount> stepRecords,
    required List<WaterIntake> waterRecords,
    required List<SleepRecord> sleepRecords,
    required List<SpO2HeartRate> heartRecords,
  }) {
    final now = DateTime.now();
    // Get Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final scores = <double>[];

    for (int i = 0; i < 7; i++) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      double score = 0.0;
      int metrics = 0;

      // Steps goal: 10000
      final daySteps = stepRecords
          .where((r) => _isSameDay(r.timestamp, day))
          .fold<int>(0, (sum, r) => sum + r.steps);
      if (daySteps > 0) {
        score += (daySteps / 10000).clamp(0.0, 1.0);
        metrics++;
      }

      // Water goal: 2000ml
      final dayWater = waterRecords
          .where((r) => _isSameDay(r.timestamp, day))
          .fold<int>(0, (sum, r) => sum + r.amount);
      if (dayWater > 0) {
        score += (dayWater / 2000).clamp(0.0, 1.0);
        metrics++;
      }

      // Sleep goal: 8 hours
      final daySleep = sleepRecords
          .where((r) => _isSameDay(r.timestamp, day))
          .toList();
      if (daySleep.isNotEmpty) {
        final hours = daySleep.first.durationHours;
        score += (hours / 8.0).clamp(0.0, 1.0);
        metrics++;
      }

      // Heart rate: has data = good
      final dayHeart = heartRecords
          .where((r) => _isSameDay(r.timestamp, day))
          .toList();
      if (dayHeart.isNotEmpty) {
        // Normal heart rate (60-100) scores higher
        final hr = dayHeart.first.heartRate;
        if (hr >= 60 && hr <= 100) {
          score += 1.0;
        } else {
          score += 0.5;
        }
        metrics++;
      }

      // Average score across available metrics
      if (metrics > 0) {
        scores.add(score / metrics);
      } else {
        scores.add(0.0);
      }
    }

    return scores;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StepCountCubit, StepCountState>(
      builder: (context, stepState) {
        return BlocBuilder<WaterIntakeBloc, WaterIntakeState>(
          builder: (context, waterState) {
            return BlocBuilder<SleepRecordCubit, SleepRecordState>(
              builder: (context, sleepState) {
                return BlocBuilder<Spo2heartrateBloc, Spo2heartrateState>(
                  builder: (context, heartState) {
                    final stepRecords = stepState is StepCountLoaded
                        ? stepState.records
                        : <StepCount>[];
                    final waterRecords = waterState is WaterIntakeLoaded
                        ? waterState.records
                        : <WaterIntake>[];
                    final sleepRecords = sleepState is SleepRecordLoaded
                        ? sleepState.records
                        : <SleepRecord>[];
                    final heartRecords = heartState is Spo2heartrateLoaded
                        ? heartState.records
                        : <SpO2HeartRate>[];

                    final scores = _calculateWeeklyScores(
                      stepRecords: stepRecords,
                      waterRecords: waterRecords,
                      sleepRecords: sleepRecords,
                      heartRecords: heartRecords,
                    );

                    return _ChartContainer(scores: scores);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final List<double> scores;
  const _ChartContainer({required this.scores});

  @override
  Widget build(BuildContext context) {
    // Count days with data
    final activeDays = scores.where((s) => s > 0).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('weekly_activity'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeDays > 0
                        ? context.tr(
                            'active_days_recorded',
                            params: {'days': activeDays.toString()},
                          )
                        : context.tr('no_data_this_week'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  context.tr('this_week'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: const Size(double.infinity, 140),
              painter: _BarChartPainter(context: context, values: scores),
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: const Color(0xFF1E88E5),
                label: context.tr('target_reached'),
              ),
              const SizedBox(width: 20),
              _LegendItem(
                color: const Color(0xFF1E88E5).withOpacity(0.3),
                label: context.tr('target'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final BuildContext context;
  final List<String> days;
  final List<double> values;

  _BarChartPainter({required this.context, required this.values})
    : days = [
        context.tr('day_mon'),
        context.tr('day_tue'),
        context.tr('day_wed'),
        context.tr('day_thu'),
        context.tr('day_fri'),
        context.tr('day_sat'),
        context.tr('day_sun'),
      ];

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (days.length * 2.2);
    final maxBarHeight = size.height - 30;
    final spacing = (size.width - barWidth * days.length) / (days.length + 1);

    for (int i = 0; i < days.length; i++) {
      final x = spacing + i * (barWidth + spacing);
      final barHeight = maxBarHeight * values[i];
      final isToday = i == DateTime.now().weekday - 1;

      // Background bar (target)
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, barWidth, maxBarHeight),
        const Radius.circular(6),
      );
      final bgPaint = Paint()
        ..color = const Color(0xFF1E88E5).withOpacity(0.08);
      canvas.drawRRect(bgRect, bgPaint);

      // Value bar (only draw if there's data)
      if (barHeight > 0) {
        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, maxBarHeight - barHeight, barWidth, barHeight),
          const Radius.circular(6),
        );

        final barPaint = Paint()
          ..shader =
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isToday
                    ? [const Color(0xFF42A5F5), const Color(0xFF1E88E5)]
                    : [
                        const Color(0xFF1E88E5).withOpacity(0.5),
                        const Color(0xFF1E88E5).withOpacity(0.7),
                      ],
              ).createShader(
                Rect.fromLTWH(x, maxBarHeight - barHeight, barWidth, barHeight),
              );

        canvas.drawRRect(barRect, barPaint);
      }

      // Today indicator dot
      if (isToday) {
        final dotPaint = Paint()..color = const Color(0xFF1E88E5);
        canvas.drawCircle(
          Offset(x + barWidth / 2, maxBarHeight + 12),
          3,
          dotPaint,
        );
      }

      // Day label
      final textPainter = TextPainter(
        text: TextSpan(
          text: days[i],
          style: TextStyle(
            color: isToday ? const Color(0xFF1E88E5) : Colors.grey.shade500,
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, maxBarHeight + 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
