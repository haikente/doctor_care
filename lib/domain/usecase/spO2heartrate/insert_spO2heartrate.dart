import 'package:doctor_care/domain/entities/spO2heartrate.dart';
import 'package:doctor_care/domain/repositories/spO2heartrate_repository.dart';

class InsertSpo2heartrate {
  final Spo2heartrateRepository repository;

  InsertSpo2heartrate(this.repository);

  Future<void> call(SpO2HeartRate spO2HeartRate) {
    return repository.insertSpO2HeartRateRecord(spO2HeartRate);
  }
}