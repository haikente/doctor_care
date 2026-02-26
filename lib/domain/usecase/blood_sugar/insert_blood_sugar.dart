import 'package:doctor_care/domain/entities/blood_sugar.dart';
import 'package:doctor_care/domain/repositories/blood_sugar_repository.dart';

class InsertBloodSugar {
  final BloodSugarRepository repository;

  InsertBloodSugar(this.repository);

  Future<void> call(BloodSugar record) async {
    await repository.addBloodSugar(record);
  }
}
