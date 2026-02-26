import 'package:doctor_care/domain/entities/step_count.dart';
import 'package:doctor_care/domain/usecase/step_count/delete_step_count.dart';
import 'package:doctor_care/domain/usecase/step_count/get_step_count.dart';
import 'package:doctor_care/domain/usecase/step_count/insert_step_count.dart';
import 'package:doctor_care/domain/usecase/step_count/update_step_count.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'step_count_state.dart';

class StepCountCubit extends Cubit<StepCountState> {
  final GetStepCount getStepCount;
  final InsertStepCount insertStepCount;
  final UpdateStepCount updateStepCount;
  final DeleteStepCount deleteStepCount;

  StepCountCubit(
    this.getStepCount,
    this.insertStepCount,
    this.updateStepCount,
    this.deleteStepCount,
  ) : super(StepCountInitial());

  Future<void> loadStepCounts() async {
    emit(StepCountLoading());
    try {
      final records = await getStepCount();
      emit(StepCountLoaded(records));
    } catch (e) {
      emit(StepCountError('Không tải được dữ liệu bước chân'));
    }
  }

  Future<void> insertStepCountRecord(StepCount record) async {
    emit(StepCountLoading());
    try {
      await insertStepCount(record);
      emit(StepCountLoaded(await getStepCount()));
    } catch (e) {
      emit(StepCountError('Không thể thêm dữ liệu bước chân'));
    }
  }

  Future<void> updateStepCountRecord(StepCount record) async {
    emit(StepCountLoading());
    try {
      await updateStepCount(record);
      emit(StepCountLoaded(await getStepCount()));
    } catch (e) {
      emit(StepCountError('Không thể cập nhật dữ liệu bước chân'));
    }
  }

  Future<void> deleteStepCountRecord(String id) async {
    emit(StepCountLoading());
    try {
      await deleteStepCount(id);
      emit(StepCountLoaded(await getStepCount()));
    } catch (e) {
      emit(StepCountError('Không thể xóa dữ liệu bước chân'));
    }
  }
}
