import 'package:doctor_care/data/datasources/hba1c_data_sources.dart';
import 'package:doctor_care/data/models/hba1c_model.dart';
import 'package:doctor_care/domain/entities/hba1c.dart';
import 'package:doctor_care/domain/repositories/hba1c_repository.dart';

class Hba1cRepositoryimpl implements Hba1cRepository{
  final Hba1cDataSources hba1cDataSources;

  Hba1cRepositoryimpl(this.hba1cDataSources);

  @override
  Future<void> addHba1cRecord(HbA1c hba1c) async {
    await hba1cDataSources.addHba1c(
      Hba1cModel(
        id: hba1c.id,
        value: hba1c.value,
        date: hba1c.date,
      )
    );
  }
  

  @override
  Future<List<HbA1c>> getHba1cRecords() async {
    final records = await hba1cDataSources.getAllHba1c();
    return records;
  }
  
  @override
  Future<void> updateHba1cRecord(HbA1c hba1c) async {
    await hba1cDataSources.updateHba1c(
      Hba1cModel(
        id: hba1c.id,
        value: hba1c.value,
        date: hba1c.date,
      )
    );
  }
  
  @override
  Future<void> deleteHba1c(String id) {
    return hba1cDataSources.deleteHba1c(int.parse(id));
  }
  
}