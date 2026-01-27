import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:dart_either/dart_either.dart';

/// Repository interface for meal analysis operations
abstract class MealAnalysisRepository {
  /// Analyze a meal image using AI
  Future<Either<Exception, MealAnalysis>> analyzeMealImage(String imagePath);

  /// Save meal analysis to database
  Future<Either<Exception, int>> saveMealAnalysis(MealAnalysis mealAnalysis);

  /// Get all meal analyses
  Future<Either<Exception, List<MealAnalysis>>> getAllMealAnalyses();

  /// Get meal analyses by date range
  Future<Either<Exception, List<MealAnalysis>>> getMealAnalysesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get meal analysis by ID
  Future<Either<Exception, MealAnalysis>> getMealAnalysisById(int id);

  /// Update meal analysis
  Future<Either<Exception, void>> updateMealAnalysis(MealAnalysis mealAnalysis);

  /// Delete meal analysis
  Future<Either<Exception, void>> deleteMealAnalysis(int id);
}
