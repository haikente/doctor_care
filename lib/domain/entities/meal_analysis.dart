import 'package:equatable/equatable.dart';
import 'package:doctor_care/domain/entities/food_item.dart';

/// Entity representing a complete meal analysis
class MealAnalysis extends Equatable {
  final int? id;
  final DateTime timestamp;
  final String imagePath;
  final List<FoodItem> foodItems;
  final String? userId;
  final String? notes;
  final String? healthRecommendations;

  const MealAnalysis({
    this.id,
    required this.timestamp,
    required this.imagePath,
    required this.foodItems,
    this.userId,
    this.notes,
    this.healthRecommendations,
  });

  @override
  List<Object?> get props => [
    id,
    timestamp,
    imagePath,
    foodItems,
    userId,
    notes,
    healthRecommendations,
  ];

  /// Calculate total calories from all food items
  double get totalCalories {
    return foodItems.fold(0.0, (sum, item) => sum + item.calories);
  }

  /// Calculate total protein from all food items
  double get totalProtein {
    return foodItems.fold(0.0, (sum, item) => sum + item.protein);
  }

  /// Calculate total carbs from all food items
  double get totalCarbs {
    return foodItems.fold(0.0, (sum, item) => sum + item.carbs);
  }

  /// Calculate total fat from all food items
  double get totalFat {
    return foodItems.fold(0.0, (sum, item) => sum + item.fat);
  }

  /// Calculate total fiber from all food items
  double get totalFiber {
    return foodItems.fold(0.0, (sum, item) => sum + item.fiber);
  }

  /// Calculate average glycemic index (weighted by carbs)
  double get averageGlycemicIndex {
    if (foodItems.isEmpty) return 0.0;

    double totalWeightedGI = 0.0;
    double totalCarbs = 0.0;

    for (var item in foodItems) {
      if (item.carbs > 0) {
        totalWeightedGI += item.glycemicIndex * item.carbs;
        totalCarbs += item.carbs;
      }
    }

    return totalCarbs > 0 ? totalWeightedGI / totalCarbs : 0.0;
  }

  /// Get GI level category
  String get giLevel {
    final avgGI = averageGlycemicIndex;
    if (avgGI <= 55) return 'Thấp';
    if (avgGI <= 69) return 'Trung bình';
    return 'Cao';
  }

  /// Create a copy with updated fields
  MealAnalysis copyWith({
    int? id,
    DateTime? timestamp,
    String? imagePath,
    List<FoodItem>? foodItems,
    String? userId,
    String? notes,
    String? healthRecommendations,
  }) {
    return MealAnalysis(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
      foodItems: foodItems ?? this.foodItems,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      healthRecommendations:
          healthRecommendations ?? this.healthRecommendations,
    );
  }
}
