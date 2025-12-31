import 'package:doctor_care/domain/entities/hba1c.dart';

abstract class Hba1cRepository {
  Future<void> addHba1cRecord(HbA1c hba1c);
  Future<void> updateHba1cRecord(HbA1c hba1c);
  Future<List<HbA1c>> getHba1cRecords();
  Future<void> deleteHba1c(String id);
}
