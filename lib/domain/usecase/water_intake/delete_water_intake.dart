import 'package:doctor_care/domain/repositories/water_intake_repository.dart';

class DeleteWaterIntake {
  final WaterIntakeRepository repository;

  DeleteWaterIntake(this.repository);

  Future<void> call(String id) async {
    await repository.deleteWaterIntakeRecord(id);
  }
}
