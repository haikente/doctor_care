part of 'blood_sugar_cubit.dart';

abstract class BloodSugarState extends Equatable {
  const BloodSugarState();

  @override
  List<Object> get props => [];
}

class BloodSugarInitial extends BloodSugarState {}

class BloodSugarLoading extends BloodSugarState {}

class BloodSugarLoaded extends BloodSugarState {
  final List<BloodSugar> records;

  const BloodSugarLoaded(this.records);

  @override
  List<Object> get props => [records];
}

class BloodSugarError extends BloodSugarState {
  final String message;

  const BloodSugarError(this.message);

  @override
  List<Object> get props => [message];
}
