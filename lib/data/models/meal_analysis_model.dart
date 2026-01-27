import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/domain/entities/food_item.dart';
import 'package:doctor_care/data/models/food_item_model.dart';

/// Data model for MealAnalysis with JSON and database serialization
class MealAnalysisModel extends MealAnalysis {
  const MealAnalysisModel({
    super.id,
    required super.timestamp,
    required super.imagePath,
    super.dishName,
    required super.foodItems,
    super.userId,
    super.notes,
    super.healthRecommendations,
  });

  /// Convert from entity to model
  factory MealAnalysisModel.fromEntity(MealAnalysis entity) {
    return MealAnalysisModel(
      id: entity.id,
      timestamp: entity.timestamp,
      imagePath: entity.imagePath,
      dishName: entity.dishName,
      foodItems: entity.foodItems,
      userId: entity.userId,
      notes: entity.notes,
      healthRecommendations: entity.healthRecommendations,
    );
  }

  /// Convert from JSON
  factory MealAnalysisModel.fromJson(Map<String, dynamic> json) {
    return MealAnalysisModel(
      id: json['id'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['imagePath'] as String,
      dishName: json['dishName'] as String?,
      foodItems: (json['foodItems'] as List<dynamic>)
          .map((item) => FoodItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      userId: json['userId'] as String?,
      notes: json['notes'] as String?,
      healthRecommendations: json['healthRecommendations'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
      'dishName': dishName,
      'foodItems': foodItems
          .map((item) => FoodItemModel.fromEntity(item).toJson())
          .toList(),
      'userId': userId,
      'notes': notes,
      'healthRecommendations': healthRecommendations,
    };
  }

  /// Convert from database map (without food items)
  factory MealAnalysisModel.fromMap(
    Map<String, dynamic> map, {
    List<FoodItem>? foodItems,
  }) {
    return MealAnalysisModel(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      imagePath: map['image_path'] as String,
      dishName: map['dish_name'] as String?,
      foodItems: foodItems ?? [],
      userId: map['user_id'] as String?,
      notes: map['notes'] as String?,
      healthRecommendations: map['health_recommendations'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'image_path': imagePath,
      'dish_name': dishName,
      'user_id': userId,
      'notes': notes,
      'health_recommendations': healthRecommendations,
    };
  }

  /// Convert to entity
  MealAnalysis toEntity() {
    return MealAnalysis(
      id: id,
      timestamp: timestamp,
      imagePath: imagePath,
      dishName: dishName,
      foodItems: foodItems,
      userId: userId,
      notes: notes,
      healthRecommendations: healthRecommendations,
    );
  }
}
