import 'package:doctor_care/domain/entities/step_count.dart';
import 'package:doctor_care/domain/repositories/step_count_repository.dart';

class InsertStepCount {
  final StepCountRepository repository;
  InsertStepCount(this.repository);
  Future<void> call(StepCount record) async =>
      await repository.addStepCount(record);
}
