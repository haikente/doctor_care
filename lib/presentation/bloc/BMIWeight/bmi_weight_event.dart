part of 'bmi_weight_bloc.dart';

abstract class BMIWeightEvent extends Equatable {
  const BMIWeightEvent();

  @override
  List<Object> get props => [];
}

class LoadBMIWeightRecords extends BMIWeightEvent {}

class AddBMIWeightRecord extends BMIWeightEvent {
  final BMIWeight record;

  const AddBMIWeightRecord(this.record);

  @override
  List<Object> get props => [record];
}

class UpdateBMIWeightRecord extends BMIWeightEvent {
  final BMIWeight record;

  const UpdateBMIWeightRecord(this.record);

  @override
  List<Object> get props => [record];
}

class DeleteBMIWeightRecord extends BMIWeightEvent {
  final String id;

  const DeleteBMIWeightRecord(this.id);

  @override
  List<Object> get props => [id];
}
