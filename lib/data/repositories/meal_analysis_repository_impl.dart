import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/domain/entities/food_item.dart';
import 'package:doctor_care/domain/repositories/meal_analysis_repository.dart';
import 'package:doctor_care/data/datasources/meal_analysis_local_datasource.dart';
import 'package:doctor_care/core/services/gemini_ai_service.dart';
import 'package:dart_either/dart_either.dart';

/// Repository implementation for meal analysis
class MealAnalysisRepositoryImpl implements MealAnalysisRepository {
  final MealAnalysisLocalDataSource _localDataSource;
  final GeminiAIService _aiService;

  MealAnalysisRepositoryImpl(this._localDataSource, this._aiService);

  @override
  Future<Either<Exception, MealAnalysis>> analyzeMealImage(
    String imagePath,
  ) async {
    try {
      final result = await _aiService.analyzeMealImage(imagePath);

      // Kiểm tra ảnh có hợp lệ không
      final imageValid = result['imageValid'] as bool? ?? true;
      if (!imageValid) {
        final reason = result['invalidReason'] as String? ?? 'Ảnh không hợp lệ';
        return Left(InvalidImageException(reason));
      }

      final foodItems = result['foodItems'] as List<FoodItem>;
      final dishName = result['dishName'] as String?;
      final healthRecommendations = result['healthRecommendations'] as String?;

      final mealAnalysis = MealAnalysis(
        timestamp: DateTime.now(),
        imagePath: imagePath,
        dishName: dishName,
        healthRecommendations: healthRecommendations,
        foodItems: foodItems,
      );

      return Right(mealAnalysis);
    } catch (e) {
      return Left(Exception('Failed to analyze meal image: $e'));
    }
  }

  @override
  Future<Either<Exception, int>> saveMealAnalysis(
    MealAnalysis mealAnalysis,
  ) async {
    try {
      final id = await _localDataSource.saveMealAnalysis(mealAnalysis);
      return Right(id);
    } catch (e) {
      return Left(Exception('Failed to save meal analysis: $e'));
    }
  }

  @override
  Future<Either<Exception, List<MealAnalysis>>> getAllMealAnalyses() async {
    try {
      final meals = await _localDataSource.getAllMealAnalyses();
      return Right(meals);
    } catch (e) {
      return Left(Exception('Failed to get meal analyses: $e'));
    }
  }

  @override
  Future<Either<Exception, List<MealAnalysis>>> getMealAnalysesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final meals = await _localDataSource.getMealAnalysesByDateRange(
        startDate,
        endDate,
      );
      return Right(meals);
    } catch (e) {
      return Left(Exception('Failed to get meal analyses by date range: $e'));
    }
  }

  @override
  Future<Either<Exception, MealAnalysis>> getMealAnalysisById(int id) async {
    try {
      final meal = await _localDataSource.getMealAnalysisById(id);
      if (meal == null) {
        return Left(Exception('Meal analysis not found'));
      }
      return Right(meal);
    } catch (e) {
      return Left(Exception('Failed to get meal analysis: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updateMealAnalysis(
    MealAnalysis mealAnalysis,
  ) async {
    try {
      await _localDataSource.updateMealAnalysis(mealAnalysis);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to update meal analysis: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> deleteMealAnalysis(int id) async {
    try {
      await _localDataSource.deleteMealAnalysis(id);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to delete meal analysis: $e'));
    }
  }
}

/// Exception khi ảnh không hợp lệ (không phải thức ăn, quá mờ, quá tối...)
class InvalidImageException implements Exception {
  final String reason;

  const InvalidImageException(this.reason);

  @override
  String toString() => reason;
}
