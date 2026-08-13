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

  String _getMealTypeLabel(String? mealType) {
    switch (mealType) {
      case 'breakfast':
        return 'Bữa sáng';
      case 'lunch':
        return 'Bữa trưa';
      case 'dinner':
        return 'Bữa tối';
      case 'snack':
        return 'Bữa phụ';
      default:
        return 'Bữa ăn';
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

  void _showMealDetail(BuildContext context, MealAnalysis meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Hero image
                  if (meal.imagePath.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(meal.imagePath),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.restaurant_rounded,
                                size: 64, color: Colors.orange.shade200),
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dish name + time
                        Text(
                          meal.dishName ?? 'Bữa ăn',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 15, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('HH:mm · dd/MM/yyyy')
                                  .format(meal.timestamp),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getGIColor(meal.averageGlycemicIndex)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'GI: ${meal.averageGlycemicIndex.toStringAsFixed(0)} (${meal.giLevel})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getGIColor(
                                      meal.averageGlycemicIndex),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getMealTypeIcon(meal.mealType),
                                size: 18,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Loại bữa: ${_getMealTypeLabel(meal.mealType)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Nutrition summary cards
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade300,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_fire_department_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${meal.totalCalories.toStringAsFixed(0)} kcal',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${meal.foodItems.length} thực phẩm',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildMacroChip(
                                    'Protein',
                                    '${meal.totalProtein.toStringAsFixed(1)}g',
                                    Colors.blue.shade300,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMacroChip(
                                    'Carbs',
                                    '${meal.totalCarbs.toStringAsFixed(1)}g',
                                    Colors.amber.shade300,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMacroChip(
                                    'Chất béo',
                                    '${meal.totalFat.toStringAsFixed(1)}g',
                                    Colors.red.shade300,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMacroChip(
                                    'Chất xơ',
                                    '${meal.totalFiber.toStringAsFixed(1)}g',
                                    Colors.green.shade300,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Health Recommendations
                        if (meal.healthRecommendations != null &&
                            meal.healthRecommendations!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: Colors.green.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.tips_and_updates_rounded,
                                        color: Colors.green.shade700,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Lời khuyên sức khỏe',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  meal.healthRecommendations!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade900,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Food items list
                        const Text(
                          'Thành phần thực phẩm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...meal.foodItems
                            .map((food) => _buildFoodItemDetail(food)),

                        // Notes
                        if (meal.notes != null &&
                            meal.notes!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.notes_rounded,
                                        size: 18,
                                        color: Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ghi chú',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  meal.notes!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Delete button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _confirmDelete(context, meal.id!),
                            icon: Icon(Icons.delete_outline_rounded,
                                color: Colors.red.shade400, size: 20),
                            label: Text(
                              'Xóa bữa ăn',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.red.shade200, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMacroChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildFoodItemDetail(food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.lunch_dining_outlined,
                color: Colors.blue.shade400, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.foodName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${food.portionGrams.toStringAsFixed(0)}g · ${food.calories.toStringAsFixed(0)} kcal · GI: ${food.glycemicIndex}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildMiniTag(
                        'P ${food.protein.toStringAsFixed(1)}g', Colors.blue),
                    const SizedBox(width: 4),
                    _buildMiniTag(
                        'C ${food.carbs.toStringAsFixed(1)}g', Colors.amber.shade700),
                    const SizedBox(width: 4),
                    _buildMiniTag(
                        'F ${food.fat.toStringAsFixed(1)}g', Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTag(String text, Color color) {
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
