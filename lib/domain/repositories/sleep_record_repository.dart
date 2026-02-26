import 'package:doctor_care/domain/entities/sleep_record.dart';

abstract class SleepRecordRepository {
  Future<void> addSleepRecord(SleepRecord record);
  Future<void> updateSleepRecord(SleepRecord record);
  Future<List<SleepRecord>> getAllSleepRecords();
  Future<void> deleteSleepRecord(String id);
}
