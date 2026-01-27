part of 'water_intake_bloc.dart';

abstract class WaterIntakeState extends Equatable {
  const WaterIntakeState();

  @override
  List<Object> get props => [];
}

class WaterIntakeInitial extends WaterIntakeState {}

class WaterIntakeLoading extends WaterIntakeState {}

class WaterIntakeLoaded extends WaterIntakeState {
  final List<WaterIntake> records;

  const WaterIntakeLoaded(this.records);

  @override
  List<Object> get props => [records];
}

class WaterIntakeError extends WaterIntakeState {
  final String message;

  const WaterIntakeError(this.message);

  @override
  List<Object> get props => [message];
}
