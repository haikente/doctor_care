import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/domain/repositories/meal_analysis_repository.dart';
import 'package:dart_either/dart_either.dart';

/// Use case to analyze a meal image using AI
class AnalyzeMealImageUseCase {
  final MealAnalysisRepository repository;

  AnalyzeMealImageUseCase(this.repository);

  Future<Either<Exception, MealAnalysis>> call(String imagePath) {
    return repository.analyzeMealImage(imagePath);
  }
}
