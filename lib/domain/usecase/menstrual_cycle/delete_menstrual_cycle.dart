import 'package:doctor_care/domain/repositories/menstrual_cycle_repository.dart';

class DeleteMenstrualCycle {
  final MenstrualCycleRepository repository;
  DeleteMenstrualCycle(this.repository);

  Future<void> call(int id) => repository.delete(id);
}
