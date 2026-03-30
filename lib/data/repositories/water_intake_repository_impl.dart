import 'package:doctor_care/data/datasources/water_intake_data_source.dart';
import 'package:doctor_care/data/models/water_intake_model.dart';
import 'package:doctor_care/domain/entities/water_intake.dart';
import 'package:doctor_care/domain/repositories/water_intake_repository.dart';

class WaterIntakeRepositoryImpl implements WaterIntakeRepository {
  final WaterIntakeDataSource dataSource;

  WaterIntakeRepositoryImpl({required this.dataSource});

  @override
  Future<List<WaterIntake>> getWaterIntakeRecords() async {
    return await dataSource.getAllWaterIntakeRecords();
  }

  @override
  Future<void> insertWaterIntakeRecord(WaterIntake record) async {
    final model = WaterIntakeModel(
      id: record.id,
      amount: record.amount,
      note: record.note,
      timestamp: record.timestamp,
      profileId: record.profileId,
    );
    await dataSource.insertWaterIntakeRecord(model);
  }

  @override
  Future<void> updateWaterIntakeRecord(WaterIntake record) async {
    final model = WaterIntakeModel(
      id: record.id,
      amount: record.amount,
      note: record.note,
      timestamp: record.timestamp,
      profileId: record.profileId,
    );
    await dataSource.updateWaterIntakeRecord(model);
  }

  @override
  Future<void> deleteWaterIntakeRecord(String id) async {
    await dataSource.deleteWaterIntakeRecord(id);
  }
}
