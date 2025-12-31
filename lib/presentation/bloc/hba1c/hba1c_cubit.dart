import 'package:doctor_care/domain/entities/hba1c.dart';
import 'package:doctor_care/domain/usecase/hba1c/delete_hba1c.dart';
import 'package:doctor_care/domain/usecase/hba1c/get_hba1c.dart';
import 'package:doctor_care/domain/usecase/hba1c/insert_hba1c.dart';
import 'package:doctor_care/domain/usecase/hba1c/update_hba1c.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'hba1c_state.dart';

class Hba1cCubit extends Cubit<Hba1cState> {
  final GetHba1c getHba1c;
  final InsertHba1c insertHba1c;
  final UpdateHba1c updateHba1c;
  final DeleteHba1c deleteHba1c;

  Hba1cCubit(
    this.getHba1c, 
    this.insertHba1c, 
    this.updateHba1c, 
    this.deleteHba1c, 
    ) : super(Hba1cInitial());

  Future<void> loadHba1cRecords() async {
    emit(Hba1cLoading());
    try {
      final hba1c = await getHba1c();
      emit(Hba1cLoaded(hba1c));
    } catch (e) {
      emit(Hba1cError('Không tải được dữ liệu HbA1c'));
    }
  }

  Future<void> updateHba1cRecord(HbA1c hba1c) async {
    try {
      emit(Hba1cLoading());
      await updateHba1c(hba1c);
      final hba1cRecords = await getHba1c();
      emit(Hba1cLoaded(hba1cRecords));
    } catch (e) {
      emit(HbA1cFailure('Không cập nhật được dữ liệu HbA1c'));
    }
  }

  Future<void> addHba1cRecord(HbA1c hba1c) async {
    try {
      emit(Hba1cLoading());
      await insertHba1c(hba1c);
      final hba1cRecords = await getHba1c();
      emit(Hba1cLoaded(hba1cRecords));
    } catch (e) {
      emit(HbA1cFailure('Không thêm được dữ liệu HbA1c'));
    }
  }

  Future<void> deleteHba1cRecord(String id) async {
    try {
      emit(Hba1cLoading());
      await deleteHba1c(id);
      final hba1cRecords = await getHba1c();
      emit(Hba1cLoaded(hba1cRecords));
    } catch (e) {
      emit(HbA1cFailure('Không xóa được dữ liệu HbA1c'));
    }
  }
}
