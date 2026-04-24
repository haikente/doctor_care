import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:equatable/equatable.dart';

abstract class MealAnalysisState extends Equatable {
  const MealAnalysisState();

  @override
  List<Object?> get props => [];
}

// trạng thái ban đầu
class MealAnalysisInitial extends MealAnalysisState {
  const MealAnalysisInitial();
}

// trạng thái đang tải
class MealAnalysisLoading extends MealAnalysisState {
  const MealAnalysisLoading();
}

// trạng thái phân tích thành công
class MealAnalysisSuccess extends MealAnalysisState {
  final MealAnalysis mealAnalysis;

  const MealAnalysisSuccess(this.mealAnalysis);

  @override
  List<Object?> get props => [mealAnalysis];
}

// trạng thái lưu thành công
class MealAnalysisSaved extends MealAnalysisState {
  final int mealId;

  const MealAnalysisSaved(this.mealId);

  @override
  List<Object?> get props => [mealId];
}

// trạng thái tải thành công
class MealAnalysesLoaded extends MealAnalysisState {
  final List<MealAnalysis> mealAnalyses;

  const MealAnalysesLoaded(this.mealAnalyses);

  @override
  List<Object?> get props => [mealAnalyses];
}

// trạng thái xóa thành công
class MealAnalysisDeleted extends MealAnalysisState {
  const MealAnalysisDeleted();
}

// trạng thái lỗi
class MealAnalysisError extends MealAnalysisState {
  final String message;

  const MealAnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}

// trạng thái gợi ý thành công
class MealSuggestionLoaded extends MealAnalysisState {
  final Map<String, dynamic> suggestion;

  const MealSuggestionLoaded(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}
