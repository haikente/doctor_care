// Script tạo food_database.db trực tiếp bằng sqlite3
// Chạy: dart run tool/create_food_db.dart

import 'dart:io';
import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';

void main() {
  // Đọc JSON đã generate
  final jsonFile = File('assets/database/food_database.json');
  final foods = jsonDecode(jsonFile.readAsStringSync()) as List<dynamic>;
  print('Loaded ${foods.length} food items from JSON');

  // Tạo database
  final dbPath = 'assets/database/food_database.db';
  final dbFile = File(dbPath);
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
    print('Deleted existing database');
  }

  final db = sqlite3.open(dbPath);

  // Tạo bảng
  db.execute('''
    CREATE TABLE IF NOT EXISTS foods (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      name_en TEXT NOT NULL,
      calories_per_100g REAL NOT NULL,
      glycemic_index INTEGER NOT NULL,
      protein REAL NOT NULL,
      carbs REAL NOT NULL,
      fat REAL NOT NULL,
      fiber REAL NOT NULL,
      category TEXT NOT NULL
    )
  ''');

  // Tạo indexes
  db.execute('CREATE INDEX idx_foods_name ON foods(name)');
  db.execute('CREATE INDEX idx_foods_name_en ON foods(name_en)');
  db.execute('CREATE INDEX idx_foods_category ON foods(category)');
  db.execute('CREATE INDEX idx_foods_key ON foods(key)');

  // Insert dữ liệu
  final stmt = db.prepare('''
    INSERT OR REPLACE INTO foods (key, name, name_en, calories_per_100g, glycemic_index, protein, carbs, fat, fiber, category)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''');

  db.execute('BEGIN TRANSACTION');
  for (final food in foods) {
    stmt.execute([
      food['key'],
      food['name'],
      food['name_en'],
      food['calories_per_100g'],
      food['glycemic_index'],
      food['protein'],
      food['carbs'],
      food['fat'],
      food['fiber'],
      food['category'],
    ]);
  }
  db.execute('COMMIT');
  stmt.dispose();

  // Verify
  final result = db.select('SELECT COUNT(*) as count FROM foods');
  print('Database created: $dbPath');
  print('Total records: ${result.first['count']}');

  // Liệt kê categories
  final categories =
      db.select('SELECT category, COUNT(*) as count FROM foods GROUP BY category ORDER BY count DESC');
  print('\nCategories (${categories.length}):');
  for (final row in categories) {
    print('  - ${row['category']} (${row['count']} items)');
  }

  db.dispose();
  print('\n✅ food_database.db created successfully!');
}
