import 'package:doctor_care/data/datasources/blood_sugar_data_source.dart';
import 'package:doctor_care/data/models/blood_sugar_model.dart';
import 'package:doctor_care/domain/entities/blood_sugar.dart';
import 'package:doctor_care/domain/repositories/blood_sugar_repository.dart';

class BloodSugarRepositoryImpl implements BloodSugarRepository {
  final BloodSugarDataSource dataSource;

  BloodSugarRepositoryImpl(this.dataSource);

  @override
  Future<void> addBloodSugar(BloodSugar record) async {
    await dataSource.addBloodSugar(
      BloodSugarModel(
        id: record.id,
        value: record.value,
        mealStatus: record.mealStatus,
        timestamp: record.timestamp,
        note: record.note,
      ),
    );
  }

  @override
  Future<void> deleteBloodSugar(String id) async {
    await dataSource.deleteBloodSugar(int.parse(id));
  }

  @override
  Future<List<BloodSugar>> getAllBloodSugars() async {
    return await dataSource.getAllBloodSugars();
  }

  @override
  Future<void> updateBloodSugar(BloodSugar record) async {
    await dataSource.updateBloodSugar(
      BloodSugarModel(
        id: record.id,
        value: record.value,
        mealStatus: record.mealStatus,
        timestamp: record.timestamp,
        note: record.note,
      ),
    );
  }
}
