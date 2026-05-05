part of 'spo2heartrate_bloc.dart';

abstract class Spo2heartrateEvent extends Equatable {
  const Spo2heartrateEvent();

  @override
  List<Object> get props => [];
}

class LoadSpo2HeartRateRecords extends Spo2heartrateEvent {}

class AddSpo2HeartRateRecord extends Spo2heartrateEvent {
  final SpO2HeartRate record;

  const AddSpo2HeartRateRecord(this.record);

  @override
  List<Object> get props => [record];
}

class UpdateSpo2HeartRateRecord extends Spo2heartrateEvent {
  final SpO2HeartRate record;

  const UpdateSpo2HeartRateRecord(this.record);

  @override
  List<Object> get props => [record];
}

class DeleteSpo2HeartRateRecord extends Spo2heartrateEvent {
  final String id;

  const DeleteSpo2HeartRateRecord(this.id);

  @override
  List<Object> get props => [id];
}

/// Event đồng bộ dữ liệu từ Health Connect
class SyncFromHealthConnect extends Spo2heartrateEvent {
  final int daysBack;

  const SyncFromHealthConnect({this.daysBack = 7});

  @override
  List<Object> get props => [daysBack];
}
