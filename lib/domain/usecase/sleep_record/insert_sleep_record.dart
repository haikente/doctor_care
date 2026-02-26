import 'package:doctor_care/domain/entities/sleep_record.dart';
import 'package:doctor_care/domain/repositories/sleep_record_repository.dart';

class InsertSleepRecord {
  final SleepRecordRepository repository;
  InsertSleepRecord(this.repository);

  Future<void> call(SleepRecord record) async {
    await repository.addSleepRecord(record);
  }
}
