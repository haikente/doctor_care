import 'dart:io';
import 'package:doctor_care/core/localization/app_localizations.dart';
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
  late TextEditingController _dishNameController;

  @override
  void initState() {
    super.initState();
    _foodItems = List.from(widget.mealAnalysis.foodItems);
    _notesController = TextEditingController(text: widget.mealAnalysis.notes);
    _dishNameController = TextEditingController(
      text: widget.mealAnalysis.dishName,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _dishNameController.dispose();
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
    if (_foodItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('meal_analysis_need_food_item_to_save')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final updatedAnalysis = widget.mealAnalysis.copyWith(
      foodItems: _foodItems,
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
      dishName: _dishNameController.text.trim().isEmpty
          ? null
          : _dishNameController.text.trim(),
    );

    try {
      context.read<MealAnalysisBloc>().add(
        SaveMealAnalysisEvent(updatedAnalysis),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'meal_analysis_save_error',
              params: {'error': e.toString()},
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        title: Text(context.tr('meal_analysis_result_title')),
        centerTitle: true,
      ),
      body: BlocListener<MealAnalysisBloc, MealAnalysisState>(
        listener: (context, state) {
          if (state is MealAnalysisSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('meal_analysis_saved_success')),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is MealAnalysisError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr(
                    'error_with_message',
                    params: {'message': state.message},
                  ),
                ),
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

              // Dish Name Input
              TextField(
                controller: _dishNameController,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: context.tr('dish_name_label'),
                  hintText: context.tr('dish_name_hint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.restaurant),
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
                      Text(
                        context.tr('overview'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            context.tr('total_calories'),
                            '${_totalCalories.toStringAsFixed(0)} kcal',
                            Icons.local_fire_department,
                            Colors.orange,
                          ),
                          _buildSummaryItem(
                            context.tr('glycemic_index'),
                            _averageGI.toStringAsFixed(0),
                            Icons.analytics,
                            _getGIColor(_averageGI),
                          ),
                          _buildSummaryItem(
                            context.tr('meals'),
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
                  Text(
                    context.tr('food_items'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    context.tr('tap_to_edit'),
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
                  return _buildFoodItemCard(
                    foodItem, 
                    index,
                    key: ValueKey('${foodItem.foodName}_$index'),
                  );
                },
              ),

              // Health Recommendations
              if (widget.mealAnalysis.healthRecommendations != null &&
                  widget.mealAnalysis.healthRecommendations!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
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
                            context.tr('health_recommendations'),
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
                        widget.mealAnalysis.healthRecommendations!,
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

              const SizedBox(height: 24),

              // Notes section
              Text(
                context.tr('notes'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: context.tr('notes'),
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
                  icon: const Icon(Icons.save_outlined, size: 24),
                  label: Text(
                    context.tr('save_meal'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
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

  Widget _buildFoodItemCard(
    FoodItem foodItem, 
    int index, {
    Key? key,
  }) {
    return Card(
      key: key,
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
    showDialog(
      context: context,
      builder: (context) => _EditFoodItemDialog(
        foodItem: foodItem,
        onSave: (updatedItem) {
          _updateFoodItem(index, updatedItem);
        },
      ),
    );
  }
}

/// Separate StatefulWidget for edit dialog to properly manage controller lifecycle
class _EditFoodItemDialog extends StatefulWidget {
  final FoodItem foodItem;
  final Function(FoodItem) onSave;

  const _EditFoodItemDialog({
    required this.foodItem,
    required this.onSave,
  });

  @override
  State<_EditFoodItemDialog> createState() => _EditFoodItemDialogState();
}

class _EditFoodItemDialogState extends State<_EditFoodItemDialog> {
  late TextEditingController _portionController;

  @override
  void initState() {
    super.initState();
    _portionController = TextEditingController(
      text: widget.foodItem.portionGrams.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final newPortion = double.tryParse(_portionController.text) ?? 
                      widget.foodItem.portionGrams;
    final ratio = newPortion / widget.foodItem.portionGrams;

    final updatedItem = widget.foodItem.copyWith(
      portionGrams: newPortion,
      calories: widget.foodItem.calories * ratio,
      protein: widget.foodItem.protein * ratio,
      carbs: widget.foodItem.carbs * ratio,
      fat: widget.foodItem.fat * ratio,
      fiber: widget.foodItem.fiber * ratio,
    );

    widget.onSave(updatedItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.tr(
          'edit_food_item',
          params: {'name': widget.foodItem.foodName},
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _portionController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: context.tr('portion_grams_label'),
              border: OutlineInputBorder(),
              suffixText: 'g',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('nutrition_recalc_note'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(context.tr('save')),
        ),
      ],
    );
  }
}
