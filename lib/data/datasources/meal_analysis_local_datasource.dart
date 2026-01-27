import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/domain/entities/food_item.dart';
import 'package:doctor_care/data/models/meal_analysis_model.dart';
import 'package:doctor_care/data/models/food_item_model.dart';

/// Local data source for meal analysis using SQLite
class MealAnalysisLocalDataSource {
  final DbHelper _dbHelper = DbHelper.instance;

  /// Save meal analysis to database
  Future<int> saveMealAnalysis(MealAnalysis mealAnalysis) async {
    final db = await _dbHelper.database;

    // Save meal analysis
    final mealModel = MealAnalysisModel.fromEntity(mealAnalysis);
    final mealId = await db.insert('meal_analysis', mealModel.toMap());

    // Save food items
    for (var foodItem in mealAnalysis.foodItems) {
      final foodModel = FoodItemModel.fromEntity(foodItem);
      await db.insert('food_items', foodModel.toMap(mealAnalysisId: mealId));
    }

    return mealId;
  }

  /// Get all meal analyses
  Future<List<MealAnalysis>> getAllMealAnalyses() async {
    final db = await _dbHelper.database;

    final mealMaps = await db.query('meal_analysis', orderBy: 'timestamp DESC');

    final List<MealAnalysis> meals = [];

    for (var mealMap in mealMaps) {
      final foodItems = await _getFoodItemsForMeal(mealMap['id'] as int);
      final meal = MealAnalysisModel.fromMap(mealMap, foodItems: foodItems);
      meals.add(meal.toEntity());
    }

    return meals;
  }

  /// Get meal analyses by date range
  Future<List<MealAnalysis>> getMealAnalysesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;

    final mealMaps = await db.query(
      'meal_analysis',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    final List<MealAnalysis> meals = [];

    for (var mealMap in mealMaps) {
      final foodItems = await _getFoodItemsForMeal(mealMap['id'] as int);
      final meal = MealAnalysisModel.fromMap(mealMap, foodItems: foodItems);
      meals.add(meal.toEntity());
    }

    return meals;
  }

  /// Get meal analysis by ID
  Future<MealAnalysis?> getMealAnalysisById(int id) async {
    final db = await _dbHelper.database;

    final mealMaps = await db.query(
      'meal_analysis',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (mealMaps.isEmpty) return null;

    final foodItems = await _getFoodItemsForMeal(id);
    final meal = MealAnalysisModel.fromMap(
      mealMaps.first,
      foodItems: foodItems,
    );
    return meal.toEntity();
  }

  /// Update meal analysis
  Future<void> updateMealAnalysis(MealAnalysis mealAnalysis) async {
    final db = await _dbHelper.database;

    // Update meal analysis
    final mealModel = MealAnalysisModel.fromEntity(mealAnalysis);
    await db.update(
      'meal_analysis',
      mealModel.toMap(),
      where: 'id = ?',
      whereArgs: [mealAnalysis.id],
    );

    // Delete old food items
    await db.delete(
      'food_items',
      where: 'meal_analysis_id = ?',
      whereArgs: [mealAnalysis.id],
    );

    // Insert updated food items
    for (var foodItem in mealAnalysis.foodItems) {
      final foodModel = FoodItemModel.fromEntity(foodItem);
      await db.insert(
        'food_items',
        foodModel.toMap(mealAnalysisId: mealAnalysis.id),
      );
    }
  }

  /// Delete meal analysis
  Future<void> deleteMealAnalysis(int id) async {
    final db = await _dbHelper.database;

    // Delete food items first (foreign key constraint)
    await db.delete(
      'food_items',
      where: 'meal_analysis_id = ?',
      whereArgs: [id],
    );

    // Delete meal analysis
    await db.delete('meal_analysis', where: 'id = ?', whereArgs: [id]);
  }

  /// Get food items for a specific meal
  Future<List<FoodItem>> _getFoodItemsForMeal(int mealId) async {
    final db = await _dbHelper.database;

    final foodMaps = await db.query(
      'food_items',
      where: 'meal_analysis_id = ?',
      whereArgs: [mealId],
    );

    return foodMaps
        .map((map) => FoodItemModel.fromMap(map).toEntity())
        .toList();
  }
}
