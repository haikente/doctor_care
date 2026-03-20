import 'package:doctor_care/presentation/bloc/health_goal/health_goal_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthGoalCubit extends Cubit<HealthGoalState> {
  static const _keySteps = 'goal_steps';
  static const _keyWater = 'goal_water';
  static const _keyCalories = 'goal_calories';
  static const _keySleep = 'goal_sleep';
  static const _keyWeight = 'goal_weight';

  HealthGoalCubit() : super(const HealthGoalState()) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(
      dailySteps: prefs.getInt(_keySteps) ?? 10000,
      dailyWaterMl: prefs.getInt(_keyWater) ?? 2000,
      dailyCalories: prefs.getInt(_keyCalories) ?? 2000,
      sleepHours: prefs.getDouble(_keySleep) ?? 8.0,
      targetWeight: prefs.getDouble(_keyWeight) ?? 0,
    ));
  }

  Future<void> updateDailySteps(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySteps, value);
    emit(state.copyWith(dailySteps: value));
  }

  Future<void> updateDailyWater(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWater, value);
    emit(state.copyWith(dailyWaterMl: value));
  }

  Future<void> updateDailyCalories(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCalories, value);
    emit(state.copyWith(dailyCalories: value));
  }

  Future<void> updateSleepHours(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySleep, value);
    emit(state.copyWith(sleepHours: value));
  }

  Future<void> updateTargetWeight(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyWeight, value);
    emit(state.copyWith(targetWeight: value));
  }
}
