import 'package:doctor_care/domain/entities/cholesterol.dart';
import 'package:doctor_care/domain/repositories/cholesterol_repository.dart';

class UpdateCholesterol {
  final CholesterolRepository repository;
  UpdateCholesterol(this.repository);
  Future<void> call(Cholesterol record) async =>
      await repository.updateCholesterol(record);
}
