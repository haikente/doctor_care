import 'package:doctor_care/domain/repositories/sleep_record_repository.dart';

class DeleteSleepRecord {
  final SleepRecordRepository repository;
  DeleteSleepRecord(this.repository);

  Future<void> call(String id) async {
    await repository.deleteSleepRecord(id);
  }
}
