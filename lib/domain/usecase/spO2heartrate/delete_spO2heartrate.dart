import 'package:doctor_care/domain/repositories/spO2heartrate_repository.dart';

class DeleteSpo2heartrate {
  final Spo2heartrateRepository repository;
  DeleteSpo2heartrate(this.repository);

  Future<void> call(String id) async {
    await repository.deleteSpO2HeartRateRecord(id);

  }
}