import 'package:doctor_care/data/datasources/cholesterol_data_source.dart';
import 'package:doctor_care/data/models/cholesterol_model.dart';
import 'package:doctor_care/domain/entities/cholesterol.dart';
import 'package:doctor_care/domain/repositories/cholesterol_repository.dart';

class CholesterolRepositoryImpl implements CholesterolRepository {
  final CholesterolDataSource dataSource;
  CholesterolRepositoryImpl(this.dataSource);

  @override
  Future<void> addCholesterol(Cholesterol record) async {
    await dataSource.addCholesterol(
      CholesterolModel(
        id: record.id,
        totalCholesterol: record.totalCholesterol,
        hdl: record.hdl,
        ldl: record.ldl,
        triglycerides: record.triglycerides,
        timestamp: record.timestamp,
        note: record.note,
      ),
    );
  }

  @override
  Future<void> deleteCholesterol(String id) async =>
      await dataSource.deleteCholesterol(int.parse(id));

  @override
  Future<List<Cholesterol>> getAllCholesterols() async =>
      await dataSource.getAllCholesterols();

  @override
  Future<void> updateCholesterol(Cholesterol record) async {
    await dataSource.updateCholesterol(
      CholesterolModel(
        id: record.id,
        totalCholesterol: record.totalCholesterol,
        hdl: record.hdl,
        ldl: record.ldl,
        triglycerides: record.triglycerides,
        timestamp: record.timestamp,
        note: record.note,
      ),
    );
  }
}
