import 'package:doctor_care/domain/entities/blood_sugar.dart';

abstract class BloodSugarRepository {
  Future<void> addBloodSugar(BloodSugar record);
  Future<void> updateBloodSugar(BloodSugar record);
  Future<List<BloodSugar>> getAllBloodSugars();
  Future<void> deleteBloodSugar(String id);
}
