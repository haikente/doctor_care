import 'package:equatable/equatable.dart';

/// Entity representing a single food item in a meal
class FoodItem extends Equatable {
  final int? id;
  final String foodName; // Vietnamese name
  final String foodNameEn; // English name
  final double portionGrams; // Portion size in grams
  final double calories; // Total calories for this portion
  final int glycemicIndex; // GI value
  final double protein; // Protein in grams
  final double carbs; // Carbs in grams
  final double fat; // Fat in grams
  final double fiber; // Fiber in grams
  final String category; // Food category

  const FoodItem({
    this.id,
    required this.foodName,
    required this.foodNameEn,
    required this.portionGrams,
    required this.calories,
    required this.glycemicIndex,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.category,
  });

  @override
  List<Object?> get props => [
    id,
    foodName,
    foodNameEn,
    portionGrams,
    calories,
    glycemicIndex,
    protein,
    carbs,
    fat,
    fiber,
    category,
  ];

  /// Create a copy with updated fields
  FoodItem copyWith({
    int? id,
    String? foodName,
    String? foodNameEn,
    double? portionGrams,
    double? calories,
    int? glycemicIndex,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    String? category,
  }) {
    return FoodItem(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      foodNameEn: foodNameEn ?? this.foodNameEn,
      portionGrams: portionGrams ?? this.portionGrams,
      calories: calories ?? this.calories,
      glycemicIndex: glycemicIndex ?? this.glycemicIndex,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      category: category ?? this.category,
    );
  }
}
