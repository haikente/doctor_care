import 'package:doctor_care/domain/entities/step_count.dart';
import 'package:doctor_care/domain/repositories/step_count_repository.dart';

class UpdateStepCount {
  final StepCountRepository repository;
  UpdateStepCount(this.repository);
  Future<void> call(StepCount record) async =>
      await repository.updateStepCount(record);
}
