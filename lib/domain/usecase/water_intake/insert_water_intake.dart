import 'package:doctor_care/domain/entities/water_intake.dart';
import 'package:doctor_care/domain/repositories/water_intake_repository.dart';

class InsertWaterIntake {
  final WaterIntakeRepository repository;

  InsertWaterIntake(this.repository);

  Future<void> call(WaterIntake record) async {
    await repository.insertWaterIntakeRecord(record);
  }
}
