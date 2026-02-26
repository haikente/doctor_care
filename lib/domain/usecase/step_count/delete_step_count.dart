import 'package:doctor_care/domain/repositories/step_count_repository.dart';

class DeleteStepCount {
  final StepCountRepository repository;
  DeleteStepCount(this.repository);
  Future<void> call(String id) async => await repository.deleteStepCount(id);
}
