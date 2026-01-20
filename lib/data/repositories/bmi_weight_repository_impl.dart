import 'package:doctor_care/data/datasources/bmi_weight_data_source.dart';
import 'package:doctor_care/data/models/bmi_weight_model.dart';
import 'package:doctor_care/domain/entities/bmi_weight.dart';
import 'package:doctor_care/domain/repositories/bmi_weight_repository.dart';

class BMIWeightRepositoryImpl implements BMIWeightRepository {
  final BMIWeightDataSource dataSource;

  BMIWeightRepositoryImpl(this.dataSource);

  @override
  Future<List<BMIWeight>> getBMIWeightRecords() async {
    return await dataSource.getAllBMIWeightRecords();
  }

  @override
  Future<void> insertBMIWeightRecord(BMIWeight record) async {
    await dataSource.addBMIWeightRecord(
      BMIWeightModel(
        id: record.id,
        weight: record.weight,
        height: record.height,
        timestamp: record.timestamp,
        note: record.note,
      ),
    );
  }

  @override
  Future<void> updateBMIWeightRecord(BMIWeight record) async {
    await dataSource.updateBMIWeightRecord(
      BMIWeightModel(
        id: record.id,
        weight: record.weight,
        height: record.height,
        timestamp: record.timestamp,
        note: record.note,
      ),
    );
  }

  @override
  Future<void> deleteBMIWeightRecord(String id) async {
    await dataSource.deleteBMIWeightRecord(id);
  }
}
