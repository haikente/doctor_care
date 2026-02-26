import 'package:doctor_care/domain/repositories/blood_sugar_repository.dart';

class DeleteBloodSugar {
  final BloodSugarRepository repository;

  DeleteBloodSugar(this.repository);

  Future<void> call(String id) async {
    await repository.deleteBloodSugar(id);
  }
}
