import 'package:doctor_care/domain/entities/step_count.dart';
import 'package:doctor_care/domain/repositories/step_count_repository.dart';

class GetStepCount {
  final StepCountRepository repository;
  GetStepCount(this.repository);
  Future<List<StepCount>> call() async => await repository.getAllStepCounts();
}
