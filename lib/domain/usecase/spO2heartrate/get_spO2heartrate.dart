import 'package:doctor_care/domain/entities/spO2heartrate.dart';
import 'package:doctor_care/domain/repositories/spO2heartrate_repository.dart';

class GetSpo2heartrate {
  final Spo2heartrateRepository repository;

  GetSpo2heartrate(this.repository);

  Future<List<SpO2HeartRate>> call() {
    return repository.getSpO2HeartRateRecords();
  }
}