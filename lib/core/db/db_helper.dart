import 'package:doctor_care/domain/entities/spO2heartrate.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  DbHelper._internal();

  static const _dbName = 'doctor_care.db';
  static const _dbVersion = 17;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await _ensureMealTablesExist(db);

    return db;
  }

  Future _onCreate(Database db, int version) async {
    // ✅ HbA1c table
    await db.execute('''
      CREATE TABLE hba1c (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL NOT NULL,
        date TEXT NOT NULL,
        profileId INTEGER
      )
    ''');

    // ✅ Blood Pressure table
    await db.execute('''
      CREATE TABLE blood_pressure (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        profileId INTEGER
      )
    ''');

    // ✅ Temperature table - FIX: Thêm measurementLocation và đổi date → timestamp
    await db.execute('''
      CREATE TABLE temperature (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL NOT NULL,
        timestamp TEXT NOT NULL,
        measurementLocation TEXT NOT NULL DEFAULT 'armpit',
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE spo2heartrate (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        spo2 INTEGER NOT NULL CHECK(spo2 >= 0 AND spo2 <= 100),
        heartRate INTEGER NOT NULL CHECK(heartRate >= 30 AND heartRate <= 250),
        timestamp TEXT NOT NULL,
        note TEXT
      )
    ''');

    // ✅ BMI/Weight table
    await db.execute('''
      CREATE TABLE bmi_weight (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT
      )
    ''');

    // ✅ Water Intake table
    await db.execute('''
      CREATE TABLE water_intake (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT
      )
    ''');

    // ✅ Blood Sugar table
    await db.execute('''
      CREATE TABLE blood_sugar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL NOT NULL,
        mealStatus TEXT NOT NULL DEFAULT 'random',
        timestamp TEXT NOT NULL,
        note TEXT
      )
    ''');

    // ✅ Sleep Record table
    await db.execute('''
      CREATE TABLE sleep_record (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bedTime TEXT NOT NULL,
        wakeTime TEXT NOT NULL,
        quality INTEGER NOT NULL CHECK(quality >= 1 AND quality <= 5),
        timestamp TEXT NOT NULL,
        note TEXT
      )
    ''');

    // ✅ Step Count table
    await db.execute('''
      CREATE TABLE step_count (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        steps INTEGER NOT NULL,
        distance REAL,
        caloriesBurned REAL,
        timestamp TEXT NOT NULL,
        note TEXT
      )
    ''');

    // ✅ Cholesterol table
    await db.execute('''
      CREATE TABLE cholesterol (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        totalCholesterol REAL NOT NULL,
        hdl REAL NOT NULL,
        ldl REAL NOT NULL,
        triglycerides REAL NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT
      )
    ''');

    // ✅ Meal Analysis table
    await db.execute('''
      CREATE TABLE meal_analysis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        image_path TEXT NOT NULL,
        user_id TEXT,
        notes TEXT,
        health_recommendations TEXT,
        dish_name TEXT
      )
    ''');

    // ✅ Food Items table
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_analysis_id INTEGER NOT NULL,
        food_name TEXT NOT NULL,
        food_name_en TEXT NOT NULL,
        portion_grams REAL NOT NULL,
        calories REAL NOT NULL,
        glycemic_index INTEGER NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        fiber REAL NOT NULL,
        category TEXT NOT NULL,
        FOREIGN KEY (meal_analysis_id) REFERENCES meal_analysis(id) ON DELETE CASCADE
      )
    ''');

    // ✅ Family Profile table
    await db.execute('''
      CREATE TABLE family_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        relationship TEXT NOT NULL DEFAULT 'other',
        dateOfBirth TEXT,
        gender TEXT,
        bloodType TEXT,
        height REAL,
        weight REAL,
        avatar TEXT,
        isActive INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    print('✅ Created all tables (version $version)');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from v$oldVersion to v$newVersion');

    // ✅ Upgrade từ version 2 → 3: Sửa bảng temperature
    if (oldVersion < 3) {
      try {
        // 1. Kiểm tra xem bảng temperature có tồn tại không
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='temperature'",
        );

        if (tables.isNotEmpty) {
          // 2. Backup dữ liệu cũ (nếu có)
          final oldData = await db.query('temperature');
          print('📦 Backing up ${oldData.length} temperature records');

          // 3. Xóa bảng cũ
          await db.execute('DROP TABLE IF EXISTS temperature');
          print('🗑️ Dropped old temperature table');

          // 4. Tạo bảng mới với schema đúng
          await db.execute('''
            CREATE TABLE temperature (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              value REAL NOT NULL,
              timestamp TEXT NOT NULL,
              measurementLocation TEXT NOT NULL DEFAULT 'armpit',
              note TEXT
            )
          ''');
          print('✅ Created new temperature table with correct schema');

          // 5. Migrate dữ liệu cũ sang bảng mới
          for (var record in oldData) {
            await db.insert('temperature', {
              'value': record['value'],
              'timestamp': record['date'], // ✅ Đổi date → timestamp
              'measurementLocation': 'armpit', // ✅ Default value
              'note': null,
            });
          }
          print('✅ Migrated ${oldData.length} records to new schema');
        } else {
          // Nếu chưa có bảng temperature, tạo mới
          await db.execute('''
            CREATE TABLE temperature (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              value REAL NOT NULL,
              timestamp TEXT NOT NULL,
              measurementLocation TEXT NOT NULL DEFAULT 'armpit',
              note TEXT
            )
          ''');
          print('✅ Created temperature table (first time)');
        }

        // 6. Tạo các bảng khác nếu chưa có
        await db.execute('''
          CREATE TABLE IF NOT EXISTS hba1c (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS blood_pressure (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            systolic INTEGER NOT NULL,
            diastolic INTEGER NOT NULL
          )
        ''');

        print('✅ Database upgrade completed');
      } catch (e) {
        print('❌ Error during database upgrade: $e');
        rethrow;
      }
    }

    // ✅ Upgrade to version 4: Create bmi_weight table
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bmi_weight (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          weight REAL NOT NULL,
          height REAL NOT NULL,
          timestamp TEXT NOT NULL,
          note TEXT
        )
      ''');
    }

    if (oldVersion < 5) {
      try {
        // 1. Fix temperature table
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='temperature'",
        );

        if (tables.isNotEmpty) {
          // Check current columns
          final columns = await db.rawQuery('PRAGMA table_info(temperature)');
          final columnNames = columns
              .map((col) => col['name'] as String)
              .toList();

          print('📊 Current temperature columns: $columnNames');

          // If 'date' column exists but 'timestamp' doesn't, migrate
          if (columnNames.contains('date') &&
              !columnNames.contains('timestamp')) {
            print('🔄 Migrating temperature table from date to timestamp');

            // Backup old data
            final oldData = await db.query('temperature');
            print('📦 Backing up ${oldData.length} records');

            // Drop old table
            await db.execute('DROP TABLE temperature');

            // Create new table with correct schema
            await db.execute('''
              CREATE TABLE temperature (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                value REAL NOT NULL,
                timestamp TEXT NOT NULL,
                measurementLocation TEXT NOT NULL DEFAULT 'armpit',
                note TEXT
              )
            ''');

            // Migrate data
            for (var record in oldData) {
              await db.insert('temperature', {
                'value': record['value'],
                'timestamp': record['date'], // date → timestamp
                'measurementLocation': 'armpit',
                'note': null,
              });
            }

            print('✅ Migrated ${oldData.length} records to new schema (v5)');
          } else {
            print('✅ Temperature table already has correct schema');
          }
        }

        // 2. Create spo2heartrate table if not exists
        await db.execute('''
          CREATE TABLE IF NOT EXISTS spo2heartrate (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            spo2 INTEGER NOT NULL CHECK(spo2 >= 0 AND spo2 <= 100),
            heartRate INTEGER NOT NULL CHECK(heartRate >= 30 AND heartRate <= 250),
            timestamp TEXT NOT NULL,
            note TEXT
          )
        ''');
        print('✅ Created spo2heartrate table (v5)');
      } catch (e) {
        print('❌ Error upgrading to v5: $e');
        rethrow;
      }
    }

    // ✅ Upgrade to version 6: Create water_intake table
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS water_intake (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount INTEGER NOT NULL,
          timestamp TEXT NOT NULL,
          note TEXT
        )
      ''');
      print('✅ Created water_intake table (v6)');
    }

    // ✅ Upgrade to version 7: Create meal_analysis and food_items tables
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS meal_analysis (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT NOT NULL,
          image_path TEXT NOT NULL,
          user_id TEXT,
          notes TEXT,
          health_recommendations TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS food_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          meal_analysis_id INTEGER NOT NULL,
          food_name TEXT NOT NULL,
          food_name_en TEXT NOT NULL,
          portion_grams REAL NOT NULL,
          calories REAL NOT NULL,
          glycemic_index INTEGER NOT NULL,
          protein REAL NOT NULL,
          carbs REAL NOT NULL,
          fat REAL NOT NULL,
          fiber REAL NOT NULL,
          category TEXT NOT NULL,
          FOREIGN KEY (meal_analysis_id) REFERENCES meal_analysis(id) ON DELETE CASCADE
        )
      ''');
      print('✅ Created meal_analysis and food_items tables (v7)');
    }

    // ✅ Upgrade to version 8: Add dish_name to meal_analysis
    if (oldVersion < 8) {
      try {
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='meal_analysis'",
        );

        if (tables.isNotEmpty) {
          // Check if dish_name column exists
          final columns = await db.rawQuery('PRAGMA table_info(meal_analysis)');
          final columnNames = columns
              .map((col) => col['name'] as String)
              .toList();

          if (!columnNames.contains('dish_name')) {
            await db.execute(
              'ALTER TABLE meal_analysis ADD COLUMN dish_name TEXT',
            );
            print('✅ Added dish_name column to meal_analysis table (v8)');
          }
        }
      } catch (e) {
        print('❌ Error adding dish_name column: $e');
      }
    }

    // ✅ Upgrade to version 9: Create blood_sugar, sleep_record, step_count, cholesterol tables
    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS blood_sugar (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          value REAL NOT NULL,
          mealStatus TEXT NOT NULL DEFAULT 'random',
          timestamp TEXT NOT NULL,
          note TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sleep_record (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bedTime TEXT NOT NULL,
          wakeTime TEXT NOT NULL,
          quality INTEGER NOT NULL CHECK(quality >= 1 AND quality <= 5),
          timestamp TEXT NOT NULL,
          note TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS step_count (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          steps INTEGER NOT NULL,
          distance REAL,
          caloriesBurned REAL,
          timestamp TEXT NOT NULL,
          note TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS cholesterol (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          totalCholesterol REAL NOT NULL,
          hdl REAL NOT NULL,
          ldl REAL NOT NULL,
          triglycerides REAL NOT NULL,
          timestamp TEXT NOT NULL,
          note TEXT
        )
      ''');
      print(
        '✅ Created blood_sugar, sleep_record, step_count, cholesterol tables (v9)',
      );
    }

    // ✅ Upgrade to version 10: Create family_profile table
    if (oldVersion < 10) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS family_profile (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          relationship TEXT NOT NULL DEFAULT 'other',
          dateOfBirth TEXT,
          gender TEXT,
          bloodType TEXT,
          height REAL,
          weight REAL,
          avatar TEXT,
          isActive INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL
        )
      ''');
      print('✅ Created family_profile table (v10)');
    }

    // ✅ Upgrade to version 11: Add profileId to blood_pressure
    if (oldVersion < 11) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(blood_pressure)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('profileId')) {
          await db.execute(
            'ALTER TABLE blood_pressure ADD COLUMN profileId INTEGER',
          );
          print('Đã thêm cột profileId vào bảng huyết áp (v11)');
        }
      } catch (e) {
        print('Lỗi khi thêm profileId vào blood_pressure: $e');
      }
    }

    if (oldVersion < 12) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(hba1c)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('profileId')) {
          await db.execute('ALTER TABLE hba1c ADD COLUMN profileId INTEGER');
          print('Đã thêm cột profileId vào bảng hba1c (v12)');
        }
      } catch (e) {
        print('Lỗi khi thêm profileId vào hba1c: $e');
      }
    }

    if (oldVersion < 13) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(temperature)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('profileId')) {
          await db.execute(
            'ALTER TABLE temperature ADD COLUMN profileId INTEGER',
          );
          print('Đã thêm cột profileId vào bảng temperature (v13)');
        }
      } catch (e) {
        print('Lỗi khi thêm profileId vào temperature: $e');
      }
    }

    if (oldVersion < 14) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(spo2heartrate)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('profileId')) {
          await db.execute(
            'ALTER TABLE spo2heartrate ADD COLUMN profileId INTEGER',
          );
          print('Đã thêm cột profileId vào bảng spo2heartrate (v14)');
        }
      } catch (e) {
        print('Lỗi khi thêm profileId vào spo2heartrate: $e');
      }
    }

    if (oldVersion < 16) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(blood_sugar)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('profileId')) {
          await db.execute(
            'ALTER TABLE blood_sugar ADD COLUMN profileId INTEGER',
          );
          print('Đã thêm cột profileId vào bảng blood_sugar (v16)');
        }
      } catch (e) {
        print('Lỗi khi thêm profileId vào blood_sugar: $e');
      }
    }

    if (oldVersion < 17) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(cholesterol)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('profileId')) {
          await db.execute(
            'ALTER TABLE cholesterol ADD COLUMN profileId INTEGER',
          );
          print('Đã thêm cột profileId vào bảng cholesterol (v16)');
        }
      } catch (e) {
        print('Lỗi khi thêm profileId vào cholesterol: $e');
      }
    }

    print('Nâng cấp cơ sở dữ liệu đã hoàn tất');
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('🗑️ Database deleted');
  }

  Future<void> checkSchema() async {
    final db = await database;

    // Check all tables
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    print('📊 All tables: ${tables.map((t) => t['name']).toList()}');

    // Check temperature schema
    final tempSchema = await db.rawQuery(
      "SELECT sql FROM sqlite_master WHERE type='table' AND name='temperature'",
    );
    if (tempSchema.isNotEmpty) {
      print('Temperature schema: ${tempSchema.first['sql']}');
    }

    // Check spo2heartrate schema
    final spo2Schema = await db.rawQuery(
      "SELECT sql FROM sqlite_master WHERE type='table' AND name='spo2heartrate'",
    );
    if (spo2Schema.isNotEmpty) {
      print('Spo2HeartRate schema: ${spo2Schema.first['sql']}');
    } else {
      print('Table spo2heartrate does not exist!');
    }
  }

  // Force recreate database - USE THIS TO FIX SCHEMA ISSUES
  Future<void> recreateDatabase() async {
    print('🔄 Recreating database...');
    await deleteDatabase();
    _database = await _initDatabase();
    print('✅ Database recreated successfully');
  }

  Future<void> updateSpo2HeartRate(SpO2HeartRate record) async {}

  Future<void> _ensureMealTablesExist(Database db) async {
    // Check if meal_analysis table exists
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='meal_analysis'",
    );

    if (tables.isEmpty) {
      print('⚠️ Table meal_analysis missing, forcing creation...');

      // Create meal_analysis table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS meal_analysis (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT NOT NULL,
          image_path TEXT NOT NULL,
          user_id TEXT,
          notes TEXT,
          health_recommendations TEXT,
          dish_name TEXT
        )
      ''');

      // Create food_items table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS food_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          meal_analysis_id INTEGER NOT NULL,
          food_name TEXT NOT NULL,
          food_name_en TEXT NOT NULL,
          portion_grams REAL NOT NULL,
          calories REAL NOT NULL,
          glycemic_index INTEGER NOT NULL,
          protein REAL NOT NULL,
          carbs REAL NOT NULL,
          fat REAL NOT NULL,
          fiber REAL NOT NULL,
          category TEXT NOT NULL,
          FOREIGN KEY (meal_analysis_id) REFERENCES meal_analysis(id) ON DELETE CASCADE
        )
      ''');

      print('✅ Forced creation of meal analysis tables');
    } else {
      // Check if dish_name column exists (in case table exists but column missing)
      try {
        final columns = await db.rawQuery('PRAGMA table_info(meal_analysis)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();

        if (!columnNames.contains('dish_name')) {
          await db.execute(
            'ALTER TABLE meal_analysis ADD COLUMN dish_name TEXT',
          );
          print('✅ Added dish_name column to existing meal_analysis table');
        }
      } catch (e) {
        print('❌ Error checking/adding dish_name column: $e');
      }
    }
  }
}
