part of 'blood_pressure_cubit.dart';

abstract class BloodPressureState extends Equatable {
  const BloodPressureState();

  @override
  List<Object> get props => [];
}

class BloodPressureInitial extends BloodPressureState {}
class BloodPressureLoading extends BloodPressureState {}
class BloodPressureLoaded extends BloodPressureState {
  final List<BloodPressure> records;

  const BloodPressureLoaded(this.records);

  @override
  List<Object> get props => [records];
}
class BloodPressureError extends BloodPressureState {
  final String message;

  const BloodPressureError(this.message);

  @override
  List<Object> get props => [message];
}
class BloodPressureFailure extends BloodPressureState {
  final String message;
  const BloodPressureFailure(this.message);
}

