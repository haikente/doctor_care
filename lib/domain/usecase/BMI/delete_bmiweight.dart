import 'package:doctor_care/domain/repositories/bmi_weight_repository.dart';

class DeleteBmiweight {
  final BMIWeightRepository repository;

  DeleteBmiweight({required this.repository});

  Future<void> call(String id) async {
    return repository.deleteBMIWeightRecord(id);
  }
}
