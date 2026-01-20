import 'package:doctor_care/domain/entities/bmi_weight.dart';
import 'package:doctor_care/domain/repositories/bmi_weight_repository.dart';

class UpdateBmiWeight {
  final BMIWeightRepository repository;

  UpdateBmiWeight({required this.repository});

  Future<void> call(BMIWeight bmiWeight) async {
    return repository.updateBMIWeightRecord(bmiWeight);
  }
}
