import 'package:dio/dio.dart';
import 'package:doctor_care/data/datasources/blood_pressure_data_sources.dart';
import 'package:doctor_care/data/datasources/hba1c_data_sources.dart';
import 'package:doctor_care/data/datasources/temperature_data_sources.dart';
import 'package:doctor_care/data/repositories/blood_pressure_repositoryimpl.dart';
import 'package:doctor_care/data/repositories/hba1c_repositoryimpl.dart';
import 'package:doctor_care/data/repositories/temperature_repositoryimpl.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/delete_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/get_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/insert_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/update_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/hba1c/delete_hba1c.dart';
import 'package:doctor_care/domain/usecase/hba1c/get_hba1c.dart';
import 'package:doctor_care/domain/usecase/hba1c/insert_hba1c.dart';
import 'package:doctor_care/domain/usecase/hba1c/update_hba1c.dart';
import 'package:doctor_care/domain/usecase/temperature/delete_temperature.dart';
import 'package:doctor_care/domain/usecase/temperature/get_temperature.dart';
import 'package:doctor_care/domain/usecase/temperature/insert_temperature.dart';
import 'package:doctor_care/domain/usecase/temperature/update_temperature.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  final dio = Dio();

  Hba1cRepositoryimpl? _hba1cRepository;
  BloodPressureRepositoryImpl? _bloodPressureRepository;
  TemperatureRepositoryImpl? _temperatureRepository;

  //usecase
  GetHba1c? _getHba1c;
  InsertHba1c? _insertHba1c;
  UpdateHba1c? _updateHba1c;
  DeleteHba1c? _deleteHba1c;

  GetBloodPressure? _getBloodPressure;
  InsertBloodPressure? _insertBloodPressure;
  UpdateBloodPressure? _updateBloodPressure;
  DeleteBloodPressure? _deleteBloodPressure;

  GetTemperature? _getTemperature;
  InsertTemperature? _insertTemperature;
  UpdateTemperature? _updateTemperature;
  DeleteTemperature? _deleteTemperature;

  // Repository Getters
  Hba1cRepositoryimpl get hba1cRepository => _hba1cRepository!;
  BloodPressureRepositoryImpl get bloodPressureRepository => _bloodPressureRepository!;
  TemperatureRepositoryImpl get temperatureRepository => _temperatureRepository!;

  //Usecase Getters
  GetHba1c get getHba1c => _getHba1c!;
  InsertHba1c get insertHba1c => _insertHba1c!;
  UpdateHba1c get updateHba1c => _updateHba1c!;
  DeleteHba1c get deleteHba1c => _deleteHba1c!;

  GetBloodPressure get getBloodPressure => _getBloodPressure!;
  InsertBloodPressure get insertBloodPressure => _insertBloodPressure!;
  UpdateBloodPressure get updateBloodPressure => _updateBloodPressure!;
  DeleteBloodPressure get deleteBloodPressure => _deleteBloodPressure!;

  GetTemperature get getTemperature => _getTemperature!;
  InsertTemperature get insertTemperature => _insertTemperature!;
  UpdateTemperature get updateTemperature => _updateTemperature!;
  DeleteTemperature get deleteTemperature => _deleteTemperature!;

  Future<void> init() async {

    //theo dõi HbA1c
    final hba1DataSources = Hba1cDataSourcesImpl(); 
    _hba1cRepository = Hba1cRepositoryimpl(hba1DataSources);
    _getHba1c = GetHba1c(_hba1cRepository!);
    _insertHba1c = InsertHba1c(_hba1cRepository!);
    _updateHba1c = UpdateHba1c(_hba1cRepository!);
    _deleteHba1c = DeleteHba1c(_hba1cRepository!);

    // theo dõi huyết áp
     final bloodPressureDataSources = BloodPressureDataSourcesImpl();
    _bloodPressureRepository = BloodPressureRepositoryImpl(bloodPressureDataSources);
    _getBloodPressure = GetBloodPressure(_bloodPressureRepository!);
    _insertBloodPressure = InsertBloodPressure(_bloodPressureRepository!);
    _updateBloodPressure = UpdateBloodPressure(_bloodPressureRepository!);
    _deleteBloodPressure = DeleteBloodPressure(_bloodPressureRepository!);

    final temperatureDataSources = TemperatureDataSourceImpl();
    _temperatureRepository = TemperatureRepositoryImpl(temperatureDataSources);
    _getTemperature = GetTemperature(_temperatureRepository!);
    _insertTemperature = InsertTemperature(_temperatureRepository!);
    _updateTemperature = UpdateTemperature(_temperatureRepository!);
    _deleteTemperature = DeleteTemperature(_temperatureRepository!);
  }

   void dispose() {
    dio.close();
  }
}