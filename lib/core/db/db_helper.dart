import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  DbHelper._internal();

  static const _dbName = 'doctor_care.db';
  static const _dbVersion = 4;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // ✅ HbA1c table
    await db.execute('''
      CREATE TABLE hba1c (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // ✅ Blood Pressure table
    await db.execute('''
      CREATE TABLE blood_pressure (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL
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
      print('✅ Created bmi_weight table (v4)');
    }
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
    final result = await db.rawQuery(
      "SELECT sql FROM sqlite_master WHERE type='table' AND name='temperature'",
    );
    print('📊 Temperature table schema: ${result.first['sql']}');
  }
}
