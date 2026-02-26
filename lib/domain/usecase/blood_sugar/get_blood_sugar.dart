import 'package:doctor_care/domain/entities/blood_sugar.dart';
import 'package:doctor_care/domain/repositories/blood_sugar_repository.dart';

class GetBloodSugar {
  final BloodSugarRepository repository;

  GetBloodSugar(this.repository);

  Future<List<BloodSugar>> call() async {
    return await repository.getAllBloodSugars();
  }
}
