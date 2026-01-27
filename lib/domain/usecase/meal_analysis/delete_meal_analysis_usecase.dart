import 'package:doctor_care/domain/repositories/meal_analysis_repository.dart';
import 'package:dart_either/dart_either.dart';

/// Use case to delete a meal analysis
class DeleteMealAnalysisUseCase {
  final MealAnalysisRepository repository;

  DeleteMealAnalysisUseCase(this.repository);

  Future<Either<Exception, void>> call(int id) {
    return repository.deleteMealAnalysis(id);
  }
}
