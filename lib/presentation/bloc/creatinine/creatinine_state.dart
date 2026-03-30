part of 'creatinine_cubit.dart';

abstract class CreatinineState extends Equatable {
  const CreatinineState();

  @override
  List<Object> get props => [];
}

class CreatinineInitial extends CreatinineState {}

class CreatinineLoading extends CreatinineState {}

class CreatinineLoaded extends CreatinineState {
  final List<Creatinine> records;

  const CreatinineLoaded(this.records);

  @override
  List<Object> get props => [records];
}

class CreatinineError extends CreatinineState {
  final String message;

  const CreatinineError(this.message);

  @override
  List<Object> get props => [message];
}
