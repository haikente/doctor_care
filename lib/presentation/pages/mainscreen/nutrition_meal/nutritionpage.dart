import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/presentation/bloc/health_goal/health_goal_cubit.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';
import 'package:doctor_care/presentation/pages/mainscreen/nutrition_meal/insert_dish.dart';
import 'package:doctor_care/presentation/pages/mainscreen/nutrition_meal/trackmeal.dart';
import 'package:doctor_care/presentation/pages/mainscreen/nutrition_meal/widgets/calorie_chart.dart';
import 'package:doctor_care/presentation/pages/screens/meal_analysis/meal_suggestion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'dart:io';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  String formatDate(BuildContext context, DateTime date) {
    final isVi = context.l10n.languageCode == 'vi';
    final weekdayKeys = [
      'weekday_mon',
      'weekday_tue',
      'weekday_wed',
      'weekday_thu',
      'weekday_fri',
      'weekday_sat',
      'weekday_sun',
    ];
    final weekday = context.tr(weekdayKeys[date.weekday - 1]);

    if (isVi) {
      return "$weekday, ${date.day.toString().padLeft(2, '0')} ${context.tr('month')} ${date.month.toString().padLeft(2, '0')}";
    }

    return "$weekday, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final dailyCalories = context.select(
      (HealthGoalCubit cubit) => cubit.state.dailyCalories.toDouble(),
    );
    final proteinGoal = dailyCalories * 0.20 / 4;
    final carbsGoal = dailyCalories * 0.50 / 4;
    final fatGoal = dailyCalories * 0.30 / 9;

    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDate(context, DateTime.now()),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColor.textSecondary(context),
                          ),
                        ),
                        Gap(2),
                        Text(
                          context.tr('nutrition'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrackMeal(),
                        ),
                      ),
                      child: Icon(
                        Icons.history,
                        color: AppColor.textPrimary(context),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(20),
              const CalorieChart(),

              // AI Gợi ý bữa ăn card
              const Gap(16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MealSuggestionScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.teal.shade400],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('meal_suggestion_ai_title'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              context.tr('meal_suggestion_ai_subtitle'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              //phân bổ dinh dưỡng
              Gap(20),
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
                    context.tr('nutrition_distribution'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary(context),
                    ),
                  ),
                ],
              ),
              Gap(20),

              BlocBuilder<MealAnalysisBloc, MealAnalysisState>(
                builder: (context, state) {
                  double totalProtein = 0;
                  double totalCarbs = 0;
                  double totalFat = 0;
                  if (state is MealAnalysesLoaded) {
                    final todayMeals = state.mealAnalyses
                        .where((meal) => _isToday(meal.timestamp))
                        .toList();
                    totalProtein = todayMeals.fold<double>(
                      0,
                      (sum, meal) => sum + meal.totalProtein,
                    );
                    totalCarbs = todayMeals.fold(
                      0,
                      (sum, meal) => sum + meal.totalCarbs,
                    );
                    totalFat = todayMeals.fold(
                      0,
                      (sum, meal) => sum + meal.totalFat,
                    );
                  }
                  return Column(
                    children: [
                      _buildMealCard(
                        title: context.tr('protein'),
                        current: "${totalProtein.toStringAsFixed(0)}g",
                        goal: "${proteinGoal.toStringAsFixed(0)}g",
                        progress: (totalProtein / proteinGoal)
                            .clamp(0.0, 1.0)
                            .toDouble(),
                        progressColor: Colors.blue,
                        progressBgColor: Colors.blue.shade50,
                      ),

                      Gap(10),
                      _buildMealCard(
                        title: context.tr('carbs'),
                        current: "${totalCarbs.toStringAsFixed(0)}g",
                        goal: "${carbsGoal.toStringAsFixed(0)}g",
                        progress: (totalCarbs / carbsGoal)
                            .clamp(0.0, 1.0)
                            .toDouble(),
                        progressColor: Colors.orange,
                        progressBgColor: Colors.orange.shade50,
                      ),

                      Gap(10),
                      _buildMealCard(
                        title: context.tr('fat'),
                        current: "${totalFat.toStringAsFixed(0)}g",
                        goal: "${fatGoal.toStringAsFixed(0)}g",
                        progress: (totalFat / fatGoal)
                            .clamp(0.0, 1.0)
                            .toDouble(),
                        progressColor: Colors.red,
                        progressBgColor: Colors.red.shade50,
                      ),
                    ],
                  );
                },
              ),
              Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    context.tr('today_meals'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary(context),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InsertDish()),
                      );
                    },
                    child: Text(
                      context.tr('add_new_dish'),
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_outlined,
                    size: 13,
                    color: Colors.blue.shade600,
                  ),
                ],
              ),
              const Gap(10),
              // Danh sách bữa ăn hôm nay
              BlocBuilder<MealAnalysisBloc, MealAnalysisState>(
                builder: (context, state) {
                  if (state is MealAnalysesLoaded) {
                    final todayMeals =
                        state.mealAnalyses
                            .where((meal) => _isToday(meal.timestamp))
                            .toList()
                          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                    if (todayMeals.isEmpty) {
                      return _buildEmptyMealState();
                    }

                    return Column(
                      children: todayMeals
                          .map(
                            (meal) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildMealItem(meal),
                            ),
                          )
                          .toList(),
                    );
                  }
                  return _buildEmptyMealState();
                },
              ),
              Gap(100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard({
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
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: progressColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Gap(8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColor.textPrimary(context),
                      ),
                    ),
                    Spacer(),
                    Text(
                      "$current/$goal",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Gap(20),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMealState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const Gap(12),
          Text(
            context.tr('no_meals_today_full'),
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const Gap(4),
          Text(
            context.tr('capture_meal_to_analyze'),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(MealAnalysis meal) {
    final time =
        "${meal.timestamp.hour.toString().padLeft(2, '0')}:${meal.timestamp.minute.toString().padLeft(2, '0')}";
    final hasImage =
        meal.imagePath.isNotEmpty && File(meal.imagePath).existsSync();
    final mealTypeLabel = _getMealTypeLabel(meal.mealType);
    final foodCount = context.tr(
      'food_count',
      params: {'count': '${meal.foodItems.length}'},
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Ảnh món ăn
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasImage
                ? Image.file(
                    File(meal.imagePath),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: Colors.orange.shade50,
                    child: Icon(
                      Icons.fastfood_rounded,
                      color: Colors.orange.shade300,
                      size: 28,
                    ),
                  ),
          ),
          const Gap(14),
          // Thông tin bữa ăn
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.dishName ?? context.tr('default_meal_name'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(
                      _getMealTypeIcon(meal.mealType),
                      size: 14,
                      color: Colors.blue.shade500,
                    ),
                    const Gap(4),
                    Flexible(
                      child: Text(
                        "$mealTypeLabel - $foodCount - $time",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Gap(6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildMacroTag(
                      "${meal.totalCalories.toStringAsFixed(0)} kcal",
                      Colors.deepOrange,
                    ),
                    _buildMacroTag(
                      "P ${meal.totalProtein.toStringAsFixed(0)}g",
                      Colors.blue,
                    ),
                    _buildMacroTag(
                      "C ${meal.totalCarbs.toStringAsFixed(0)}g",
                      Colors.orange,
                    ),
                    _buildMacroTag(
                      "F ${meal.totalFat.toStringAsFixed(0)}g",
                      Colors.red,
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

  Widget _buildMacroTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _getMealTypeLabel(String? mealType) {
    switch (mealType) {
      case 'breakfast':
        return context.tr('meal_suggestion_breakfast');
      case 'lunch':
        return context.tr('meal_suggestion_lunch');
      case 'dinner':
        return context.tr('meal_suggestion_dinner');
      case 'snack':
        return context.tr('meal_suggestion_snack');
      default:
        return context.tr('default_meal_name');
    }
  }

  IconData _getMealTypeIcon(String? mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.free_breakfast_rounded;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'dinner':
        return Icons.dinner_dining_rounded;
      case 'snack':
        return Icons.fastfood_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }
}
