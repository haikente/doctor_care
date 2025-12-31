import 'package:doctor_care/domain/entities/temperature.dart';
import 'package:doctor_care/domain/repositories/temperature_repository.dart';

class InsertTemperature {
   TemperatureRepository repository;

   InsertTemperature(this.repository);

   Future<void> call(Temperature temperature) async {
     await repository.addTemperature(temperature);
   }
}