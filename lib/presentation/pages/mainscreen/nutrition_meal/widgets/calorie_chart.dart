import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'dart:math';

class CalorieChart extends StatefulWidget {
  const CalorieChart({super.key});

  @override
  State<CalorieChart> createState() => _CalorieChartState();
}

class _CalorieChartState extends State<CalorieChart> {
  static const double _dailyGoal = 2000; // kcal

  @override
  void initState() {
    super.initState();
    context.read<MealAnalysisBloc>().add(const LoadMealAnalysesEvent());
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Color _getProgressColor(double calories) {
  //   if (calories >= _dailyGoal) return Colors.green;
  //   if (calories >= _dailyGoal * 0.75) return Colors.lightGreen;
  //   if (calories >= _dailyGoal * 0.5) return Colors.amber;
  //   if (calories >= _dailyGoal * 0.25) return Colors.orange;
  //   return Colors.red;
  // }

  IconData _getStatusIcon(double calories) {
    if (calories >= _dailyGoal) return Icons.check_circle_rounded;
    if (calories >= _dailyGoal * 0.75) return Icons.trending_up_rounded;
    if (calories >= _dailyGoal * 0.5) return Icons.horizontal_rule_rounded;
    return Icons.trending_down_rounded;
  }

  // String _getStatus(double calories) {
  //   if (calories >= _dailyGoal) return "Hoàn thành";
  //   if (calories >= _dailyGoal * 0.75) return "Gần đạt";
  //   if (calories >= _dailyGoal * 0.5) return "Trung bình";
  //   if (calories >= _dailyGoal * 0.25) return "Cần cải thiện";
  //   return "Bắt đầu";
  // }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}k";
    }
    return number.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealAnalysisBloc, MealAnalysisState>(
      builder: (context, state) {
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;

        if (state is MealAnalysesLoaded) {
          final todayMeals = state.mealAnalyses
              .where((meal) => _isToday(meal.timestamp))
              .toList();

          for (var meal in todayMeals) {
            totalCalories += meal.totalCalories;
            totalProtein += meal.totalProtein;
            totalCarbs += meal.totalCarbs;
            totalFat += meal.totalFat;
          }
        }

        final progress = (totalCalories / _dailyGoal).clamp(0.0, 1.0);
        ///final progressColor = _getProgressColor(totalCalories);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            padding: const EdgeInsets.all(20),
           decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.06),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant_rounded,
                        color: Colors.blue, size: 22),
                    const Gap(8),
                    Text(
                      "Calories hôm nay",
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
                          progressColor: Colors.blue,
                          bgColor: Colors.blue.withOpacity(0.15),
                          strokeWidth: 12,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(totalCalories),
                                color: Colors.blue,
                                size: 28,
                              ),
                              const Gap(4),
                              Text(
                                _formatNumber(totalCalories),
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
                            icon: Icons.fitness_center_rounded,
                            iconColor: Colors.blue,
                            label: "Protein",
                            value: "${totalProtein.toStringAsFixed(1)}g",
                          ),
                          const Gap(16),
                          _buildStatRow(
                            context,
                            icon: Icons.bakery_dining_rounded,
                            iconColor: Colors.amber,
                            label: "Carbs",
                            value: "${totalCarbs.toStringAsFixed(1)}g",
                          ),
                          const Gap(16),
                          _buildStatRow(
                            context,
                            icon: Icons.water_drop_rounded,
                            iconColor: Colors.red,
                            label: "Chất béo",
                            value: "${totalFat.toStringAsFixed(1)}g",
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
            borderRadius: BorderRadius.circular(8),
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
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
