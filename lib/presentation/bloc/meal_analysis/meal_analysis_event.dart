import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:equatable/equatable.dart';

/// Events for meal analysis BLoC
abstract class MealAnalysisEvent extends Equatable {
  const MealAnalysisEvent();

  @override
  List<Object?> get props => [];
}

/// Event to analyze a meal image
class AnalyzeMealImageEvent extends MealAnalysisEvent {
  final String imagePath;

  const AnalyzeMealImageEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// Event to save meal analysis
class SaveMealAnalysisEvent extends MealAnalysisEvent {
  final MealAnalysis mealAnalysis;

  const SaveMealAnalysisEvent(this.mealAnalysis);

  @override
  List<Object?> get props => [mealAnalysis];
}

/// Event to load all meal analyses
class LoadMealAnalysesEvent extends MealAnalysisEvent {
  const LoadMealAnalysesEvent();
}

/// Event to delete meal analysis
class DeleteMealAnalysisEvent extends MealAnalysisEvent {
  final int id;

  const DeleteMealAnalysisEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to update meal analysis (after user edits)
class UpdateMealAnalysisEvent extends MealAnalysisEvent {
  final MealAnalysis mealAnalysis;

  const UpdateMealAnalysisEvent(this.mealAnalysis);

  @override
  List<Object?> get props => [mealAnalysis];
}

/// Event to request AI meal suggestion based on health data
class SuggestMealEvent extends MealAnalysisEvent {
  final String? mealType;

  const SuggestMealEvent({this.mealType});

  @override
  List<Object?> get props => [mealType];
}
