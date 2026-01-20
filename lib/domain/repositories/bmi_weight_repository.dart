import 'package:doctor_care/domain/entities/bmi_weight.dart';

abstract class BMIWeightRepository {
  Future<List<BMIWeight>> getBMIWeightRecords();
  Future<void> insertBMIWeightRecord(BMIWeight record);
  Future<void> updateBMIWeightRecord(BMIWeight record);
  Future<void> deleteBMIWeightRecord(String id);
}
