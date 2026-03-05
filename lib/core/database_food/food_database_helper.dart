import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:doctor_care/domain/entities/food_nutrition.dart';

/// Helper class để đọc food database từ file .db
/// Thay thế cho FoodDatabaseGenerated (static Map)
class FoodDatabaseHelper {
  static Database? _database;
  static final FoodDatabaseHelper instance = FoodDatabaseHelper._();

  FoodDatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'food_database.db');

    // Kiểm tra nếu database chưa tồn tại thì copy từ assets
    final exists = await databaseExists(path);
    if (!exists) {
      // Copy từ assets
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      final data = await rootBundle.load('assets/database/food_database.db');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path, readOnly: true);
  }

  /// Lấy tất cả foods
  Future<List<FoodNutrition>> getAllFoods() async {
    final db = await database;
    final rows = await db.query('foods');
    return rows.map(_fromRow).toList();
  }

  /// Lấy foods theo category
  Future<List<FoodNutrition>> getFoodsByCategory(String category) async {
    final db = await database;
    final rows = await db.query(
      'foods',
      where: 'category = ?',
      whereArgs: [category],
    );
    return rows.map(_fromRow).toList();
  }

  /// Lấy tất cả categories
  Future<List<String>> getCategories() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT category FROM foods ORDER BY category',
    );
    return rows.map((r) => r['category'] as String).toList();
  }

  /// Tìm food theo tên (Vietnamese)
  Future<FoodNutrition?> findByName(String name) async {
    final db = await database;
    final rows = await db.query(
      'foods',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  /// Tìm food theo tên (English)
  Future<FoodNutrition?> findByNameEn(String nameEn) async {
    final db = await database;
    final rows = await db.query(
      'foods',
      where: 'name_en LIKE ?',
      whereArgs: ['%$nameEn%'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  /// Tìm food theo tên (cả Vietnamese và English)
  Future<FoodNutrition?> findFood(String name, String nameEn) async {
    // Tìm theo tên tiếng Việt trước
    final byVi = await findByName(name);
    if (byVi != null) return byVi;

    // Tìm theo tên tiếng Anh
    return await findByNameEn(nameEn);
  }

  /// Tìm kiếm food (trả về nhiều kết quả)
  Future<List<FoodNutrition>> searchFoods(String query) async {
    final db = await database;
    final rows = await db.query(
      'foods',
      where: 'name LIKE ? OR name_en LIKE ? OR key LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return rows.map(_fromRow).toList();
  }

  /// Lấy food theo key
  Future<FoodNutrition?> getByKey(String key) async {
    final db = await database;
    final rows = await db.query(
      'foods',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  /// Lấy tổng số records
  Future<int> getCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM foods');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Convert row to FoodNutrition
  FoodNutrition _fromRow(Map<String, dynamic> row) {
    return FoodNutrition(
      name: row['name'] as String,
      nameEn: row['name_en'] as String,
      caloriesPer100g: (row['calories_per_100g'] as num).toDouble(),
      glycemicIndex: (row['glycemic_index'] as num).toInt(),
      protein: (row['protein'] as num).toDouble(),
      carbs: (row['carbs'] as num).toDouble(),
      fat: (row['fat'] as num).toDouble(),
      fiber: (row['fiber'] as num).toDouble(),
      category: row['category'] as String,
    );
  }

  /// Đóng database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
