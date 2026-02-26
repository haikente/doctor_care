import 'package:doctor_care/domain/entities/cholesterol.dart';
import 'package:doctor_care/domain/repositories/cholesterol_repository.dart';

class InsertCholesterol {
  final CholesterolRepository repository;
  InsertCholesterol(this.repository);
  Future<void> call(Cholesterol record) async =>
      await repository.addCholesterol(record);
}
