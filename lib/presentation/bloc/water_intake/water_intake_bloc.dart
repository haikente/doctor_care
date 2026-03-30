import 'package:doctor_care/domain/usecase/water_intake/delete_water_intake.dart';
import 'package:doctor_care/domain/usecase/water_intake/get_water_intake.dart';
import 'package:doctor_care/domain/usecase/water_intake/insert_water_intake.dart';
import 'package:doctor_care/domain/usecase/water_intake/update_water_intake.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_care/domain/entities/water_intake.dart';

part 'water_intake_event.dart';
part 'water_intake_state.dart';

class WaterIntakeBloc extends Bloc<WaterIntakeEvent, WaterIntakeState> {
  final GetWaterIntake getWaterIntake;
  final InsertWaterIntake insertWaterIntake;
  final UpdateWaterIntake updateWaterIntake;
  final DeleteWaterIntake deleteWaterIntake;

  WaterIntakeBloc({
    required this.getWaterIntake,
    required this.insertWaterIntake,
    required this.updateWaterIntake,
    required this.deleteWaterIntake,
  }) : super(WaterIntakeInitial()) {
    on<LoadWaterIntakeRecords>(_onLoadRecords);
    on<AddWaterIntakeRecord>(_onAddRecord);
    on<UpdateWaterIntakeRecord>(_onUpdateRecord);
    on<DeleteWaterIntakeRecord>(_onDeleteRecord);
  }

  Future<void> _onLoadRecords(
    LoadWaterIntakeRecords event,
    Emitter<WaterIntakeState> emit,
  ) async {
    emit(WaterIntakeLoading());
    try {
      final records = await getWaterIntake();
      emit(WaterIntakeLoaded(records));
    } catch (e) {
      emit(WaterIntakeError(e.toString()));
    }
  }

  Future<void> _onAddRecord(
    AddWaterIntakeRecord event,
    Emitter<WaterIntakeState> emit,
  ) async {
    try {
      await insertWaterIntake(event.record);
      add(LoadWaterIntakeRecords());
    } catch (e) {
      emit(WaterIntakeError(e.toString()));
    }
  }

  Future<void> _onUpdateRecord(
    UpdateWaterIntakeRecord event,
    Emitter<WaterIntakeState> emit,
  ) async {
    try {
      await updateWaterIntake(event.record);
      add(LoadWaterIntakeRecords());
    } catch (e) {
      emit(WaterIntakeError(e.toString()));
    }
  }

  Future<void> _onDeleteRecord(
    DeleteWaterIntakeRecord event,
    Emitter<WaterIntakeState> emit,
  ) async {
    try {
      await deleteWaterIntake(event.id);
      add(LoadWaterIntakeRecords());
    } catch (e) {
      emit(WaterIntakeError(e.toString()));
    }
  }
}
