import 'package:doctor_care/core/db/db_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqlite_api.dart';

class HealthContextService {
  static Future<Map<String, dynamic>> buildLatestHealthContext() async {
    final db = await DbHelper.instance.database;
    final contextData = <String, dynamic>{};

    try {
      // Lấy active_profile
      final profileResult = await db.query(
        'family_profile',
        where: 'isActive = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (profileResult.isEmpty) return {};

      final profile = profileResult.first;
      final profileId = profile['id'] as int?;
      if (profileId == null) return {};

      contextData['user'] = {
        'gender': profile['gender'],
        'age': _calculateAge(profile['dateOfBirth'] as String?),
        'weight': profile['weight'],
        'height': profile['height'],
      };


      final results = await Future.wait([
        _getLatest(db, 'blood_sugar', profileId),
        _getLatest(db, 'blood_pressure', profileId),
        _getLatest(db, 'hba1c', profileId),
        _getLatest(db, 'cholesterol', profileId),
        _getLatest(db, 'bmi_weight', profileId),
        _getLatest(db, 'spo2heartrate', profileId),
        _getLatest(db, 'temperature', profileId),
        _getLatest(db, 'sleep_record', profileId),
        _getLatest(db, 'creatinine', profileId),
        _getLatestSteps(db, profileId),
        _getTodayWaterIntake(db, profileId),
        _getTodayMeals(db),
      ]);

      final bs = results[0] as Map<String, dynamic>?;
      final bp = results[1] as Map<String, dynamic>?;
      final hba1c = results[2] as Map<String, dynamic>?;
      final chol = results[3] as Map<String, dynamic>?;
      final bmi = results[4] as Map<String, dynamic>?;
      final spo2hr = results[5] as Map<String, dynamic>?;
      final temp = results[6] as Map<String, dynamic>?;
      final sleep = results[7] as Map<String, dynamic>?;
      final creatinine = results[8] as Map<String, dynamic>?;
      final steps = results[9] as Map<String, dynamic>?;
      final todayWater = results[10] as int;
      final todayMeals = results[11] as List<Map<String, dynamic>>;

      if (bs != null) {
        contextData['latest_blood_sugar'] = {
          'value': bs['value'],
          'mealStatus': bs['mealStatus'],
          'recordedAt': bs['timestamp'],
        };
      }

      if (bp != null) {
        contextData['latest_blood_pressure'] = {
          'systolic': bp['systolic'],
          'diastolic': bp['diastolic'],
          'recordedAt': bp['timestamp'],
        };
      }

      if (hba1c != null) {
        contextData['latest_hba1c'] = {
          'value': hba1c['value'],
          'recordedAt': hba1c['timestamp'],
        };
      }

      if (chol != null) {
        contextData['latest_cholesterol'] = {
          'ldl': chol['ldl'],
          'hdl': chol['hdl'],
          'triglycerides': chol['triglycerides'],
          'recordedAt': chol['timestamp'],
        };
      }

      if (bmi != null) {
        contextData['latest_bmi'] = {
          'value': bmi['bmi'],
          'recordedAt': bmi['timestamp'],
        };

        contextData['user']['latest_weight'] = bmi['weight'];
      }

      // ===== CÁC CHỈ SỐ MỚI =====

      if (spo2hr != null) {
        contextData['latest_spo2_heartrate'] = {
          'spo2': spo2hr['spo2'],
          'heartRate': spo2hr['heartRate'],
          'recordedAt': spo2hr['timestamp'],
        };
      }

      if (temp != null) {
        contextData['latest_temperature'] = {
          'value': temp['value'],
          'recordedAt': temp['timestamp'],
        };
      }

      if (sleep != null) {
        contextData['latest_sleep'] = {
          'bedTime': sleep['bedTime'],
          'wakeTime': sleep['wakeTime'],
          'quality': sleep['quality'],
          'recordedAt': sleep['timestamp'],
        };
      }

      if (creatinine != null) {
        contextData['latest_creatinine'] = {
          'value': creatinine['value'],
          'recordedAt': creatinine['timestamp'],
        };
      }

      if (steps != null) {
        contextData['today_steps'] = {
          'steps': steps['steps'],
          'caloriesBurned': steps['caloriesBurned'],
        };
      }

      contextData['today_water_ml'] = todayWater;

      // Tính tổng dinh dưỡng đã ăn hôm nay
      if (todayMeals.isNotEmpty) {
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;
        double totalFiber = 0;

        for (final meal in todayMeals) {
          final mealId = meal['id'] as int;
          final foods = await db.query(
            'food_items',
            where: 'meal_analysis_id = ?',
            whereArgs: [mealId],
          );
          for (final food in foods) {
            totalCalories += (food['calories'] as num?)?.toDouble() ?? 0;
            totalProtein += (food['protein'] as num?)?.toDouble() ?? 0;
            totalCarbs += (food['carbs'] as num?)?.toDouble() ?? 0;
            totalFat += (food['fat'] as num?)?.toDouble() ?? 0;
            totalFiber += (food['fiber'] as num?)?.toDouble() ?? 0;
          }
        }

        contextData['today_nutrition'] = {
          'mealsCount': todayMeals.length,
          'totalCalories': totalCalories,
          'totalProtein': totalProtein,
          'totalCarbs': totalCarbs,
          'totalFat': totalFat,
          'totalFiber': totalFiber,
        };
      }

      // Tính TDEE ước tính
      final user = contextData['user'] as Map<String, dynamic>;
      final tdee = _estimateTDEE(
        age: user['age'] as int?,
        gender: user['gender'] as String?,
        weightKg: (user['latest_weight'] ?? user['weight']) as num?,
        heightCm: user['height'] as num?,
        stepsToday: steps?['steps'] as int?,
      );
      if (tdee != null) {
        contextData['estimated_tdee'] = tdee;
      }
    } catch (e, stack) {
      debugPrint('HealthContextService error: $e\n$stack');
    }

    return contextData;
  }

  /// Tính TDEE ước tính dựa trên Harris-Benedict + mức hoạt động từ bước chân
  static double? _estimateTDEE({
    int? age,
    String? gender,
    num? weightKg,
    num? heightCm,
    int? stepsToday,
  }) {
    if (age == null || weightKg == null || heightCm == null) return null;

    // BMR theo Harris-Benedict
    double bmr;
    if (gender?.toLowerCase() == 'male' || gender == 'Nam') {
      bmr = 88.362 +
          (13.397 * weightKg.toDouble()) +
          (4.799 * heightCm.toDouble()) -
          (5.677 * age);
    } else {
      bmr = 447.593 +
          (9.247 * weightKg.toDouble()) +
          (3.098 * heightCm.toDouble()) -
          (4.330 * age);
    }

    // Activity multiplier dựa trên bước chân
    double activityMultiplier;
    if (stepsToday == null || stepsToday < 3000) {
      activityMultiplier = 1.2; // Ít vận động
    } else if (stepsToday < 7000) {
      activityMultiplier = 1.375; // Nhẹ
    } else if (stepsToday < 12000) {
      activityMultiplier = 1.55; // Trung bình
    } else {
      activityMultiplier = 1.725; // Nhiều
    }

    return bmr * activityMultiplier;
  }

  static int? _calculateAge(String? dobString) {
    if (dobString == null) return null;
    try {
      final dob = DateTime.parse(dobString);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _getLatest(
    Database db,
    String table,
    int profileId,
  ) async {
    try {
      // Xác định cột sắp xếp phù hợp cho từng bảng
      String orderColumn = 'timestamp';
      if (table == 'hba1c') orderColumn = 'date';

      final res = await db.query(
        table,
        where: 'profileId = ?',
        whereArgs: [profileId],
        orderBy: '$orderColumn DESC',
        limit: 1,
      );
      return res.isNotEmpty ? res.first : null;
    } catch (e) {
      debugPrint('Error getting latest $table: $e');
      return null;
    }
  }

  /// Lấy bước chân hôm nay
  static Future<Map<String, dynamic>?> _getLatestSteps(
    Database db,
    int profileId,
  ) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final res = await db.query(
        'step_count',
        where: 'profileId = ? AND timestamp >= ? AND timestamp < ?',
        whereArgs: [
          profileId,
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
        ],
        orderBy: 'timestamp DESC',
        limit: 1,
      );
      return res.isNotEmpty ? res.first : null;
    } catch (e) {
      debugPrint('Error getting steps: $e');
      return null;
    }
  }

  /// Tính tổng lượng nước uống hôm nay (ml)
  static Future<int> _getTodayWaterIntake(
    Database db,
    int profileId,
  ) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final res = await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM water_intake '
        'WHERE profileId = ? AND timestamp >= ? AND timestamp < ?',
        [
          profileId,
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
        ],
      );
      return (res.first['total'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint('Error getting water intake: $e');
      return 0;
    }
  }

  /// Lấy danh sách bữa ăn hôm nay
  static Future<List<Map<String, dynamic>>> _getTodayMeals(Database db) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return await db.query(
        'meal_analysis',
        where: 'timestamp >= ? AND timestamp < ?',
        whereArgs: [
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
        ],
      );
    } catch (e) {
      debugPrint('Error getting today meals: $e');
      return [];
    }
  }
}