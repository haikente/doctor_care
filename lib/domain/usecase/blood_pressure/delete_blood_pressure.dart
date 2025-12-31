import 'package:doctor_care/domain/repositories/blood_pressure_repository.dart';

class DeleteBloodPressure {
  final BloodPressureRepository repository;

  DeleteBloodPressure(this.repository);

  Future<void> call(String id) async {
    await repository.deleteBloodPressure(id);
  }
}