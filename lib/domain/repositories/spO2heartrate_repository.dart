import 'package:doctor_care/domain/entities/spO2heartrate.dart';

abstract class Spo2heartrateRepository {
  Future<List<SpO2HeartRate>> getSpO2HeartRateRecords();
  Future<void> insertSpO2HeartRateRecord(SpO2HeartRate spO2HeartRate);
  Future<void> updateSpO2HeartRateRecord(SpO2HeartRate spO2HeartRate);
  Future<void> deleteSpO2HeartRateRecord(String id);
}