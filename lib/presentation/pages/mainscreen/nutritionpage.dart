import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';
import 'package:doctor_care/presentation/pages/mainscreen/trackmeal.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/calorie_chart.dart';
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

  String formatDate(DateTime date){
    return "Thứ ${["Hai", "Ba", "Tư", "Năm", "Sáu", "Bảy", "Chủ nhật"][date.weekday - 1]}, "
          "${date.day.toString().padLeft(2, '0')} Tháng "
          "${date.month.toString().padLeft(2, '0')}";
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Gap(25),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                      // boxShadow: [
                      //   BoxShadow(
                      //     // ignore: deprecated_member_use
                      //     color: Colors.blue.withOpacity(0.15),
                      //     blurRadius: 12,
                      //     offset: Offset(0, 5),
                      //   ),
                      // ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatDate(DateTime.now()), style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.5),
                        )),
                        Gap(2),
                        Text("Dinh dưỡng",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                    onTap: () =>  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TrackMeal())),
                      // ignore: deprecated_member_use
                      child: Icon(Icons.history, color: Colors.black.withOpacity(0.8), size: 22,)),
                  ],
                 ),
              ),  

              const Gap(20),
              const CalorieChart(),
              //phân bổ dinh dưỡng
              Gap(10),
              Row(
                children: [
                  Text("Phân bổ dinh dưỡng", style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary(context)
                   )
                  ),
                ],
              ),
              Gap(10),
              
              BlocBuilder<MealAnalysisBloc, MealAnalysisState>(
                builder: (context, state){
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
                          title: "Protein",
                          current: "${totalProtein.toStringAsFixed(0)}g",
                          goal: "100g",
                          progress: (totalProtein / 100).clamp(0, 1),
                          progressColor: Colors.blue,
                          progressBgColor: Colors.blue.shade50,
                        ),
                      
                      Gap(10),
                        _buildMealCard(
                          title: "Carbs",
                          current: "${totalCarbs.toStringAsFixed(0)}g",
                          goal: "250g",
                          progress: (totalCarbs / 250).clamp(0, 1),
                          progressColor: Colors.orange,
                          progressBgColor: Colors.orange.shade50,
                        ),

                      Gap(10),
                        _buildMealCard(
                          title: "Chất béo",
                          current: "${totalFat.toStringAsFixed(0)}g",
                          goal: "60g",
                          progress: (totalFat / 60).clamp(0, 1),
                          progressColor: Colors.red,
                          progressBgColor: Colors.red.shade50,
                        ),  
                    ],
                  );
                }
              ),
              Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Bữa ăn hôm nay", style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary(context))),
                    Spacer(),  
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TrackMeal(),));
                      },
                      child: Text("Thêm món",
                        style: TextStyle(color: Colors.blue.shade600, fontSize: 14),),
                    ),
                    Icon(Icons.arrow_forward_outlined, size: 13, color: Colors.blue.shade600,)  
                  ],
                ),
              const Gap(10),
              // Danh sách bữa ăn hôm nay
              BlocBuilder<MealAnalysisBloc, MealAnalysisState>(
                builder: (context, state) {
                  if (state is MealAnalysesLoaded) {
                    final todayMeals = state.mealAnalyses
                        .where((meal) => _isToday(meal.timestamp))
                        .toList()
                      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                    if (todayMeals.isEmpty) {
                      return _buildEmptyMealState();
                    }

                    return Column(
                      children: todayMeals
                          .map((meal) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildMealItem(meal),
                              ))
                          .toList(),
                    );
                  }
                  return _buildEmptyMealState();
                },
              ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    Container(width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: progressColor,
                      shape: BoxShape.circle
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
                    minHeight: 8,
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.restaurant_menu_rounded,
              size: 48, color: Colors.grey.shade300),
          const Gap(12),
          Text(
            "Chưa có bữa ăn nào hôm nay",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const Gap(4),
          Text(
            "Chụp ảnh món ăn để phân tích dinh dưỡng",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    child: Icon(Icons.fastfood_rounded,
                        color: Colors.orange.shade300, size: 28),
                  ),
          ),
          const Gap(14),
          // Thông tin bữa ăn
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.dishName ?? "Bữa ăn",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  "${meal.foodItems.length} món · $time",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Gap(6),
                Row(
                  children: [
                    _buildMacroTag(
                        "${meal.totalCalories.toStringAsFixed(0)} kcal",
                        Colors.deepOrange),
                    const Gap(6),
                    _buildMacroTag(
                        "P ${meal.totalProtein.toStringAsFixed(0)}g",
                        Colors.blue),
                    const Gap(6),
                    _buildMacroTag(
                        "C ${meal.totalCarbs.toStringAsFixed(0)}g",
                        Colors.orange),
                    const Gap(6),
                    _buildMacroTag(
                        "F ${meal.totalFat.toStringAsFixed(0)}g",
                        Colors.red),
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
}