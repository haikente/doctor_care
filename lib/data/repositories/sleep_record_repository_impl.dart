import 'package:doctor_care/data/datasources/sleep_record_data_source.dart';
import 'package:doctor_care/data/models/sleep_record_model.dart';
import 'package:doctor_care/domain/entities/sleep_record.dart';
import 'package:doctor_care/domain/repositories/sleep_record_repository.dart';

class SleepRecordRepositoryImpl implements SleepRecordRepository {
  final SleepRecordDataSource dataSource;

  SleepRecordRepositoryImpl(this.dataSource);

  @override
  Future<void> addSleepRecord(SleepRecord record) async {
    await dataSource.addSleepRecord(
      SleepRecordModel(
        id: record.id,
        bedTime: record.bedTime,
        wakeTime: record.wakeTime,
        quality: record.quality,
        timestamp: record.timestamp,
        note: record.note,
      ),
    );
  }

  @override
  Future<void> deleteSleepRecord(String id) async {
    await dataSource.deleteSleepRecord(int.parse(id));
  }

  @override
  Future<List<SleepRecord>> getAllSleepRecords() async {
    return await dataSource.getAllSleepRecords();
  }

  @override
  Future<void> updateSleepRecord(SleepRecord record) async {
    await dataSource.updateSleepRecord(
      SleepRecordModel(
        id: record.id,
        bedTime: record.bedTime,
        wakeTime: record.wakeTime,
        quality: record.quality,
        timestamp: record.timestamp,
        note: record.note,
      ),
    );
  }
}
