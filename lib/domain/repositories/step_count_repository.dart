import 'package:doctor_care/domain/entities/step_count.dart';

abstract class StepCountRepository {
  Future<void> addStepCount(StepCount record);
  Future<void> updateStepCount(StepCount record);
  Future<List<StepCount>> getAllStepCounts();
  Future<void> deleteStepCount(String id);
}
