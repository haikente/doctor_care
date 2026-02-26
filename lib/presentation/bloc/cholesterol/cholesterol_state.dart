part of 'cholesterol_cubit.dart';

abstract class CholesterolState extends Equatable {
  const CholesterolState();
  @override
  List<Object> get props => [];
}

class CholesterolInitial extends CholesterolState {}

class CholesterolLoading extends CholesterolState {}

class CholesterolLoaded extends CholesterolState {
  final List<Cholesterol> records;
  const CholesterolLoaded(this.records);
  @override
  List<Object> get props => [records];
}

class CholesterolError extends CholesterolState {
  final String message;
  const CholesterolError(this.message);
  @override
  List<Object> get props => [message];
}
