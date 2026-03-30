import 'package:doctor_care/domain/entities/creatinine.dart';
import 'package:doctor_care/domain/usecase/creatinine/delete_creatinine.dart';
import 'package:doctor_care/domain/usecase/creatinine/get_creatinine.dart';
import 'package:doctor_care/domain/usecase/creatinine/insert_creatinine.dart';
import 'package:doctor_care/domain/usecase/creatinine/update_creatinine.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'creatinine_state.dart';

class CreatinineCubit extends Cubit<CreatinineState> {
  final GetCreatinine getCreatinine;
  final InsertCreatinine insertCreatinine;
  final UpdateCreatinine updateCreatinine;
  final DeleteCreatinine deleteCreatinine;

  CreatinineCubit(
    this.getCreatinine,
    this.insertCreatinine,
    this.updateCreatinine,
    this.deleteCreatinine,
  ) : super(CreatinineInitial());

  Future<void> loadCreatinineRecords() async {
    emit(CreatinineLoading());
    try {
      final records = await getCreatinine();
      emit(CreatinineLoaded(records));
    } catch (e) {
      emit(CreatinineError('Không tải được dữ liệu Creatinine'));
    }
  }

  Future<void> insertCreatinineRecord(Creatinine record) async {
    emit(CreatinineLoading());
    try {
      await insertCreatinine(record);
      emit(CreatinineLoaded(await getCreatinine()));
    } catch (e) {
      emit(CreatinineError('Không thể thêm dữ liệu Creatinine'));
    }
  }

  Future<void> updateCreatinineRecord(Creatinine record) async {
    emit(CreatinineLoading());
    try {
      await updateCreatinine(record);
      emit(CreatinineLoaded(await getCreatinine()));
    } catch (e) {
      emit(CreatinineError('Không thể cập nhật dữ liệu Creatinine'));
    }
  }

  Future<void> deleteCreatinineRecord(String id) async {
    emit(CreatinineLoading());
    try {
      await deleteCreatinine(id);
      emit(CreatinineLoaded(await getCreatinine()));
    } catch (e) {
      emit(CreatinineError('Không thể xóa dữ liệu Creatinine'));
    }
  }
}
