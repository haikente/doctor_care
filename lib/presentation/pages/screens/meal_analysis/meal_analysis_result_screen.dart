import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/domain/entities/food_item.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';

/// Screen displaying AI analysis results with edit capability
class MealAnalysisResultScreen extends StatefulWidget {
  final MealAnalysis mealAnalysis;
  final String imagePath;

  const MealAnalysisResultScreen({
    super.key,
    required this.mealAnalysis,
    required this.imagePath,
  });

  @override
  State<MealAnalysisResultScreen> createState() =>
      _MealAnalysisResultScreenState();
}

class _MealAnalysisResultScreenState extends State<MealAnalysisResultScreen> {
  late List<FoodItem> _foodItems;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _foodItems = List.from(widget.mealAnalysis.foodItems);
    _notesController = TextEditingController(text: widget.mealAnalysis.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateFoodItem(int index, FoodItem updatedItem) {
    setState(() {
      _foodItems[index] = updatedItem;
    });
  }

  void _removeFoodItem(int index) {
    setState(() {
      _foodItems.removeAt(index);
    });
  }

  void _saveMealAnalysis() {
    final updatedAnalysis = widget.mealAnalysis.copyWith(
      foodItems: _foodItems,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    context.read<MealAnalysisBloc>().add(
      SaveMealAnalysisEvent(updatedAnalysis),
    );
  }

  double get _totalCalories {
    return _foodItems.fold(0.0, (sum, item) => sum + item.calories);
  }

  double get _averageGI {
    if (_foodItems.isEmpty) return 0.0;
    double totalWeightedGI = 0.0;
    double totalCarbs = 0.0;

    for (var item in _foodItems) {
      if (item.carbs > 0) {
        totalWeightedGI += item.glycemicIndex * item.carbs;
        totalCarbs += item.carbs;
      }
    }

    return totalCarbs > 0 ? totalWeightedGI / totalCarbs : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả phân tích'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMealAnalysis,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: BlocListener<MealAnalysisBloc, MealAnalysisState>(
        listener: (context, state) {
          if (state is MealAnalysisSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã lưu bữa ăn thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is MealAnalysisError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imagePath),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              // Summary card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tổng quan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            'Tổng calo',
                            '${_totalCalories.toStringAsFixed(0)} kcal',
                            Icons.local_fire_department,
                            Colors.orange,
                          ),
                          _buildSummaryItem(
                            'Chỉ số GI',
                            _averageGI.toStringAsFixed(0),
                            Icons.analytics,
                            _getGIColor(_averageGI),
                          ),
                          _buildSummaryItem(
                            'Món ăn',
                            '${_foodItems.length}',
                            Icons.restaurant,
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Food items list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Danh sách thực phẩm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Chạm để chỉnh sửa',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  final foodItem = _foodItems[index];
                  return _buildFoodItemCard(foodItem, index);
                },
              ),

              const SizedBox(height: 24),

              // Notes section
              const Text(
                'Ghi chú',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Thêm ghi chú về bữa ăn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveMealAnalysis,
                  icon: const Icon(Icons.save, size: 24),
                  label: const Text(
                    'Lưu bữa ăn',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildFoodItemCard(FoodItem foodItem, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEditDialog(foodItem, index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${foodItem.portionGrams.toStringAsFixed(0)}g',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildNutrientChip(
                          '${foodItem.calories.toStringAsFixed(0)} kcal',
                          Colors.orange,
                        ),
                        _buildNutrientChip(
                          'GI: ${foodItem.glycemicIndex}',
                          _getGIColor(foodItem.glycemicIndex.toDouble()),
                        ),
                        _buildNutrientChip(
                          'P: ${foodItem.protein.toStringAsFixed(1)}g',
                          Colors.blue,
                        ),
                        _buildNutrientChip(
                          'C: ${foodItem.carbs.toStringAsFixed(1)}g',
                          Colors.green,
                        ),
                        _buildNutrientChip(
                          'F: ${foodItem.fat.toStringAsFixed(1)}g',
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFoodItem(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getGIColor(double gi) {
    if (gi <= 55) return Colors.green;
    if (gi <= 69) return Colors.orange;
    return Colors.red;
  }

  void _showEditDialog(FoodItem foodItem, int index) {
    final portionController = TextEditingController(
      text: foodItem.portionGrams.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa: ${foodItem.foodName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: portionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Khối lượng (gram)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPortion =
                  double.tryParse(portionController.text) ??
                  foodItem.portionGrams;
              final ratio = newPortion / foodItem.portionGrams;

              final updatedItem = foodItem.copyWith(
                portionGrams: newPortion,
                calories: foodItem.calories * ratio,
                protein: foodItem.protein * ratio,
                carbs: foodItem.carbs * ratio,
                fat: foodItem.fat * ratio,
                fiber: foodItem.fiber * ratio,
              );

              _updateFoodItem(index, updatedItem);
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    portionController.dispose();
  }
}
