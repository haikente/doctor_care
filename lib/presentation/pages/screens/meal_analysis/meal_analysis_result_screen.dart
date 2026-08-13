import 'dart:io';

import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/domain/entities/food_item.dart';
import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class MealAnalysisResultScreen extends StatefulWidget {
  const MealAnalysisResultScreen({
    super.key,
    required this.mealAnalysis,
    required this.imagePath,
  });

  final MealAnalysis mealAnalysis;
  final String imagePath;

  @override
  State<MealAnalysisResultScreen> createState() =>
      _MealAnalysisResultScreenState();
}

class _MealAnalysisResultScreenState extends State<MealAnalysisResultScreen> {
  late final TextEditingController _dishNameController;
  late final TextEditingController _notesController;
  late List<FoodItem> _foodItems;
  late String _selectedMealType;

  static const List<_MealTypeOption> _mealTypeOptions = [
    _MealTypeOption(
      value: 'breakfast',
      labelKey: 'meal_suggestion_breakfast',
      icon: Icons.free_breakfast_rounded,
    ),
    _MealTypeOption(
      value: 'lunch',
      labelKey: 'meal_suggestion_lunch',
      icon: Icons.lunch_dining_rounded,
    ),
    _MealTypeOption(
      value: 'dinner',
      labelKey: 'meal_suggestion_dinner',
      icon: Icons.dinner_dining_rounded,
    ),
    _MealTypeOption(
      value: 'snack',
      labelKey: 'meal_suggestion_snack',
      icon: Icons.fastfood_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _foodItems = List<FoodItem>.from(widget.mealAnalysis.foodItems);
    _dishNameController = TextEditingController(
      text: widget.mealAnalysis.dishName,
    );
    _notesController = TextEditingController(text: widget.mealAnalysis.notes);
    _selectedMealType = _resolveInitialMealType(widget.mealAnalysis.mealType);
  }

  @override
  void dispose() {
    _dishNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalCalories {
    return _foodItems.fold(0.0, (sum, item) => sum + item.calories);
  }

  double get _totalProtein {
    return _foodItems.fold(0.0, (sum, item) => sum + item.protein);
  }

  double get _totalCarbs {
    return _foodItems.fold(0.0, (sum, item) => sum + item.carbs);
  }

  double get _totalFat {
    return _foodItems.fold(0.0, (sum, item) => sum + item.fat);
  }

  double get _averageGI {
    if (_foodItems.isEmpty) return 0.0;

    var weightedGI = 0.0;
    var totalCarbs = 0.0;

    for (final item in _foodItems) {
      if (item.carbs <= 0) continue;
      weightedGI += item.glycemicIndex * item.carbs;
      totalCarbs += item.carbs;
    }

    return totalCarbs == 0 ? 0.0 : weightedGI / totalCarbs;
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
      dishName: _nullableText(_dishNameController.text),
      mealType: _selectedMealType,
      notes: _nullableText(_notesController.text),
    );

    context.read<MealAnalysisBloc>().add(SaveMealAnalysisEvent(updatedAnalysis));
  }

  void _removeFoodItem(int index) {
    setState(() {
      _foodItems.removeAt(index);
    });
  }

  void _updateFoodItem(int index, FoodItem updatedItem) {
    setState(() {
      _foodItems[index] = updatedItem;
    });
  }

  String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _resolveInitialMealType(String? mealType) {
    final exists = _mealTypeOptions.any((option) => option.value == mealType);
    if (exists) return mealType!;
    return _defaultMealTypeFor(DateTime.now());
  }

  String _defaultMealTypeFor(DateTime now) {
    final hour = now.hour;
    if (hour < 10) return 'breakfast';
    if (hour < 14) return 'lunch';
    if (hour < 20) return 'dinner';
    return 'snack';
  }

  Color _giColor(double gi) {
    if (gi <= 55) return Colors.green;
    if (gi <= 69) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomStackAppBar(
        title: context.tr('meal_analysis_result_title'),
        centerTitle: true,
        onBack: () => Navigator.pop(context),
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
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MealImagePreview(imagePath: widget.imagePath),
                const Gap(18),
                _DishDetailsSection(
                  dishNameController: _dishNameController,
                  selectedMealType: _selectedMealType,
                  mealTypeOptions: _mealTypeOptions,
                  onMealTypeChanged: (value) {
                    setState(() {
                      _selectedMealType = value;
                    });
                  },
                ),
                const Gap(18),
                _OverviewCard(
                  totalCalories: _totalCalories,
                  averageGI: _averageGI,
                  foodCount: _foodItems.length,
                  totalProtein: _totalProtein,
                  totalCarbs: _totalCarbs,
                  totalFat: _totalFat,
                  giColor: _giColor(_averageGI),
                ),
                const Gap(22),
                _SectionTitle(
                  icon: Icons.restaurant_menu_rounded,
                  title: context.tr('food_items'),
                  trailing: context.tr('tap_to_edit'),
                ),
                const Gap(12),
                if (_foodItems.isEmpty)
                  _EmptyFoodItemsMessage(
                    message: context.tr('meal_analysis_need_food_item_to_save'),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _foodItems.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) {
                      final item = _foodItems[index];
                      return _FoodItemCard(
                        key: ValueKey('${item.id}_${item.foodName}_$index'),
                        foodItem: item,
                        giColor: _giColor(item.glycemicIndex.toDouble()),
                        onEdit: () => _showEditFoodItemDialog(index, item),
                        onDelete: () => _removeFoodItem(index),
                      );
                    },
                  ),
                if (_hasHealthRecommendations) ...[
                  const Gap(22),
                  _HealthRecommendationCard(
                    recommendations: widget.mealAnalysis.healthRecommendations!,
                  ),
                ],
                const Gap(22),
                _SectionTitle(
                  icon: Icons.notes_rounded,
                  title: context.tr('notes'),
                ),
                const Gap(12),
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
                const Gap(24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _saveMealAnalysis,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      context.tr('save_meal'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasHealthRecommendations {
    final value = widget.mealAnalysis.healthRecommendations;
    return value != null && value.trim().isNotEmpty;
  }

  void _showEditFoodItemDialog(int index, FoodItem foodItem) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return _EditFoodItemDialog(
          foodItem: foodItem,
          onSave: (updatedItem) => _updateFoodItem(index, updatedItem),
        );
      },
    );
  }
}

class _MealImagePreview extends StatelessWidget {
  const _MealImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade600,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DishDetailsSection extends StatelessWidget {
  const _DishDetailsSection({
    required this.dishNameController,
    required this.selectedMealType,
    required this.mealTypeOptions,
    required this.onMealTypeChanged,
  });

  final TextEditingController dishNameController;
  final String selectedMealType;
  final List<_MealTypeOption> mealTypeOptions;
  final ValueChanged<String> onMealTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: dishNameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.tr('dish_name_label'),
            hintText: context.tr('dish_name_hint'),
            prefixIcon: Icon(Icons.restaurant_rounded,),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const Gap(12),
        DropdownButtonFormField<String>(
          value: selectedMealType,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: context.tr('meal_type_label'),
            prefixIcon: const Icon(Icons.schedule_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: mealTypeOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option.value,
              child: Row(
                children: [
                  Icon(option.icon, size: 20),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      context.tr(option.labelKey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            onMealTypeChanged(value);
          },
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.totalCalories,
    required this.averageGI,
    required this.foodCount,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.giColor,
  });

  final double totalCalories;
  final double averageGI;
  final int foodCount;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final Color giColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.analytics_rounded,
              title: context.tr('overview'),
            ),
            const Gap(14),
            Row(
              children: [
                Expanded(
                  child: _OverviewMetric(
                    label: context.tr('total_calories'),
                    value: totalCalories.toStringAsFixed(0),
                    unit: 'kcal',
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _OverviewMetric(
                    label: context.tr('glycemic_index'),
                    value: averageGI.toStringAsFixed(0),
                    icon: Icons.speed_rounded,
                    color: giColor,
                  ),
                ),
                Expanded(
                  child: _OverviewMetric(
                    label: context.tr('food_items'),
                    value: '$foodCount',
                    icon: Icons.restaurant_rounded,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const Gap(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MacroChip(label: context.tr('protein'), value: totalProtein),
                _MacroChip(label: context.tr('carbs'), value: totalCarbs),
                _MacroChip(label: context.tr('fat'), value: totalFat),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const Gap(6),
        Text(
          unit == null ? value : '$value $unit',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}g',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue),
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  const _FoodItemCard({
    super.key,
    required this.foodItem,
    required this.giColor,
    required this.onEdit,
    required this.onDelete,
  });

  final FoodItem foodItem;
  final Color giColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${foodItem.portionGrams.toStringAsFixed(0)}g',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const Gap(10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _NutrientChip(
                          label:
                              '${foodItem.calories.toStringAsFixed(0)} kcal',
                          color: Colors.orange,
                        ),
                        _NutrientChip(
                          label: 'GI ${foodItem.glycemicIndex}',
                          color: giColor,
                        ),
                        _NutrientChip(
                          label: 'P ${foodItem.protein.toStringAsFixed(1)}g',
                          color: Colors.blue,
                        ),
                        _NutrientChip(
                          label: 'C ${foodItem.carbs.toStringAsFixed(1)}g',
                          color: Colors.green,
                        ),
                        _NutrientChip(
                          label: 'F ${foodItem.fat.toStringAsFixed(1)}g',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr('delete'),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  const _NutrientChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HealthRecommendationCard extends StatelessWidget {
  const _HealthRecommendationCard({required this.recommendations});

  final String recommendations;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _SectionTitle(
            icon: Icons.health_and_safety_rounded,
            title: context.tr('health_recommendations'),
            color: Colors.green.shade800,
          ),
          const Gap(10),
          Text(
            recommendations,
            style: TextStyle(
              color: Colors.green.shade900,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    this.trailing,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.blue.shade700;

    return Row(
      children: [
        Icon(icon, size: 20, color: effectiveColor),
        const Gap(8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
      ],
    );
  }
}

class _EmptyFoodItemsMessage extends StatelessWidget {
  const _EmptyFoodItemsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.orange.shade800,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EditFoodItemDialog extends StatefulWidget {
  const _EditFoodItemDialog({
    required this.foodItem,
    required this.onSave,
  });

  final FoodItem foodItem;
  final ValueChanged<FoodItem> onSave;

  @override
  State<_EditFoodItemDialog> createState() => _EditFoodItemDialogState();
}

class _EditFoodItemDialogState extends State<_EditFoodItemDialog> {
  late final TextEditingController _portionController;

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

  void _save() {
    final nextPortion = double.tryParse(_portionController.text.trim());
    if (nextPortion == null || nextPortion <= 0) return;

    final currentPortion = widget.foodItem.portionGrams;
    final ratio = currentPortion <= 0 ? 1.0 : nextPortion / currentPortion;

    widget.onSave(
      widget.foodItem.copyWith(
        portionGrams: nextPortion,
        calories: widget.foodItem.calories * ratio,
        protein: widget.foodItem.protein * ratio,
        carbs: widget.foodItem.carbs * ratio,
        fat: widget.foodItem.fat * ratio,
        fiber: widget.foodItem.fiber * ratio,
      ),
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _portionController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              labelText: context.tr('portion_grams_label'),
              suffixText: 'g',
              border: const OutlineInputBorder(),
            ),
          ),
          const Gap(10),
          Text(
            context.tr('nutrition_recalc_note'),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(context.tr('save')),
        ),
      ],
    );
  }
}

class _MealTypeOption {
  const _MealTypeOption({
    required this.value,
    required this.labelKey,
    required this.icon,
  });

  final String value;
  final String labelKey;
  final IconData icon;
}
