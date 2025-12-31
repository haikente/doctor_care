import 'package:doctor_care/domain/entities/blood_pressure.dart';
import 'package:doctor_care/domain/repositories/blood_pressure_repository.dart';

class UpdateBloodPressure {
  final BloodPressureRepository repository;

  UpdateBloodPressure(this.repository);

  Future<void> call(BloodPressure bp) async {
    await repository.updateBloodPressure(bp);
  }
}