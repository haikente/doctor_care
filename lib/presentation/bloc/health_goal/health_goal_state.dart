import 'package:equatable/equatable.dart';

class HealthGoalState extends Equatable {
  final int dailySteps;
  final int dailyWaterMl;
  final int dailyCalories;
  final double sleepHours;
  final double targetWeight;

  const HealthGoalState({
    this.dailySteps = 10000,
    this.dailyWaterMl = 2000,
    this.dailyCalories = 2000,
    this.sleepHours = 8.0,
    this.targetWeight = 0,
  });

  HealthGoalState copyWith({
    int? dailySteps,
    int? dailyWaterMl,
    int? dailyCalories,
    double? sleepHours,
    double? targetWeight,
  }) {
    return HealthGoalState(
      dailySteps: dailySteps ?? this.dailySteps,
      dailyWaterMl: dailyWaterMl ?? this.dailyWaterMl,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      sleepHours: sleepHours ?? this.sleepHours,
      targetWeight: targetWeight ?? this.targetWeight,
    );
  }

  @override
  List<Object> get props => [
        dailySteps,
        dailyWaterMl,
        dailyCalories,
        sleepHours,
        targetWeight,
      ];
}
