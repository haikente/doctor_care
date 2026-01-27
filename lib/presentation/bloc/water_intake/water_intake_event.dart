part of 'water_intake_bloc.dart';

abstract class WaterIntakeEvent extends Equatable {
  const WaterIntakeEvent();

  @override
  List<Object> get props => [];
}

class LoadWaterIntakeRecords extends WaterIntakeEvent {}

class AddWaterIntakeRecord extends WaterIntakeEvent {
  final WaterIntake record;

  const AddWaterIntakeRecord(this.record);

  @override
  List<Object> get props => [record];
}

class UpdateWaterIntakeRecord extends WaterIntakeEvent {
  final WaterIntake record;

  const UpdateWaterIntakeRecord(this.record);

  @override
  List<Object> get props => [record];
}

class DeleteWaterIntakeRecord extends WaterIntakeEvent {
  final String id;

  const DeleteWaterIntakeRecord(this.id);

  @override
  List<Object> get props => [id];
}
