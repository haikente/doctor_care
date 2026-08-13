import 'package:doctor_care/core/localization/app_localizations.dart';
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

  final List<_MealTypeOption> _mealTypes = const [
    _MealTypeOption(
      key: null,
      labelKey: 'meal_suggestion_next_meal',
      icon: Icons.auto_awesome_rounded,
    ),
    _MealTypeOption(
      key: 'bữa sáng',
      labelKey: 'meal_suggestion_breakfast',
      icon: Icons.wb_sunny_rounded,
    ),
    _MealTypeOption(
      key: 'bữa trưa',
      labelKey: 'meal_suggestion_lunch',
      icon: Icons.wb_twilight_rounded,
    ),
    _MealTypeOption(
      key: 'bữa tối',
      labelKey: 'meal_suggestion_dinner',
      icon: Icons.nights_stay_rounded,
    ),
    _MealTypeOption(
      key: 'bữa phụ (snack)',
      labelKey: 'meal_suggestion_snack',
      icon: Icons.cookie_rounded,
    ),
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
        title: context.tr('meal_suggestion_ai_title'),
        centerTitle: true,
        onBack: () => Navigator.pop(context),
      ),
      body: BlocBuilder<MealAnalysisBloc, MealAnalysisState>(
        builder: (context, state) {
          if (state is MealAnalysisLoading) {
            return const _LoadingState();
          }

          if (state is MealSuggestionLoaded) {
            return _SuggestionResult(
              suggestion: state.suggestion,
              onRegenerate: _requestSuggestion,
            );
          }

          if (state is MealAnalysisError) {
            return _ErrorState(
              message: state.message,
              onRetry: _requestSuggestion,
            );
          }

          return _InitialState(
            mealTypes: _mealTypes,
            selectedMealType: _selectedMealType,
            onMealTypeSelected: (value) {
              setState(() {
                _selectedMealType = value;
              });
            },
            onGenerate: _requestSuggestion,
          );
        },
      ),
    );
  }
}

class _InitialState extends StatelessWidget {
  const _InitialState({
    required this.mealTypes,
    required this.selectedMealType,
    required this.onMealTypeSelected,
    required this.onGenerate,
  });

