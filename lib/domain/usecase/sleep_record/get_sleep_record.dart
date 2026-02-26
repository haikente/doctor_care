import 'package:doctor_care/domain/entities/sleep_record.dart';
import 'package:doctor_care/domain/repositories/sleep_record_repository.dart';

class GetSleepRecord {
  final SleepRecordRepository repository;
  GetSleepRecord(this.repository);

  Future<List<SleepRecord>> call() async {
    return await repository.getAllSleepRecords();
  }
}
