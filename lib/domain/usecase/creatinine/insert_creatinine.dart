import 'package:doctor_care/domain/entities/creatinine.dart';
import 'package:doctor_care/domain/repositories/creatinine_repository.dart';

// lớp thêm dữ liệu creatininn
class InsertCreatinine {
  final CreatinineRepository repository;

  InsertCreatinine(this.repository);

  Future<void> call(Creatinine record) async {
    await repository.addCreatinine(record);
  }
}
