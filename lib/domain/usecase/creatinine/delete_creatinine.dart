import 'package:doctor_care/domain/repositories/creatinine_repository.dart';

class DeleteCreatinine {
  final CreatinineRepository repository;

  DeleteCreatinine(this.repository);

  Future<void> call(String id) async {
    await repository.deleteCreatinine(id);
  }
}
