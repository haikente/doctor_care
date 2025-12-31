import 'package:doctor_care/domain/entities/blood_pressure.dart';

abstract class BloodPressureRepository {
  Future<void> addBloodPressure(BloodPressure bp);
  Future<void> updateBloodPressure(BloodPressure bp);
  Future<List<BloodPressure>> getAllBloodPressures();
  Future<void> deleteBloodPressure(String id);
}