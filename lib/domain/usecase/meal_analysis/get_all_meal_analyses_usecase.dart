import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/domain/repositories/meal_analysis_repository.dart';
import 'package:dart_either/dart_either.dart';

/// Use case to get all meal analyses
class GetAllMealAnalysesUseCase {
  final MealAnalysisRepository repository;

  GetAllMealAnalysesUseCase(this.repository);

  Future<Either<Exception, List<MealAnalysis>>> call() {
    return repository.getAllMealAnalyses();
  }
}
