part of 'bmi_weight_bloc.dart';

abstract class BMIWeightState extends Equatable {
  const BMIWeightState();

  @override
  List<Object> get props => [];
}

class BMIWeightInitial extends BMIWeightState {}

class BMIWeightLoading extends BMIWeightState {}

class BMIWeightLoaded extends BMIWeightState {
  final List<BMIWeight> records;

  const BMIWeightLoaded(this.records);

  @override
  List<Object> get props => [records];
}

class BMIWeightError extends BMIWeightState {
  final String message;

  const BMIWeightError(this.message);

  @override
  List<Object> get props => [message];
}
