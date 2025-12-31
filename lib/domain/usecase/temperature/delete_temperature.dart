import 'package:doctor_care/domain/repositories/temperature_repository.dart';

class DeleteTemperature {
  TemperatureRepository repository;

  DeleteTemperature(this.repository);

  Future<void> call(String id) async {
    await repository.deleteTemperature(id);
  }
}