part of 'hba1c_cubit.dart';

abstract class Hba1cState extends Equatable {
  const Hba1cState();

  @override
  List<Object> get props => [];
}

class Hba1cInitial extends Hba1cState {}
class Hba1cLoading extends Hba1cState {}
class Hba1cLoaded extends Hba1cState {
  final List<HbA1c> hba1cRecords;

  const Hba1cLoaded(this.hba1cRecords);

  @override
  List<Object> get props => [hba1cRecords];
}

class Hba1cError extends Hba1cState {
  final String message;

  const Hba1cError(this.message);

  @override
  List<Object> get props => [message];
}

class HbA1cAddSuccess extends Hba1cState {}
class HbA1cUpdateSuccess extends Hba1cState {}
class HbA1cDeleteSuccess extends Hba1cState {}
class HbA1cFailure extends Hba1cState{
  final String message;
  const HbA1cFailure(this.message);
}
