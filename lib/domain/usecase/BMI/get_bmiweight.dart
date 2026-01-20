import 'package:doctor_care/domain/entities/bmi_weight.dart';
import 'package:doctor_care/domain/repositories/bmi_weight_repository.dart';

class GetBMIWeight {
  final BMIWeightRepository repository;

  GetBMIWeight({required this.repository});

  Future<List<BMIWeight>> call() async {
    return repository.getBMIWeightRecords();
  }
}
