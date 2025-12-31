import 'package:doctor_care/data/datasources/temperature_data_sources.dart';
import 'package:doctor_care/data/models/temperature_model.dart';
import 'package:doctor_care/domain/entities/temperature.dart';
import 'package:doctor_care/domain/repositories/temperature_repository.dart';

class TemperatureRepositoryImpl implements TemperatureRepository{
  TemperatureDataSource temperatureDataSource;

  TemperatureRepositoryImpl(this.temperatureDataSource);

  @override
  Future<void> addTemperature(Temperature temp) async{
    await temperatureDataSource.insertTemperature(
      TemperatureModel(
        id: temp.id,
        value: temp.value,
        timestamp: temp.timestamp,
      )
    );
  }

  @override
  Future<void> deleteTemperature(String id) async{
    await temperatureDataSource.deleteTemperature(id);
  }

  @override
  Future<List<Temperature>> getAllTemperatures() async{
   return await temperatureDataSource.getAllTemperatures();
  }

  @override
  Future<void> updateTemperature(Temperature temp) async{
   await temperatureDataSource.updateTemperature(
      TemperatureModel(
        id: temp.id,
        value: temp.value,
        timestamp: temp.timestamp,
      )
    );
  }
}