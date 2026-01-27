import 'package:doctor_care/domain/entities/food_item.dart';

/// Data model for FoodItem with JSON and database serialization
class FoodItemModel extends FoodItem {
  const FoodItemModel({
    super.id,
    required super.foodName,
    required super.foodNameEn,
    required super.portionGrams,
    required super.calories,
    required super.glycemicIndex,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.fiber,
    required super.category,
  });

  /// Convert from entity to model
  factory FoodItemModel.fromEntity(FoodItem entity) {
    return FoodItemModel(
      id: entity.id,
      foodName: entity.foodName,
      foodNameEn: entity.foodNameEn,
      portionGrams: entity.portionGrams,
      calories: entity.calories,
      glycemicIndex: entity.glycemicIndex,
      protein: entity.protein,
      carbs: entity.carbs,
      fat: entity.fat,
      fiber: entity.fiber,
      category: entity.category,
    );
  }

  /// Convert from JSON
  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'] as int?,
      foodName: json['foodName'] as String,
      foodNameEn: json['foodNameEn'] as String,
      portionGrams: (json['portionGrams'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      glycemicIndex: json['glycemicIndex'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      category: json['category'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'foodNameEn': foodNameEn,
      'portionGrams': portionGrams,
      'calories': calories,
      'glycemicIndex': glycemicIndex,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'category': category,
    };
  }

  /// Convert from database map
  factory FoodItemModel.fromMap(Map<String, dynamic> map) {
    return FoodItemModel(
      id: map['id'] as int?,
      foodName: map['food_name'] as String,
      foodNameEn: map['food_name_en'] as String,
      portionGrams: (map['portion_grams'] as num).toDouble(),
      calories: (map['calories'] as num).toDouble(),
      glycemicIndex: map['glycemic_index'] as int,
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      fiber: (map['fiber'] as num).toDouble(),
      category: map['category'] as String,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap({int? mealAnalysisId}) {
    return {
      'id': id,
      'meal_analysis_id': mealAnalysisId,
      'food_name': foodName,
      'food_name_en': foodNameEn,
      'portion_grams': portionGrams,
      'calories': calories,
      'glycemic_index': glycemicIndex,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'category': category,
    };
  }

  /// Convert to entity
  FoodItem toEntity() {
    return FoodItem(
      id: id,
      foodName: foodName,
      foodNameEn: foodNameEn,
      portionGrams: portionGrams,
      calories: calories,
      glycemicIndex: glycemicIndex,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      category: category,
    );
  }
}
