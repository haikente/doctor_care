import 'package:doctor_care/data/datasources/blood_pressure_data_sources.dart';
import 'package:doctor_care/data/models/blood_pressure_model.dart';
import 'package:doctor_care/domain/entities/blood_pressure.dart';
import 'package:doctor_care/domain/repositories/blood_pressure_repository.dart';

class BloodPressureRepositoryImpl implements BloodPressureRepository {
  final BloodPressureDataSources dataSources;

  BloodPressureRepositoryImpl(this.dataSources);

  @override
  Future<void> addBloodPressure(BloodPressure bp) async {
   await dataSources.addBloodPressure(
      BloodPressureModel(
        id: bp.id,
        systolic: bp.systolic,
        diastolic: bp.diastolic,
        timestamp: bp.timestamp,
        source: bp.source,
      )
    );
  }

  @override
  Future<void> deleteBloodPressure(String id) async{
    return dataSources.deleteBloodPressure(int.parse(id));
  }

  @override
  Future<List<BloodPressure>> getAllBloodPressures() async {
    final records = await dataSources.getAllBloodPressures();
    return records;
  }

  @override
  Future<void> updateBloodPressure(BloodPressure bp) async {
    await dataSources.updateBloodPressure(
      BloodPressureModel(
        id: bp.id,
        systolic: bp.systolic,
        diastolic: bp.diastolic,
        timestamp: bp.timestamp,
        source: bp.source,
      )
    );   
  }
}
