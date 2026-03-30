import 'package:doctor_care/domain/entities/creatinine.dart';

// lớp trừu tượng để định nghĩa các phương thức cần thiết cho việc quản lý dữ liệu creatinine
abstract class CreatinineRepository {
  Future<void> addCreatinine(Creatinine record);
  Future<void> updateCreatinine(Creatinine record);
  Future<List<Creatinine>> getAllCreatinines();
  Future<void> deleteCreatinine(String id);
}
