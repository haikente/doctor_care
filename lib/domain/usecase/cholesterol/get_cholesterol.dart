import 'package:doctor_care/domain/entities/cholesterol.dart';
import 'package:doctor_care/domain/repositories/cholesterol_repository.dart';

class GetCholesterol {
  final CholesterolRepository repository;
  GetCholesterol(this.repository);
  Future<List<Cholesterol>> call() async =>
      await repository.getAllCholesterols();
}
