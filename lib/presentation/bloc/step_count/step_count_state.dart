part of 'step_count_cubit.dart';

abstract class StepCountState extends Equatable {
  const StepCountState();
  @override
  List<Object> get props => [];
}

class StepCountInitial extends StepCountState {}

class StepCountLoading extends StepCountState {}

class StepCountLoaded extends StepCountState {
  final List<StepCount> records;
  const StepCountLoaded(this.records);
  @override
  List<Object> get props => [records];
}

class StepCountError extends StepCountState {
  final String message;
  const StepCountError(this.message);
  @override
  List<Object> get props => [message];
}
