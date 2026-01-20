import 'package:doctor_care/domain/entities/bmi_weight.dart';
import 'package:doctor_care/domain/repositories/bmi_weight_repository.dart';

class InsertBmiweight {
  final BMIWeightRepository repository;

  InsertBmiweight({required this.repository});

  Future<void> call(BMIWeight bmiWeight) async {
    return repository.insertBMIWeightRecord(bmiWeight);
  }
}
