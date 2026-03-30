import 'package:doctor_care/domain/entities/water_intake.dart';

abstract class WaterIntakeRepository {
  Future<List<WaterIntake>> getWaterIntakeRecords();
  Future<void> insertWaterIntakeRecord(WaterIntake record);
  Future<void> updateWaterIntakeRecord(WaterIntake record);
  Future<void> deleteWaterIntakeRecord(String id);
}
