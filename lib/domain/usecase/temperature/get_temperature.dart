import 'package:doctor_care/domain/entities/temperature.dart';
import 'package:doctor_care/domain/repositories/temperature_repository.dart';

class GetTemperature {
  TemperatureRepository repository;

  GetTemperature(this.repository);

  Future<List<Temperature>> call() async {
    return await repository.getAllTemperatures();
  }
}