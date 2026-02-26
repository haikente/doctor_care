import 'package:doctor_care/domain/entities/cholesterol.dart';

abstract class CholesterolRepository {
  Future<void> addCholesterol(Cholesterol record);
  Future<void> updateCholesterol(Cholesterol record);
  Future<List<Cholesterol>> getAllCholesterols();
  Future<void> deleteCholesterol(String id);
}
