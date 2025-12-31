import 'package:doctor_care/domain/entities/spO2heartrate.dart';
import 'package:doctor_care/domain/repositories/spO2heartrate_repository.dart';

class UpdateSpo2heartrate {

  final Spo2heartrateRepository repository;
  UpdateSpo2heartrate(this.repository);
  Future<void> call(SpO2HeartRate spO2HeartRate) async {
    await repository.updateSpO2HeartRateRecord(spO2HeartRate);
  }
  
}