import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/sleep_record_model.dart';

abstract class SleepRecordDataSource {
  Future<void> addSleepRecord(SleepRecordModel record);
  Future<void> updateSleepRecord(SleepRecordModel record);
  Future<List<SleepRecordModel>> getAllSleepRecords();
  Future<void> deleteSleepRecord(int id);
}

class SleepRecordDataSourceImpl implements SleepRecordDataSource {
  final dbHelper = DbHelper.instance;

  @override
  Future<void> addSleepRecord(SleepRecordModel record) async {
    final db = await dbHelper.database;
    await db.insert('sleep_record', record.toMap());
  }

  @override
  Future<void> deleteSleepRecord(int id) async {
    final db = await dbHelper.database;
    await db.delete('sleep_record', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<SleepRecordModel>> getAllSleepRecords() async {
    final db = await dbHelper.database;
    final result = await db.query('sleep_record');
    return result.map((e) => SleepRecordModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateSleepRecord(SleepRecordModel record) async {
    final db = await dbHelper.database;
    await db.update(
      'sleep_record',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }
}
