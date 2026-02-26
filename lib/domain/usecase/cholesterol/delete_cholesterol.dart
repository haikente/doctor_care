import 'package:doctor_care/domain/repositories/cholesterol_repository.dart';

class DeleteCholesterol {
  final CholesterolRepository repository;
  DeleteCholesterol(this.repository);
  Future<void> call(String id) async => await repository.deleteCholesterol(id);
}
