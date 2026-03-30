import 'package:doctor_care/domain/entities/water_intake.dart';
import 'package:doctor_care/domain/repositories/water_intake_repository.dart';

class GetWaterIntake {
  final WaterIntakeRepository repository;

  GetWaterIntake(this.repository);

  Future<List<WaterIntake>> call() async {
    return await repository.getWaterIntakeRecords();
  }
}
