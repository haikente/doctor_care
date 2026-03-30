import 'package:doctor_care/domain/entities/creatinine.dart';
import 'package:doctor_care/domain/repositories/creatinine_repository.dart';

class GetCreatinine {
  final CreatinineRepository repository;

  GetCreatinine(this.repository);

  Future<List<Creatinine>> call() async {
    return await repository.getAllCreatinines();
  }
}
