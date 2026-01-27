import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/domain/repositories/meal_analysis_repository.dart';
import 'package:dart_either/dart_either.dart';

/// Use case to save meal analysis to database
class SaveMealAnalysisUseCase {
  final MealAnalysisRepository repository;

  SaveMealAnalysisUseCase(this.repository);

  Future<Either<Exception, int>> call(MealAnalysis mealAnalysis) {
    return repository.saveMealAnalysis(mealAnalysis);
  }
}
