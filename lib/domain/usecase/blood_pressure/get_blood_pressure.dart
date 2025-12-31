import 'package:doctor_care/domain/entities/blood_pressure.dart' show BloodPressure;
import 'package:doctor_care/domain/repositories/blood_pressure_repository.dart';

class GetBloodPressure {
  final BloodPressureRepository repository;

  GetBloodPressure(this.repository);

  Future<List<BloodPressure>> call() async {
    return await repository.getAllBloodPressures();
  }
}