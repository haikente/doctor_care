import 'package:doctor_care/data/datasources/menstrual_cycle_data_source.dart';
import 'package:doctor_care/domain/entities/menstrual_cycle.dart';
import 'package:doctor_care/domain/repositories/menstrual_cycle_repository.dart';

class MenstrualCycleRepositoryImpl implements MenstrualCycleRepository {
  final MenstrualCycleDataSource dataSource;

  MenstrualCycleRepositoryImpl(this.dataSource);

  @override
  Future<List<MenstrualCycle>> getAll() => dataSource.getAll();

  @override
  Future<void> insert(MenstrualCycle cycle) => dataSource.insert(cycle);

  @override
  Future<void> update(MenstrualCycle cycle) => dataSource.update(cycle);

  @override
  Future<void> delete(int id) => dataSource.delete(id);
}
