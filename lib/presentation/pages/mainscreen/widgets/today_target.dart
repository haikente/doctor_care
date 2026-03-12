import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/domain/entities/water_intake.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';
import 'package:doctor_care/presentation/bloc/step_count/step_count_cubit.dart';
import 'package:doctor_care/presentation/bloc/water_intake/water_intake_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class TodayTarget extends StatefulWidget {
  const TodayTarget({super.key});

  @override
  State<TodayTarget> createState() => _TodayTargetState();
}

class _TodayTargetState extends State<TodayTarget> {
  @override
  void initState() {
    super.initState();
    context.read<WaterIntakeBloc>().add(LoadWaterIntakeRecords());
    context.read<StepCountCubit>().loadStepCounts();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Gap(10),
              Text(
               context.tr('today_target'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary(context),
                ),
              ),
            ],
          ),
          const Gap(16),

          // ========== WATER INTAKE TARGET ==========
          BlocBuilder<WaterIntakeBloc, WaterIntakeState>(
            builder: (context, state) {
              int totalWater = 0;
              if (state is WaterIntakeLoaded) {
                final todayRecords = state.records
                    .where((r) => _isToday(r.timestamp))
                    .toList();
                totalWater = todayRecords.fold(0, (sum, r) => sum + r.amount);
              }
              final waterProgress = WaterIntake.getProgressPercent(totalWater);
              return _buildTargetCard(
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blue,
                iconBgColor: Colors.blue.shade50,
                title: context.tr('drink_water'),
                current: "$totalWater",
                goal: context.tr('water_goal'),
                progress: waterProgress / 100,
                progressColor: Colors.blue,
                progressBgColor: Colors.blue.shade100,
              );
            },
          ),
          const Gap(12),

          // ========== STEP COUNT TARGET ==========
          BlocBuilder<StepCountCubit, StepCountState>(
            builder: (context, state) {
              int totalSteps = 0;
              if (state is StepCountLoaded) {
                final todayRecords = state.records
                    .where((r) => _isToday(r.timestamp))
                    .toList();
                totalSteps = todayRecords.fold(0, (sum, r) => sum + r.steps);
              }
              final stepProgress = (totalSteps / 10000).clamp(0.0, 1.0);
              return _buildTargetCard(
                icon: Icons.directions_walk_rounded,
                iconColor: Colors.green,
                iconBgColor: Colors.green.shade50,
                title: context.tr('step_count'),
                current: "$totalSteps",
                goal: context.tr('step_goal'),
                progress: stepProgress,
                progressColor: Colors.green,
                progressBgColor: Colors.green.shade100,
              );
            },
          ),

        const Gap(12),

        // ========== MEAL CALORIES TARGET ==========
        BlocBuilder<MealAnalysisBloc, MealAnalysisState>(
          builder: (context, state) {
            double totalCalories = 0;
            if (state is MealAnalysesLoaded) {
              final todayMeals = state.mealAnalyses
                  .where((r) => _isToday(r.timestamp))
                  .toList();
              totalCalories = todayMeals.fold(
                  0.0, (sum, meal) => sum + meal.totalCalories);
            }
            final calorieProgress = (totalCalories / 2000).clamp(0.0, 1.0);
            return _buildTargetCard(
              icon: Icons.restaurant_menu_rounded,
              iconColor: Colors.orange,
              iconBgColor: Colors.orange.shade50,
              title: context.tr('meal_calories'),
              current: "${totalCalories.toStringAsFixed(0)} ",
              goal: context.tr('calorie_goal'),
              progress: calorieProgress,
              progressColor: Colors.orange,
              progressBgColor: Colors.orange.shade100,
            );
          },
        ),  
        ],
      ),
    );
  }

  Widget _buildTargetCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String current,
    required String goal,
    required double progress,
    required Color progressColor,
    required Color progressBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const Gap(16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: progressBgColor,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const Gap(8),
                Row(
                  children: [
                    Spacer(),
                    Text(
                      current,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      " / $goal",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}