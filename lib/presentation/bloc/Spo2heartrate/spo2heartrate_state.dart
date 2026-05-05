part of 'spo2heartrate_bloc.dart';

abstract class Spo2heartrateState extends Equatable {
  const Spo2heartrateState();

  @override
  List<Object> get props => [];
}

class Spo2heartrateInitial extends Spo2heartrateState {}

class Spo2heartrateLoading extends Spo2heartrateState {}

/// Đang đồng bộ với Health Connect
class Spo2heartrateSyncing extends Spo2heartrateState {}

class Spo2heartrateLoaded extends Spo2heartrateState {
  final List<SpO2HeartRate> records;

  const Spo2heartrateLoaded(this.records);

  @override
  List<Object> get props => [records];
}

/// Kết quả đồng bộ
class Spo2heartrateSyncResult extends Spo2heartrateState {
  final int syncedCount;
  final String message;

  const Spo2heartrateSyncResult({
    required this.syncedCount,
    required this.message,
  });

  @override
  List<Object> get props => [syncedCount, message];
}

class Spo2heartrateError extends Spo2heartrateState {
  final String message;

  const Spo2heartrateError(this.message);

  @override
  List<Object> get props => [message];
}
