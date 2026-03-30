import 'package:doctor_care/domain/entities/creatinine.dart';
import 'package:doctor_care/domain/repositories/creatinine_repository.dart';

class UpdateCreatinine {
  final CreatinineRepository repository;

  UpdateCreatinine(this.repository);

  Future<void> call(Creatinine record) async {
    await repository.updateCreatinine(record);
  }
}
