import 'package:doctor_care/domain/entities/menstrual_cycle.dart';
import 'package:doctor_care/domain/repositories/menstrual_cycle_repository.dart';

class GetMenstrualCycles {
  final MenstrualCycleRepository repository;
  GetMenstrualCycles(this.repository);

  Future<List<MenstrualCycle>> call() => repository.getAll();
}
