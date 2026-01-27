import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:equatable/equatable.dart';

/// States for meal analysis BLoC
abstract class MealAnalysisState extends Equatable {
  const MealAnalysisState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MealAnalysisInitial extends MealAnalysisState {
  const MealAnalysisInitial();
}

/// Loading state
class MealAnalysisLoading extends MealAnalysisState {
  const MealAnalysisLoading();
}

/// Analysis completed successfully
class MealAnalysisSuccess extends MealAnalysisState {
  final MealAnalysis mealAnalysis;

  const MealAnalysisSuccess(this.mealAnalysis);

  @override
  List<Object?> get props => [mealAnalysis];
}

/// Meal saved successfully
class MealAnalysisSaved extends MealAnalysisState {
  final int mealId;

  const MealAnalysisSaved(this.mealId);

  @override
  List<Object?> get props => [mealId];
}

/// Meal analyses loaded
class MealAnalysesLoaded extends MealAnalysisState {
  final List<MealAnalysis> mealAnalyses;

  const MealAnalysesLoaded(this.mealAnalyses);

  @override
  List<Object?> get props => [mealAnalyses];
}

/// Meal deleted successfully
class MealAnalysisDeleted extends MealAnalysisState {
  const MealAnalysisDeleted();
}

/// Error state
class MealAnalysisError extends MealAnalysisState {
  final String message;

  const MealAnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}
