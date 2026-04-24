import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class MealSuggestionScreen extends StatefulWidget {
  const MealSuggestionScreen({super.key});

  @override
  State<MealSuggestionScreen> createState() => _MealSuggestionScreenState();
}

class _MealSuggestionScreenState extends State<MealSuggestionScreen> {
  String? _selectedMealType;

  final _mealTypes = [
    {'key': null, 'label': 'Bữa ăn tiếp theo', 'icon': Icons.auto_awesome},
    {'key': 'bữa sáng', 'label': 'Bữa sáng', 'icon': Icons.wb_sunny_rounded},
    {'key': 'bữa trưa', 'label': 'Bữa trưa', 'icon': Icons.wb_twilight_rounded},
    {'key': 'bữa tối', 'label': 'Bữa tối', 'icon': Icons.nights_stay_rounded},
    {
      'key': 'bữa phụ (snack)',
      'label': 'Bữa phụ',
      'icon': Icons.cookie_rounded,
    },
  ];

  void _requestSuggestion() {
    context.read<MealAnalysisBloc>().add(
      SuggestMealEvent(mealType: _selectedMealType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        title: 'AI Gợi ý bữa ăn',
        centerTitle: true,
        onBack: () => Navigator.pop(context),
      ),
      body: BlocBuilder<MealAnalysisBloc, MealAnalysisState>(
        builder: (context, state) {
          if (state is MealAnalysisLoading) {
            return _buildLoadingState();
          }

          if (state is MealSuggestionLoaded) {
            return _buildSuggestionResult(state.suggestion);
          }

          if (state is MealAnalysisError) {
            return _buildErrorState(state.message);
          }

          return _buildInitialState();
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Gap(20),

          // Hero illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.teal.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 56,
              color: Colors.blue.shade700,
            ),
          ),
          const Gap(24),

          Text(
            'Gợi ý bữa ăn thông minh',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary(context),
            ),
          ),
          const Gap(8),
          Text(
            'AI sẽ phân tích chỉ số sức khỏe, dinh dưỡng đã nạp\nvà đề xuất bữa ăn phù hợp nhất cho bạn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),

          const Gap(32),

          // Meal type selector
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Gap(10),
                Text(
                  'Chọn loại bữa ăn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary(context),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _mealTypes.map((type) {
              final isSelected = _selectedMealType == type['key'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMealType = type['key'] as String?;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.shade50
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue.shade400
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? Colors.blue.shade600
                            : Colors.grey.shade500,
                      ),
                      const Gap(6),
                      Text(
                        type['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.blue.shade700
                              : AppColor.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const Gap(32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildFeatureRow(
                  Icons.favorite_rounded,
                  'Phân tích đường huyết, huyết áp, cholesterol',
                  Colors.red,
                ),
                const Gap(10),
                _buildFeatureRow(
                  Icons.calculate_rounded,
                  'Tính calo/macro còn thiếu trong ngày',
                  Colors.orange,
                ),
                const Gap(10),
                _buildFeatureRow(
                  Icons.monitor_weight_rounded,
                  'Tính TDEE dựa trên BMI và bước chân',
                  Colors.blue,
                ),
                const Gap(10),
                _buildFeatureRow(
                  Icons.local_dining_rounded,
                  'Gợi ý món Việt Nam phù hợp',
                  Colors.green,
                ),
              ],
            ),
          ),

          const Gap(32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _requestSuggestion,
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: const Text(
                'AI Gợi ý ngay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const Gap(10),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const Gap(12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue.shade400),
          const Gap(24),
          const Text(
            'AI đang phân tích sức khỏe...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          Text(
            'Đang đọc chỉ số đường huyết, huyết áp,\ncholesterol và dinh dưỡng hôm nay',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const Gap(16),
            Text(
              'Không thể tạo gợi ý',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary(context),
              ),
            ),
            const Gap(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: _requestSuggestion,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionResult(Map<String, dynamic> suggestion) {
    final mealSuggestions =
        suggestion['mealSuggestions'] as List<dynamic>? ?? [];
    final dailySummary = suggestion['dailySummary'] as String? ?? '';
    final nutritionGaps = suggestion['nutritionGaps'] as String? ?? '';
    final waterReminder = suggestion['waterReminder'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily summary card
          if (dailySummary.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.teal.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      Gap(8),
                      Text(
                        'Tóm tắt sức khỏe hôm nay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Text(
                    dailySummary,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          const Gap(16),

          // Nutrition gaps
          if (nutritionGaps.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chất dinh dưỡng cần bổ sung',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          nutritionGaps,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const Gap(16),

          // Water reminder
          if (waterReminder.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.water_drop_rounded,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      waterReminder,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Gap(20),

          // Meal suggestions header
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
              const Gap(10),
              Text(
                'Món ăn gợi ý',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary(context),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const Gap(14),

          // Meal suggestion cards
          ...mealSuggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final meal = entry.value as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildMealSuggestionCard(meal, index + 1),
            );
          }),

          const Gap(20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Gợi ý lại",
                    onPressed: _requestSuggestion,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSuggestionCard(Map<String, dynamic> meal, int rank) {
    final dishName = meal['dishName'] as String? ?? '';
    final description = meal['description'] as String? ?? '';
    final reason = meal['reason'] as String? ?? '';
    final estimatedCalories = meal['estimatedCalories'] as num? ?? 0;
    final suitabilityScore = meal['suitabilityScore'] as num? ?? 0;
    final ingredients = meal['ingredients'] as List<dynamic>? ?? [];
    final warnings = meal['warnings'] as String?;
    final cookingTip = meal['cookingTip'] as String?;
    final nutritionHighlights =
        meal['nutritionHighlights'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getScoreColor(suitabilityScore.toDouble())
                      // ignore: deprecated_member_use
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(suitabilityScore.toDouble()),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dishName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary(context),
                      ),
                    ),
                    if (description.isNotEmpty)
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
              // Score badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(suitabilityScore.toDouble())
                      // ignore: deprecated_member_use
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: _getScoreColor(suitabilityScore.toDouble()),
                    ),
                    const Gap(2),
                    Text(
                      '${suitabilityScore.toInt()}/10',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(suitabilityScore.toDouble()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),

          // Reason
          if (reason.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      reason,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Gap(12),

          // Nutrition row
          Row(
            children: [
              _buildMiniNutrient(
                '${estimatedCalories.toInt()}',
                'kcal',
                Colors.deepOrange,
              ),
              const Gap(8),
              if (nutritionHighlights['protein'] != null)
                _buildMiniNutrient(
                  '${(nutritionHighlights['protein'] as num).toInt()}g',
                  'Protein',
                  Colors.blue,
                ),
              const Gap(8),
              if (nutritionHighlights['carbs'] != null)
                _buildMiniNutrient(
                  '${(nutritionHighlights['carbs'] as num).toInt()}g',
                  'Carbs',
                  Colors.orange,
                ),
              const Gap(8),
              if (nutritionHighlights['fat'] != null)
                _buildMiniNutrient(
                  '${(nutritionHighlights['fat'] as num).toInt()}g',
                  'Fat',
                  Colors.red,
                ),
            ],
          ),
          const Gap(10),

          // Ingredients
          if (ingredients.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ingredients
                  .take(6)
                  .map(
                    (ing) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ing.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

          // Cooking tip
          if (cookingTip != null && cookingTip.isNotEmpty) ...[
            const Gap(10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  size: 14,
                  color: Colors.amber.shade700,
                ),
                const Gap(6),
                Expanded(
                  child: Text(
                    cookingTip,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Warning
          if (warnings != null && warnings.isNotEmpty) ...[
            const Gap(8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.red.shade400),
                const Gap(6),
                Expanded(
                  child: Text(
                    warnings,
                    style: TextStyle(fontSize: 11, color: Colors.red.shade600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniNutrient(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 9, color: color)),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green.shade600;
    if (score >= 6) return Colors.orange.shade600;
    return Colors.red.shade400;
  }
}
