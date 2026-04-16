import 'package:doctor_care/domain/entities/menstrual_cycle.dart';

abstract class MenstrualCycleRepository {
  Future<List<MenstrualCycle>> getAll();
  Future<void> insert(MenstrualCycle cycle);
  Future<void> update(MenstrualCycle cycle);
  Future<void> delete(int id);
}
