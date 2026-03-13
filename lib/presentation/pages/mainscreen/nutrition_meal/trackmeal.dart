import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/presentation/pages/mainscreen/nutrition_meal/insert_dish.dart';
import 'package:doctor_care/presentation/pages/mainscreen/nutrition_meal/widgets/mealCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';
import 'package:doctor_care/presentation/pages/screens/meal_analysis/meal_capture_screen.dart';
import 'package:doctor_care/domain/entities/meal_analysis.dart';

class TrackMeal extends StatefulWidget {
  const TrackMeal({super.key});

  @override
  State<TrackMeal> createState() => _TrackMealState();
}

class _TrackMealState extends State<TrackMeal> {
  String selectedFilter = "all";
  final List<String> filterOptions = ["all", "today", "week", "month"];

  @override
  void initState() {
    super.initState();
    context.read<MealAnalysisBloc>().add(const LoadMealAnalysesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: context.tr('meal_history_title'),
        centerTitle: true,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20,),
        onInfo: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => const InsertDish()));
        },
      ),
      body: BlocBuilder<MealAnalysisBloc, MealAnalysisState>(
        builder: (context, state) {
          if (state is MealAnalysisLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MealAnalysisError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    context.tr(
                      'error_with_message',
                      params: {'message': state.message},
                    ),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MealAnalysisBloc>().add(
                        const LoadMealAnalysesEvent(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(context.tr('retry')),
                  ),
                ],
              ),
            );
          }

          if (state is MealAnalysesLoaded) {
            List<MealAnalysis> filteredMeals = state.mealAnalyses;
            final now = DateTime.now();

            if (selectedFilter == "today") {
              filteredMeals = state.mealAnalyses.where((m) {
                return m.timestamp.year == now.year &&
                    m.timestamp.month == now.month &&
                    m.timestamp.day == now.day;
              }).toList();
            } else if (selectedFilter == "week") {
              final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              final endOfWeek = startOfWeek.add(
                const Duration(days: 6, hours: 23, minutes: 59),
              );
              filteredMeals = state.mealAnalyses.where((m) {
                return m.timestamp.isAfter(
                      startOfWeek.subtract(const Duration(seconds: 1)),
                    ) &&
                    m.timestamp.isBefore(endOfWeek);
              }).toList();
            } else if (selectedFilter == "month") {
              filteredMeals = state.mealAnalyses.where((m) {
                return m.timestamp.year == now.year &&
                    m.timestamp.month == now.month;
              }).toList();
            }

            return Column(
              children: [
                // Filter chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).colorScheme.surface,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filterOptions.map((filter) {
                        final isSelected = selectedFilter == filter;
                        final label = switch (filter) {
                          'all' => context.tr('all'),
                          'today' => context.tr('today'),
                          'week' => context.tr('week'),
                          'month' => context.tr('month'),
                          _ => filter,
                        };
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedFilter = filter;
                              });
                            },
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            selectedColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : AppColor.textSecondary(context),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : AppColor.divider(context),
                              width: 1.5,
                            ),
                            checkmarkColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredMeals.isEmpty
                      ? _buildEmptyState(context, isFiltered: true)
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<MealAnalysisBloc>().add(
                              const LoadMealAnalysesEvent(),
                            );
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredMeals.length,
                            itemBuilder: (context, index) {
                              final meal = filteredMeals[index];
                              return Mealcard().buildMealCard(context, meal);
                            },
                          ),
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MealCaptureScreen()),
          ).then((_) {
            // ignore: use_build_context_synchronously
            context.read<MealAnalysisBloc>().add(const LoadMealAnalysesEvent());
          });
        },
        icon: const Icon(Icons.auto_awesome),
        label: Text(context.tr('ai_analyze')),
        heroTag: 'track_meal_fab',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {bool isFiltered = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.filter_list_off : Icons.restaurant_menu,
            size: 64,
            color: AppColor.textSecondary(context).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered
                ? context.tr('no_meals_in_range')
                : context.tr('no_meals_today'),
            style: TextStyle(
              fontSize: 16,
              color: AppColor.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? context.tr('try_another_range')
                : context.tr('tap_ai_to_start'),
            style: TextStyle(
              fontSize: 14,
              color: AppColor.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
