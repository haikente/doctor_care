import 'package:equatable/equatable.dart';
import 'package:doctor_care/domain/entities/bmi_weight.dart';
import 'package:doctor_care/domain/usecase/BMI/delete_bmiweight.dart';
import 'package:doctor_care/domain/usecase/BMI/get_bmiweight.dart';
import 'package:doctor_care/domain/usecase/BMI/insert_bmiweight.dart';
import 'package:doctor_care/domain/usecase/BMI/update_bmiweight.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'bmi_weight_event.dart';
part 'bmi_weight_state.dart';

class BMIWeightBloc extends Bloc<BMIWeightEvent, BMIWeightState> {
  final GetBMIWeight getBMIWeight;
  final InsertBmiweight insertBmiweight;
  final UpdateBmiWeight updateBmiWeight;
  final DeleteBmiweight deleteBmiweight;

  BMIWeightBloc({
    required this.getBMIWeight,
    required this.insertBmiweight,
    required this.updateBmiWeight,
    required this.deleteBmiweight,
  }) : super(BMIWeightInitial()) {
    on<LoadBMIWeightRecords>(_onLoadBMIWeightRecords);
    on<AddBMIWeightRecord>(_onAddBMIWeightRecord);
    on<UpdateBMIWeightRecord>(_onUpdateBMIWeightRecord);
    on<DeleteBMIWeightRecord>(_onDeleteBMIWeightRecord);
  }

  Future<void> _onLoadBMIWeightRecords(
    LoadBMIWeightRecords event,
    Emitter<BMIWeightState> emit,
  ) async {
    emit(BMIWeightLoading());
    try {
      final records = await getBMIWeight();
      emit(BMIWeightLoaded(records));
    } catch (e) {
      emit(BMIWeightError(e.toString()));
    }
  }

  Future<void> _onAddBMIWeightRecord(
    AddBMIWeightRecord event,
    Emitter<BMIWeightState> emit,
  ) async {
    emit(BMIWeightLoading());
    try {
      await insertBmiweight(event.record);
      add(LoadBMIWeightRecords());
    } catch (e) {
      emit(BMIWeightError(e.toString()));
    }
  }

  Future<void> _onUpdateBMIWeightRecord(
    UpdateBMIWeightRecord event,
    Emitter<BMIWeightState> emit,
  ) async {
    emit(BMIWeightLoading());
    try {
      await updateBmiWeight(event.record);
      add(LoadBMIWeightRecords());
    } catch (e) {
      emit(BMIWeightError(e.toString()));
    }
  }

  Future<void> _onDeleteBMIWeightRecord(
    DeleteBMIWeightRecord event,
    Emitter<BMIWeightState> emit,
  ) async {
    emit(BMIWeightLoading());
    try {
      await deleteBmiweight(event.id);
      add(LoadBMIWeightRecords());
    } catch (e) {
      emit(BMIWeightError(e.toString()));
    }
  }
}
