// Script tạo food_database.db từ food_database_generated.dart
// Chạy: dart run tool/generate_food_db.dart

import 'dart:io';
import 'dart:convert';

void main() async {
  final inputFile = File('lib/core/database_food/food_database_generated.dart');
  final content = inputFile.readAsStringSync();

  // Parse tất cả FoodNutrition entries
  final foods = <Map<String, dynamic>>[];

  final regex = RegExp(
    r"'(\w+)':\s*FoodNutrition\(\s*"
    r"name:\s*'((?:[^'\\]|\\.)*)'\s*,\s*"
    r"nameEn:\s*'((?:[^'\\]|\\.)*)'\s*,\s*"
    r"caloriesPer100g:\s*([\d.]+)\s*,\s*"
    r"glycemicIndex:\s*(\d+)\s*,\s*"
    r"protein:\s*([\d.]+)\s*,\s*"
    r"carbs:\s*([\d.]+)\s*,\s*"
    r"fat:\s*([\d.]+)\s*,\s*"
    r"fiber:\s*([\d.]+)\s*,\s*"
    r"category:\s*'((?:[^'\\]|\\.)*)'\s*,?\s*\)",
    multiLine: true,
  );

  for (final match in regex.allMatches(content)) {
    foods.add({
      'key': match.group(1)!,
      'name': match.group(2)!.replaceAll("\\'", "'"),
      'name_en': match.group(3)!.replaceAll("\\'", "'"),
      'calories_per_100g': double.parse(match.group(4)!),
      'glycemic_index': int.parse(match.group(5)!),
      'protein': double.parse(match.group(6)!),
      'carbs': double.parse(match.group(7)!),
      'fat': double.parse(match.group(8)!),
      'fiber': double.parse(match.group(9)!),
      'category': match.group(10)!.replaceAll("\\'", "'"),
    });
  }

  print('Parsed ${foods.length} food items');

  // Tạo file SQL để import
  final sqlFile = File('assets/database/food_database.sql');
  await sqlFile.parent.create(recursive: true);

  final sb = StringBuffer();
  sb.writeln('CREATE TABLE IF NOT EXISTS foods (');
  sb.writeln('  id INTEGER PRIMARY KEY AUTOINCREMENT,');
  sb.writeln('  key TEXT NOT NULL UNIQUE,');
  sb.writeln('  name TEXT NOT NULL,');
  sb.writeln('  name_en TEXT NOT NULL,');
  sb.writeln('  calories_per_100g REAL NOT NULL,');
  sb.writeln('  glycemic_index INTEGER NOT NULL,');
  sb.writeln('  protein REAL NOT NULL,');
  sb.writeln('  carbs REAL NOT NULL,');
  sb.writeln('  fat REAL NOT NULL,');
  sb.writeln('  fiber REAL NOT NULL,');
  sb.writeln('  category TEXT NOT NULL');
  sb.writeln(');');
  sb.writeln();

  for (final food in foods) {
    final name = (food['name'] as String).replaceAll("'", "''");
    final nameEn = (food['name_en'] as String).replaceAll("'", "''");
    final category = (food['category'] as String).replaceAll("'", "''");
    sb.writeln(
      "INSERT INTO foods (key, name, name_en, calories_per_100g, glycemic_index, protein, carbs, fat, fiber, category) "
      "VALUES ('${food['key']}', '$name', '$nameEn', ${food['calories_per_100g']}, ${food['glycemic_index']}, "
      "${food['protein']}, ${food['carbs']}, ${food['fat']}, ${food['fiber']}, '$category');",
    );
  }

  await sqlFile.writeAsString(sb.toString());
  print('SQL file created: ${sqlFile.path}');

  // Tạo file JSON (backup)
  final jsonFile = File('assets/database/food_database.json');
  await jsonFile.writeAsString(const JsonEncoder.withIndent('  ').convert(foods));
  print('JSON file created: ${jsonFile.path}');

  print('\nDone! Now run the following to create the .db file:');
  print('  sqlite3 assets/database/food_database.db < assets/database/food_database.sql');
}
