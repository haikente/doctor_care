import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/presentation/bloc/step_count/step_count_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'dart:math';

class StepCountTargetChart extends StatelessWidget {
  const StepCountTargetChart({super.key});

  static const int _dailyGoal = 10000;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StepCountCubit, StepCountState>(
      builder: (context, state) {
        int totalSteps = 0;
        double distance = 0;
        double calories = 0;

        if (state is StepCountLoaded) {
          final todayRecords = state.records
              .where((r) => _isToday(r.timestamp))
              .toList();
          totalSteps = todayRecords.fold(0, (sum, r) => sum + r.steps);
          distance = todayRecords.fold(
            0.0,
            (sum, r) => sum + (r.distance ?? 0),
          );
          calories = todayRecords.fold(
            0.0,
            (sum, r) => sum + (r.caloriesBurned ?? 0),
          );
        }

        final progress = (totalSteps / _dailyGoal).clamp(0.0, 1.0);
        final progressColor = _getProgressColor(totalSteps);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_walk_rounded,
                      color: progressColor,
                      size: 22,
                    ),
                    const Gap(8),
                    Text(
                      context.tr('today_steps'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    // Circular progress
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: CustomPaint(
                        painter: _CircularProgressPainter(
                          progress: progress,
                          progressColor: progressColor,
                          bgColor: progressColor.withOpacity(0.15),
                          strokeWidth: 12,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(totalSteps),
                                color: progressColor,
                                size: 28,
                              ),
                              const Gap(4),
                              Text(
                                _formatNumber(totalSteps),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.textPrimary(context),
                                ),
                              ),
                              Text(
                                "/ ${_formatNumber(_dailyGoal)}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(24),
                    // Stats
                    Expanded(
                      child: Column(
                        children: [
                          _buildStatRow(
                            context,
                            icon: Icons.local_fire_department_rounded,
                            iconColor: Colors.orange,
                            label: "Calories",
                            value:
                                "${calories.toStringAsFixed(0)} ${context.tr('unit_kcal')}",
                          ),
                          const Gap(16),
                          _buildStatRow(
                            context,
                            icon: Icons.straighten_rounded,
                            iconColor: Colors.blue,
                            label: context.tr('distance'),
                            value:
                                "${distance.toStringAsFixed(1)} ${context.tr('unit_km')}",
                          ),
                          const Gap(16),
                          _buildStatRow(
                            context,
                            icon: Icons.emoji_events_rounded,
                            iconColor: progressColor,
                            label: context.tr('status'),
                            value: _getStatus(context, totalSteps),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}k".replaceAll('.0k', 'k');
    }
    return number.toString();
  }

  Color _getProgressColor(int steps) {
    if (steps < 3000) return Colors.red;
    if (steps < 6000) return Colors.orange;
    if (steps < 10000) return Colors.amber.shade700;
    if (steps < 15000) return Colors.green;
    return Colors.teal;
  }

  String _getStatus(BuildContext context, int steps) {
    if (steps < 3000) return context.tr('step_status_sedentary');
    if (steps < 6000) return context.tr('step_status_light');
    if (steps < 10000) return context.tr('step_status_moderate');
    if (steps < 15000) return context.tr('step_status_good');
    return context.tr('step_status_very_active');
  }

  IconData _getStatusIcon(int steps) {
    if (steps < 3000) return Icons.airline_seat_recline_normal;
    if (steps < 6000) return Icons.directions_walk;
    if (steps < 10000) return Icons.directions_walk;
    if (steps < 15000) return Icons.directions_run;
    return Icons.emoji_events;
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color bgColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
