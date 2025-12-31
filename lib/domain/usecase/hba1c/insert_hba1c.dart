import 'package:doctor_care/domain/entities/hba1c.dart';
import 'package:doctor_care/domain/repositories/hba1c_repository.dart';

class InsertHba1c {
  final Hba1cRepository repository;
  
  InsertHba1c(this.repository);

  Future<void> call(HbA1c hba1c) async {
    await repository.addHba1cRecord(hba1c);
  }
}