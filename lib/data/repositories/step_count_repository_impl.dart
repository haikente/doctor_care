import 'package:doctor_care/data/datasources/step_count_data_source.dart';
import 'package:doctor_care/data/models/step_count_model.dart';
import 'package:doctor_care/domain/entities/step_count.dart';
import 'package:doctor_care/domain/repositories/step_count_repository.dart';

class StepCountRepositoryImpl implements StepCountRepository {
  final StepCountDataSource dataSource;
  StepCountRepositoryImpl(this.dataSource);

  @override
  Future<void> addStepCount(StepCount record) async {
    await dataSource.addStepCount(
      StepCountModel(
        id: record.id,
        steps: record.steps,
        distance: record.distance,
        caloriesBurned: record.caloriesBurned,
        timestamp: record.timestamp,
        note: record.note,
      ),
    );
  }

  @override
  Future<void> deleteStepCount(String id) async =>
      await dataSource.deleteStepCount(int.parse(id));

  @override
  Future<List<StepCount>> getAllStepCounts() async =>
      await dataSource.getAllStepCounts();

  @override
  Future<void> updateStepCount(StepCount record) async {
    await dataSource.updateStepCount(
      StepCountModel(
        id: record.id,
        steps: record.steps,
        distance: record.distance,
        caloriesBurned: record.caloriesBurned,
        timestamp: record.timestamp,
        note: record.note,
      ),
    );
  }
}
