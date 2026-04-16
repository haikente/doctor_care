import 'package:doctor_care/domain/entities/menstrual_cycle.dart';
import 'package:doctor_care/domain/repositories/menstrual_cycle_repository.dart';

class UpdateMenstrualCycle {
  final MenstrualCycleRepository repository;
  UpdateMenstrualCycle(this.repository);

  Future<void> call(MenstrualCycle cycle) => repository.update(cycle);
}
