import 'package:doctor_care/domain/entities/temperature.dart';

abstract class TemperatureRepository {
  Future<void> addTemperature(Temperature temp);
  Future<void> updateTemperature(Temperature temp);
  Future<List<Temperature>> getAllTemperatures();
  Future<void> deleteTemperature(String id);
}