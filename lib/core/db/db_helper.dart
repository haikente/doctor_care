import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  DbHelper._internal();

  static const _defaultDbName = 'doctor_care.db';
  static const _dbVersion = 32;
  static String get dbName => instance.currentDbName;
  static const dbVersion = _dbVersion;

  String? _currentUserId;

  Database? _database;

  String get currentDbName => _dbNameForUser(_currentUserId);

  Future<void> setCurrentUser(String? userId) async {
    final normalized = _normalizeUserId(userId);
    if (normalized == _currentUserId) return;
    await closeDatabase();
    _currentUserId = normalized;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, currentDbName);

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await _ensureMealTablesExist(db);

    return db;
  }

  /// Closes the database connection safely. Useful for backup/restore operations.
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('🔒 Database connection closed safely');
    }
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
        source TEXT NOT NULL DEFAULT 'manual',
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
        note TEXT,
        profileId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE spo2heartrate (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        spo2 INTEGER NOT NULL CHECK(spo2 >= 0 AND spo2 <= 100),
        heartRate INTEGER NOT NULL CHECK(heartRate >= 30 AND heartRate <= 250),
        timestamp TEXT NOT NULL,
        note TEXT,
        source TEXT NOT NULL DEFAULT 'manual',
        profileId INTEGER
      )
    ''');

    // ✅ BMI/Weight table
    await db.execute('''
      CREATE TABLE bmi_weight (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT,
        source TEXT NOT NULL DEFAULT 'manual',
        profileId INTEGER
      )
    ''');

    // ✅ Water Intake table
    await db.execute('''
      CREATE TABLE water_intake (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT,
        profileId INTEGER
      )
    ''');

    // ✅ Blood Sugar table
    await db.execute('''
      CREATE TABLE blood_sugar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL NOT NULL,
        mealStatus TEXT NOT NULL DEFAULT 'random',
        timestamp TEXT NOT NULL,
        note TEXT,
        profileId INTEGER
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
        note TEXT,
        profileId INTEGER
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
        note TEXT,
        source TEXT NOT NULL DEFAULT 'manual',
        profileId INTEGER
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
        note TEXT,
        profileId INTEGER
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
        dish_name TEXT,
        meal_type TEXT
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

    // ✅ Creatinine table
    await db.execute('''
      CREATE TABLE creatinine (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT,
        age INTEGER,
        gender TEXT,
        profileId INTEGER
      )
    ''');

    // ✅ Menstrual Cycle table
    await db.execute('''
      CREATE TABLE menstrual_cycle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startDate TEXT NOT NULL,
        endDate TEXT,
        cycleLength INTEGER,
        periodLength INTEGER NOT NULL DEFAULT 5,
        symptoms TEXT,
        note TEXT,
        profileId INTEGER
      )
    ''');

    // Tạo unique index cho các bảng có profileId và timestamp/date
    try {
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_step_count_profile_timestamp ON step_count(profileId, timestamp)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_blood_pressure_profile_timestamp ON blood_pressure(profileId, timestamp)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_hba1c_profile_date ON hba1c(profileId, date)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_temperature_profile_timestamp ON temperature(profileId, timestamp)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_spo2heartrate_profile_timestamp ON spo2heartrate(profileId, timestamp)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_bmi_weight_profile_timestamp ON bmi_weight(profileId, timestamp)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_water_intake_profile_timestamp ON water_intake(profileId, timestamp)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_blood_sugar_profile_timestamp ON blood_sugar(profileId, timestamp)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_cholesterol_profile_timestamp ON cholesterol(profileId, timestamp)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_creatinine_profile_timestamp ON creatinine(profileId, timestamp)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_sleep_record_profile_timestamp ON sleep_record(profileId, timestamp)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_menstrual_cycle_profile_startDate ON menstrual_cycle(profileId, startDate)',
      );
    } catch (e) {
      print('❌ Error creating unique indexes in onCreate: $e');
    }

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

        print('Database upgrade completed');
      } catch (e) {
        print('Error during database upgrade: $e');
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

            print('Migrated ${oldData.length} records to new schema (v5)');
          } else {
            print('Temperature table already has correct schema');
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
        print('Created spo2heartrate table (v5)');
      } catch (e) {
        print('Error upgrading to v5: $e');
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
          health_recommendations TEXT,
          meal_type TEXT
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
      print('Created meal_analysis and food_items tables (v7)');
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
            print('Added dish_name column to meal_analysis table (v8)');
          }
        }
      } catch (e) {
        print('Error adding dish_name column: $e');
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
          note TEXT,
          source TEXT NOT NULL DEFAULT 'manual'
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

    if (oldVersion < 18) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS creatinine (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          value REAL NOT NULL,
          timestamp TEXT NOT NULL,
          note TEXT,
          age INTEGER,
          gender TEXT,
          profileId INTEGER
        )
      ''');
      print('Created creatinine table (v18)');
    }

    if (oldVersion < 19) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(bmi_weight)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('profileId')) {
          await db.execute(
            'ALTER TABLE bmi_weight ADD COLUMN profileId INTEGER',
          );
          print('Đã thêm cột profileId vào bảng bmi_weight (v19)');
        }
      } catch (e) {
        print('Lỗi khi thêm profileId vào bmi_weight: $e');
      }
    }

    if (oldVersion < 20) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(water_intake)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('profileId')) {
          await db.execute(
            'ALTER TABLE water_intake ADD COLUMN profileId INTEGER',
          );
          print('Đã thêm cột profileId vào bảng water_intake (v20)');
        }
      } catch (e) {
        print('Lỗi khi thêm profileId vào water_intake: $e');
      }
    }

     if (oldVersion < 21) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(step_count)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('profileId')) {
          await db.execute(
            'ALTER TABLE step_count ADD COLUMN profileId INTEGER',
          );
          print('Đã thêm cột profileId vào bảng step_count (v21)');
        }
      } catch (e) {
        print('Lỗi khi thêm profileId vào step_count: $e');
      }
    }

    if (oldVersion < 25) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(sleep_record)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('profileId')) {
          await db.execute(
            'ALTER TABLE sleep_record ADD COLUMN profileId INTEGER',
          );
          print('Đã thêm cột profileId vào bảng sleep_record (v2)');
        }
      } catch (e) {
        print('Lỗi khi thêm profileId vào sleep_record: $e');
      }
    }

    if (oldVersion < 22) {
      Future<void> ensureProfileId(String table) async {
        try {
          final columns = await db.rawQuery('PRAGMA table_info($table)');
          final columnNames = columns.map((col) => col['name'] as String).toList();
          if (!columnNames.contains('profileId')) {
            await db.execute('ALTER TABLE $table ADD COLUMN profileId INTEGER');
            print('Added profileId to $table (v22)');
          }
        } catch (e) {
          print(' Error adding profileId to $table (v22): $e');
        }
      }

      await ensureProfileId('temperature');
      await ensureProfileId('water_intake');
      await ensureProfileId('step_count');
      await ensureProfileId('spo2heartrate');
      await ensureProfileId('cholesterol');
    }

    if (oldVersion < 23) {
      try {
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_step_count_profile_timestamp ON step_count(profileId, timestamp)',
        );
        print('Created unique index idx_step_count_profile_timestamp (v23)');
      } catch (e) {
        print('Error creating unique index for step_count (v23): $e');
      }
    }

    if (oldVersion < 24) {
      final indexes = {
        'idx_blood_pressure_profile_timestamp': 'blood_pressure(profileId, timestamp)',
        'idx_hba1c_profile_date': 'hba1c(profileId, date)',
        'idx_temperature_profile_timestamp': 'temperature(profileId, timestamp)',
        'idx_spo2heartrate_profile_timestamp': 'spo2heartrate(profileId, timestamp)',
        'idx_bmi_weight_profile_timestamp': 'bmi_weight(profileId, timestamp)',
        'idx_water_intake_profile_timestamp': 'water_intake(profileId, timestamp)',
        'idx_blood_sugar_profile_timestamp': 'blood_sugar(profileId, timestamp)',
        'idx_cholesterol_profile_timestamp': 'cholesterol(profileId, timestamp)',
        'idx_creatinine_profile_timestamp': 'creatinine(profileId, timestamp)',
      };
      for (final entry in indexes.entries) {
        try {
          await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS ${entry.key} ON ${entry.value}',
          );
          print('Created index ${entry.key} (v24)');
        } catch (e) {
          print('Error creating index ${entry.key} (v24): $e');
        }
      }
    }

    try {
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_sleep_record_profile_timestamp ON sleep_record(profileId, timestamp)',
      );
    } catch (e) {
      print('Error creating idx_sleep_record_profile_timestamp in onUpgrade: $e');
    }

    // ✅ Version 27: Menstrual Cycle table
    if (oldVersion < 27) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS menstrual_cycle (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          startDate TEXT NOT NULL,
          endDate TEXT,
          cycleLength INTEGER,
          periodLength INTEGER NOT NULL DEFAULT 5,
          symptoms TEXT,
          note TEXT,
          profileId INTEGER
        )
      ''');
      print('✅ Created menstrual_cycle table (v27)');
    }

    // ✅ Version 28: Remove duplicates and add unique index
    if (oldVersion < 28) {
      try {
        await db.execute('''
          DELETE FROM menstrual_cycle 
          WHERE id NOT IN (
            SELECT MAX(id) 
            FROM menstrual_cycle 
            GROUP BY profileId, startDate
          )
        ''');
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_menstrual_cycle_profile_startDate ON menstrual_cycle(profileId, startDate)',
        );
        print('✅ Removed duplicates and created idx_menstrual_cycle_profile_startDate (v28)');
      } catch (e) {
        print('Error in v28 migration: $e');
      }
    }

    // ✅ Version 29: Add `source` column to spo2heartrate
    if (oldVersion < 29) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(spo2heartrate)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('source')) {
          await db.execute(
            "ALTER TABLE spo2heartrate ADD COLUMN source TEXT NOT NULL DEFAULT 'manual'",
          );
          print('✅ Added source column to spo2heartrate table (v29)');
        }
      } catch (e) {
        print('Error in v29 migration: $e');
      }
    }

    if (oldVersion < 30) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(blood_pressure)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('source')) {
          await db.execute(
            "ALTER TABLE blood_pressure ADD COLUMN source TEXT NOT NULL DEFAULT 'manual'",
          );
          print('Added source column to blood_pressure table (v30)');
        }
      } catch (e) {
        print('Error in v30 migration: $e');
      }
    }

    if (oldVersion < 31) {
      try {
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='meal_analysis'",
        );

        if (tables.isNotEmpty) {
          final columns = await db.rawQuery('PRAGMA table_info(meal_analysis)');
          final columnNames = columns
              .map((col) => col['name'] as String)
              .toList();

          if (!columnNames.contains('meal_type')) {
            await db.execute(
              'ALTER TABLE meal_analysis ADD COLUMN meal_type TEXT',
            );
            print('Added meal_type column to meal_analysis table (v31)');
          }
        }
      } catch (e) {
        print('Error in v31 migration: $e');
      }
    }

    if (oldVersion < 32) {
      try {
        final columns = await db.rawQuery('PRAGMA table_info(step_count)');
        final columnNames = columns
            .map((col) => col['name'] as String)
            .toList();
        if (!columnNames.contains('source')) {
          await db.execute(
            "ALTER TABLE step_count ADD COLUMN source TEXT NOT NULL DEFAULT 'manual'",
          );
          print('Added source column to step_count table (v32)');
        }
      } catch (e) {
        print('Error in v32 migration: $e');
      }
    }

    print('Nâng cấp cơ sở dữ liệu đã hoàn tất');
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, currentDbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('🗑️ Database deleted');
  }

  String _dbNameForUser(String? userId) {
    if (userId == null || userId.isEmpty) return _defaultDbName;
    final safeId = _sanitizeUserId(userId);
    return 'doctor_care_$safeId.db';
  }

  String? _normalizeUserId(String? userId) {
    final trimmed = userId?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String _sanitizeUserId(String userId) {
    return userId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
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

  Future<void> dedupMenstrualCycle() async {
    final db = await database;

    try {
      await db.transaction((txn) async {
        await txn.execute('''
          DELETE FROM menstrual_cycle
          WHERE id NOT IN (
            SELECT MAX(id)
            FROM menstrual_cycle
            GROUP BY profileId, startDate
          )
        ''');

        await txn.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_menstrual_cycle_profile_startDate ON menstrual_cycle(profileId, startDate)',
        );
      });

      print('Dedup menstrual_cycle completed');
    } catch (e) {
      print('Dedup menstrual_cycle failed: $e');
    }
  }

  Future<void> recreateDatabase() async {
    print('🔄 Recreating database...');
    await deleteDatabase();
    _database = await _initDatabase();
    print('✅ Database recreated successfully');
  }

  /// Lấy version hiện tại của database
  int getDatabaseVersion() => _dbVersion;

  /// Lấy thống kê số bản ghi của tất cả các bảng
  Future<Map<String, int>> getTableStats() async {
    final db = await database;
    final stats = <String, int>{};

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
    );

    for (final table in tables) {
      final tableName = table['name'] as String;
      try {
        final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
        final count = Sqflite.firstIntValue(countResult) ?? 0;
        stats[tableName] = count;
      } catch (e) {
        stats[tableName] = -1;
      }
    }

    return stats;
  }

  /// Export toàn bộ database ra JSON string
  Future<String> exportDatabaseToJson() async {
    final db = await database;
    final export = <String, dynamic>{};

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
    );

    for (final table in tables) {
      final tableName = table['name'] as String;
      try {
        final data = await db.query(tableName);
        export[tableName] = data;
      } catch (e) {
        export[tableName] = {'error': e.toString()};
      }
    }

    return const JsonEncoder.withIndent('  ').convert(export);
  }

  /// Xóa dữ liệu cũ hơn X ngày trong các bảng có timestamp
  Future<Map<String, int>> clearOldData(int days) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final deletedCounts = <String, int>{};

    // Các bảng có cột timestamp
    final tablesWithTimestamp = [
      'blood_pressure',
      'temperature',
      'spo2heartrate',
      'bmi_weight',
      'water_intake',
      'blood_sugar',
      'sleep_record',
      'step_count',
      'cholesterol',
      'creatinine',
      'hba1c',
      'menstrual_cycle',
    ];

    for (final table in tablesWithTimestamp) {
      try {
        int deleted = 0;
        if (table == 'hba1c') {
          deleted = await db.delete(
            table,
            where: 'date < ?',
            whereArgs: [cutoff],
          );
        } else if (table == 'menstrual_cycle') {
          deleted = await db.delete(
            table,
            where: 'startDate < ?',
            whereArgs: [cutoff],
          );
        } else {
          deleted = await db.delete(
            table,
            where: 'timestamp < ?',
            whereArgs: [cutoff],
          );
        }
        deletedCounts[table] = deleted;
      } catch (e) {
        print('⚠️ Error clearing old data from $table: $e');
        deletedCounts[table] = 0;
      }
    }

    return deletedCounts;
  }




  Future<void> _ensureMealTablesExist(Database db) async {
    // Check if meal_analysis table exists
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='meal_analysis'",
    );

    if (tables.isEmpty) {

      // Create meal_analysis table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS meal_analysis (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT NOT NULL,
          image_path TEXT NOT NULL,
          user_id TEXT,
          notes TEXT,
          health_recommendations TEXT,
          dish_name TEXT,
          meal_type TEXT
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
        }
        if (!columnNames.contains('meal_type')) {
          await db.execute(
            'ALTER TABLE meal_analysis ADD COLUMN meal_type TEXT',
          );
        }
      } catch (_) {}
    }
  }
}
