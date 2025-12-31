import 'package:doctor_care/domain/entities/hba1c.dart';
import 'package:doctor_care/domain/repositories/hba1c_repository.dart';

class UpdateHba1c {
  Hba1cRepository repository;

  UpdateHba1c(this.repository);

  Future<void> call(HbA1c hba1c) async {
    await repository.updateHba1cRecord(hba1c);
  }
}