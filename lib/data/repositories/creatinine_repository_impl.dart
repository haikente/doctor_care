import 'package:doctor_care/data/datasources/creatinine_data_source.dart';
import 'package:doctor_care/data/models/creatinine_model.dart';
import 'package:doctor_care/domain/entities/creatinine.dart';
import 'package:doctor_care/domain/repositories/creatinine_repository.dart';

// lớp triển khai các phương thức của CreatinineRepository
class CreatinineRepositoryImpl implements CreatinineRepository {
  final CreatinineDataSource dataSource;

  CreatinineRepositoryImpl(this.dataSource);

  @override
  Future<void> addCreatinine(Creatinine record) async {
    await dataSource.addCreatinine(
      CreatinineModel(
        id: record.id,
        value: record.value,
        timestamp: record.timestamp,
        note: record.note,
        age: record.age,
        gender: record.gender,
      ),
    );
  }

  @override
  Future<void> deleteCreatinine(String id) async {
    await dataSource.deleteCreatinine(int.parse(id));
  }

  @override
  Future<List<Creatinine>> getAllCreatinines() async {
    return await dataSource.getAllCreatinines();
  }

  @override
  Future<void> updateCreatinine(Creatinine record) async {
    await dataSource.updateCreatinine(
      CreatinineModel(
        id: record.id,
        value: record.value,
        timestamp: record.timestamp,
        note: record.note,
        age: record.age,
        gender: record.gender,
      ),
    );
  }
}
