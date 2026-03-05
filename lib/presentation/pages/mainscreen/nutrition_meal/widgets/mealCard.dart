import 'dart:io';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart' show MealAnalysisBloc;
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class Mealcard {
  Widget buildMealCard(BuildContext context, MealAnalysis meal) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMealDetail(context, meal),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (meal.imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.file(
                  File(meal.imagePath),
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(meal.timestamp),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Món ăn: ${meal.dishName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        Icons.local_fire_department,
                        '${meal.totalCalories.toStringAsFixed(0)} kcal',
                        Colors.orange,
                      ),
                      _buildStatItem(
                        Icons.analytics,
                        'GI: ${meal.averageGlycemicIndex.toStringAsFixed(0)}',
                        _getGIColor(meal.averageGlycemicIndex),
                      ),
                      _buildStatItem(
                        Icons.restaurant,
                        '${meal.foodItems.length} thực phẩm',
                        Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: meal.foodItems.take(3).map((food) {
                      return Chip(
                        side: BorderSide(color: Colors.blue),
                        label: Text(
                          food.foodName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.blue[50],
                      );
                    }).toList(),
                  ),

                  if (meal.foodItems.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${meal.foodItems.length - 3} món khác',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

    Color _getGIColor(double gi) {
    if (gi <= 55) return Colors.green;
    if (gi <= 69) return Colors.orange;
    return Colors.red;
  }

    void _showMealDetail(BuildContext context, MealAnalysis meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Image
                if (meal.imagePath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(meal.imagePath),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),

                // Health Recommendations
                if (meal.healthRecommendations != null &&
                    meal.healthRecommendations!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.health_and_safety,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lời khuyên sức khỏe',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meal.healthRecommendations!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green.shade900,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Date
                Text(
                  DateFormat(
                    'EEEE, dd MMMM yyyy HH:mm',
                    'vi',
                  ).format(meal.timestamp),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Nutrition summary
                const Text(
                  'Tổng quan dinh dưỡng',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildNutritionRow(
                          'Tổng calo',
                          '${meal.totalCalories.toStringAsFixed(0)} kcal',
                        ),
                        const Divider(),
                        _buildNutritionRow(
                          'Protein',
                          '${meal.totalProtein.toStringAsFixed(1)}g',
                        ),
                        const Divider(),
                        _buildNutritionRow(
                          'Carbs',
                          '${meal.totalCarbs.toStringAsFixed(1)}g',
                        ),
                        const Divider(),
                        _buildNutritionRow(
                          'Chất béo',
                          '${meal.totalFat.toStringAsFixed(1)}g',
                        ),
                        const Divider(),
                        _buildNutritionRow(
                          'Chất xơ',
                          '${meal.totalFiber.toStringAsFixed(1)}g',
                        ),
                        const Divider(),
                        _buildNutritionRow(
                          'Chỉ số GI trung bình',
                          '${meal.averageGlycemicIndex.toStringAsFixed(0)} (${meal.giLevel})',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Danh sách thực phẩm',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...meal.foodItems.map((food) => _buildFoodItemDetail(food)),

                if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Ghi chú',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(meal.notes!),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Delete button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _confirmDelete(context, meal.id!);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Xóa bữa ăn',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

   Widget _buildNutritionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

    Widget _buildFoodItemDetail(food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food.foodName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Khối lượng: ${food.portionGrams.toStringAsFixed(0)}g'),
            Text('Calo: ${food.calories.toStringAsFixed(0)} kcal'),
            Text('GI: ${food.glycemicIndex}'),
            Text(
              'Protein: ${food.protein.toStringAsFixed(1)}g | Carbs: ${food.carbs.toStringAsFixed(1)}g | Fat: ${food.fat.toStringAsFixed(1)}g',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int mealId) {
    AppDialog.showDeleteConfirm(
      context: context,
      onConfirm: () {
        Navigator.pop(context);
        context.read<MealAnalysisBloc>().add(DeleteMealAnalysisEvent(mealId));
      },
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa bữa ăn này?',
    );
  }
}