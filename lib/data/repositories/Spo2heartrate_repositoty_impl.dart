import 'package:doctor_care/data/datasources/spO2heartrate_data_source.dart';
import 'package:doctor_care/data/models/spO2heartratemodel.dart';
import 'package:doctor_care/domain/entities/spO2heartrate.dart';
import 'package:doctor_care/domain/repositories/spO2heartrate_repository.dart';

class Spo2heartrateRepositotyImpl implements Spo2heartrateRepository{
  final Spo2heartrateDataSource spO2heartrateDataSource;

  Spo2heartrateRepositotyImpl(this.spO2heartrateDataSource);
  @override
  Future<void> deleteSpO2HeartRateRecord(String id) {
    return spO2heartrateDataSource.deleteSpo2heartrate(id);
  }

  @override
  Future<List<SpO2HeartRate>> getSpO2HeartRateRecords()async {
   final records = await spO2heartrateDataSource.getAllSpo2heartrate();
   return records;
  }

  @override
  Future<void> insertSpO2HeartRateRecord(SpO2HeartRate spO2HeartRate) async {
    await spO2heartrateDataSource.addSpo2heartrate(
      Spo2heartratemodel(
        id: spO2HeartRate.id,
        spo2: spO2HeartRate.spo2,
        heartRate: spO2HeartRate.heartRate,
        timestamp: spO2HeartRate.timestamp,
        note: spO2HeartRate.note,
        source: spO2HeartRate.source,
      )
    );
  }

  @override
  Future<void> updateSpO2HeartRateRecord(SpO2HeartRate spO2HeartRate) async {
    await spO2heartrateDataSource.updateSpo2heartrate(
      Spo2heartratemodel(
        id: spO2HeartRate.id,
        spo2: spO2HeartRate.spo2,
        heartRate: spO2HeartRate.heartRate,
        timestamp: spO2HeartRate.timestamp,
        note: spO2HeartRate.note,
        source: spO2HeartRate.source,
      )
    );
  }
}