  final List<_MealTypeOption> mealTypes;
  final String? selectedMealType;
  final ValueChanged<String?> onMealTypeSelected;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IntroPanel(onGenerate: onGenerate),
                    const Gap(22),
                    _SectionHeader(
                      icon: Icons.schedule_rounded,
                      title: context.tr('meal_suggestion_choose_type'),
                    ),
                    const Gap(12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: mealTypes.map((type) {
                        final isSelected = selectedMealType == type.key;
                        return _MealTypeChip(
                          option: type,
                          selected: isSelected,
                          onTap: () => onMealTypeSelected(type.key),
                        );
                      }).toList(),
                    ),
                    const Gap(24),
                    _SectionHeader(
                      icon: Icons.psychology_alt_rounded,
                      title: 'AI xét các dữ liệu',
                    ),
                    const Gap(12),
                    _FeatureGrid(
                      items: [
                        _FeatureItem(
                          icon: Icons.favorite_rounded,
                          title: context.tr(
                            'meal_suggestion_feature_health_metrics',
                          ),
                          color: Colors.red,
                        ),
                        _FeatureItem(
                          icon: Icons.calculate_rounded,
                          title: context.tr(
                            'meal_suggestion_feature_macro_gaps',
                          ),
                          color: Colors.orange,
                        ),
                        _FeatureItem(
                          icon: Icons.monitor_weight_rounded,
                          title: context.tr('meal_suggestion_feature_tdee'),
                          color: Colors.blue,
                        ),
                        _FeatureItem(
                          icon: Icons.ramen_dining_rounded,
                          title: context.tr(
                            'meal_suggestion_feature_vietnamese_food',
                          ),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _BottomGenerateBar(onGenerate: onGenerate),
          ],
        ),
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary.withOpacity(0.95), const Color(0xFF20A386)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const Gap(16),
          Text(
            context.tr('meal_suggestion_smart_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(8),
          Text(
            context.tr('meal_suggestion_smart_desc'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealTypeChip extends StatelessWidget {
  const _MealTypeChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _MealTypeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? primary.withOpacity(0.10)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade200,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 18,
              color: selected ? primary : Colors.grey.shade600,
            ),
            const Gap(8),
            Text(
              context.tr(option.labelKey),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? primary : AppColor.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomGenerateBar extends StatelessWidget {
  const _BottomGenerateBar({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),

      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: context.tr('meal_suggestion_generate_now'),
          onPressed: onGenerate,
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.items});

  final List<_FeatureItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.95,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.12),
                  ),
                ),
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ],
            ),
            const Gap(28),
            Text(
              context.tr('meal_suggestion_loading_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(10),
            Text(
              context.tr('meal_suggestion_loading_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade500,
              ),
            ),
            const Gap(18),
            Text(
              context.tr('meal_suggestion_error_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColor.textPrimary(context),
              ),
            ),
            const Gap(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionResult extends StatelessWidget {
  const _SuggestionResult({
    required this.suggestion,
    required this.onRegenerate,
  });

  final Map<String, dynamic> suggestion;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final mealSuggestions =
        suggestion['mealSuggestions'] as List<dynamic>? ?? [];
    final dailySummary = suggestion['dailySummary'] as String? ?? '';
    final nutritionGaps = suggestion['nutritionGaps'] as String? ?? '';
    final waterReminder = suggestion['waterReminder'] as String? ?? '';

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              children: [
                if (dailySummary.isNotEmpty)
                  _InsightCard(
                    icon: Icons.insights_rounded,
                    title: context.tr('meal_suggestion_daily_summary'),
                    text: dailySummary,
                    color: Colors.green,
                    filled: true,
                  ),
                if (dailySummary.isNotEmpty) const Gap(12),
                if (nutritionGaps.isNotEmpty)
                  _InsightCard(
                    icon: Icons.warning_amber_rounded,
                    title: context.tr('meal_suggestion_nutrition_gaps'),
                    text: nutritionGaps,
                    color: Colors.orange,
                  ),
                if (nutritionGaps.isNotEmpty) const Gap(12),
                if (waterReminder.isNotEmpty)
                  _InsightCard(
                    icon: Icons.water_drop_rounded,
                    title: 'Nước uống',
                    text: waterReminder,
                    color: Colors.blue,
                  ),
                const Gap(22),
                _SectionHeader(
                  icon: Icons.restaurant_menu_rounded,
                  title: context.tr('meal_suggestion_suggested_dishes'),
                ),
                const Gap(12),
                ...mealSuggestions.asMap().entries.map((entry) {
                  final meal = entry.value as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MealSuggestionCard(meal: meal, rank: entry.key + 1),
                  );
                }),
              ],
            ),
          ),
          _BottomGenerateBar(onGenerate: onRegenerate),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
    this.filled = false,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final background = filled ? color : color.withOpacity(0.08);
    final foreground = filled ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: filled ? null : Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 22),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: filled
                        ? Colors.white
                        : AppColor.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(6),
                Text(
                  text,
                  style: TextStyle(
                    color: filled
                        ? Colors.white.withOpacity(0.88)
                        : AppColor.textPrimary(context).withOpacity(0.72),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealSuggestionCard extends StatelessWidget {
  const _MealSuggestionCard({required this.meal, required this.rank});

  final Map<String, dynamic> meal;
  final int rank;

  @override
  Widget build(BuildContext context) {
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
    final scoreColor = _scoreColor(suitabilityScore.toDouble());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
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
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColor.textPrimary(context),
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(10),
              _ScoreBadge(score: suitabilityScore.toInt(), color: scoreColor),
            ],
          ),
          const Gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _NutrientChip(
                value: '${estimatedCalories.toInt()}',
                label: 'kcal',
                color: Colors.deepOrange,
              ),
              if (nutritionHighlights['protein'] != null)
                _NutrientChip(
                  value: '${(nutritionHighlights['protein'] as num).toInt()}g',
                  label: context.tr('protein'),
                  color: Colors.blue,
                ),
              if (nutritionHighlights['carbs'] != null)
                _NutrientChip(
                  value: '${(nutritionHighlights['carbs'] as num).toInt()}g',
                  label: context.tr('carbs'),
                  color: Colors.orange,
                ),
              if (nutritionHighlights['fat'] != null)
                _NutrientChip(
                  value: '${(nutritionHighlights['fat'] as num).toInt()}g',
                  label: context.tr('fat'),
                  color: Colors.red,
                ),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const Gap(14),
            _TextNote(
              icon: Icons.lightbulb_outline_rounded,
              text: reason,
              color: Colors.green,
            ),
          ],
          if (ingredients.isNotEmpty) ...[
            const Gap(12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ingredients
                  .take(7)
                  .map(
                    (ing) => Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        ing.toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.grey.shade100,
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (cookingTip != null && cookingTip.isNotEmpty) ...[
            const Gap(10),
            _TextNote(
              icon: Icons.tips_and_updates_rounded,
              text: cookingTip,
              color: Colors.amber.shade700,
            ),
          ],
          if (warnings != null && warnings.isNotEmpty) ...[
            const Gap(10),
            _TextNote(
              icon: Icons.info_outline_rounded,
              text: warnings,
              color: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 8) return Colors.green.shade600;
    if (score >= 6) return Colors.orange.shade600;
    return Colors.red.shade500;
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 15, color: color),
          const Gap(3),
          Text(
            '$score/10',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  const _NutrientChip({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Gap(4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _TextNote extends StatelessWidget {
  const _TextNote({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 17),
          const Gap(8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const Gap(8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _MealTypeOption {
  const _MealTypeOption({
    required this.key,
    required this.labelKey,
    required this.icon,
  });

  final String? key;
  final String labelKey;
  final IconData icon;
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;
}
