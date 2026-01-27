import 'package:equatable/equatable.dart';

/// Entity representing nutritional information for a food item
class FoodNutrition extends Equatable {
  final String name; // Vietnamese name
  final String nameEn; // English name
  final double caloriesPer100g; // Calories per 100g
  final int glycemicIndex; // Glycemic Index (GI)
  final double protein; // Protein in grams per 100g
  final double carbs; // Carbohydrates in grams per 100g
  final double fat; // Fat in grams per 100g
  final double fiber; // Fiber in grams per 100g
  final String category; // Food category

  const FoodNutrition({
    required this.name,
    required this.nameEn,
    required this.caloriesPer100g,
    required this.glycemicIndex,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.category,
  });

  @override
  List<Object?> get props => [
    name,
    nameEn,
    caloriesPer100g,
    glycemicIndex,
    protein,
    carbs,
    fat,
    fiber,
    category,
  ];

  /// Calculate calories for a specific portion size
  double calculateCalories(double portionGrams) {
    return (caloriesPer100g * portionGrams) / 100;
  }

  /// Calculate protein for a specific portion size
  double calculateProtein(double portionGrams) {
    return (protein * portionGrams) / 100;
  }

  /// Calculate carbs for a specific portion size
  double calculateCarbs(double portionGrams) {
    return (carbs * portionGrams) / 100;
  }

  /// Calculate fat for a specific portion size
  double calculateFat(double portionGrams) {
    return (fat * portionGrams) / 100;
  }

  /// Calculate fiber for a specific portion size
  double calculateFiber(double portionGrams) {
    return (fiber * portionGrams) / 100;
  }
}
