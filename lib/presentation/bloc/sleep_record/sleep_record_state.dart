part of 'sleep_record_cubit.dart';

abstract class SleepRecordState extends Equatable {
  const SleepRecordState();

  @override
  List<Object> get props => [];
}

class SleepRecordInitial extends SleepRecordState {}

class SleepRecordLoading extends SleepRecordState {}

class SleepRecordLoaded extends SleepRecordState {
  final List<SleepRecord> records;

  const SleepRecordLoaded(this.records);

  @override
  List<Object> get props => [records];
}

class SleepRecordError extends SleepRecordState {
  final String message;

  const SleepRecordError(this.message);

  @override
  List<Object> get props => [message];
}
