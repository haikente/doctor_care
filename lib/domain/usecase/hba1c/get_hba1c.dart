import 'package:doctor_care/domain/entities/hba1c.dart';
import 'package:doctor_care/domain/repositories/hba1c_repository.dart';

class GetHba1c {
  final Hba1cRepository repository;
  
  GetHba1c(this.repository);

  Future<List<HbA1c>> call() async {
    return await repository.getHba1cRecords();
  }
}