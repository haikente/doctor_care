import 'package:doctor_care/domain/entities/blood_sugar.dart';
import 'package:doctor_care/domain/repositories/blood_sugar_repository.dart';

class UpdateBloodSugar {
  final BloodSugarRepository repository;

  UpdateBloodSugar(this.repository);

  Future<void> call(BloodSugar record) async {
    await repository.updateBloodSugar(record);
  }
}
