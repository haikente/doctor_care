import 'package:doctor_care/domain/entities/cholesterol.dart';
import 'package:doctor_care/domain/usecase/cholesterol/delete_cholesterol.dart';
import 'package:doctor_care/domain/usecase/cholesterol/get_cholesterol.dart';
import 'package:doctor_care/domain/usecase/cholesterol/insert_cholesterol.dart';
import 'package:doctor_care/domain/usecase/cholesterol/update_cholesterol.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cholesterol_state.dart';

class CholesterolCubit extends Cubit<CholesterolState> {
  final GetCholesterol getCholesterol;
  final InsertCholesterol insertCholesterol;
  final UpdateCholesterol updateCholesterol;
  final DeleteCholesterol deleteCholesterol;

  CholesterolCubit(
    this.getCholesterol,
    this.insertCholesterol,
    this.updateCholesterol,
    this.deleteCholesterol,
  ) : super(CholesterolInitial());

  Future<void> loadCholesterolRecords() async {
    emit(CholesterolLoading());
    try {
      final records = await getCholesterol();
      emit(CholesterolLoaded(records));
    } catch (e) {
      emit(CholesterolError('Không tải được dữ liệu cholesterol'));
    }
  }

  Future<void> insertCholesterolRecord(Cholesterol record) async {
    emit(CholesterolLoading());
    try {
      await insertCholesterol(record);
      emit(CholesterolLoaded(await getCholesterol()));
    } catch (e) {
      emit(CholesterolError('Không thể thêm dữ liệu cholesterol'));
    }
  }

  Future<void> updateCholesterolRecord(Cholesterol record) async {
    emit(CholesterolLoading());
    try {
      await updateCholesterol(record);
      emit(CholesterolLoaded(await getCholesterol()));
    } catch (e) {
      emit(CholesterolError('Không thể cập nhật dữ liệu cholesterol'));
    }
  }

  Future<void> deleteCholesterolRecord(String id) async {
    emit(CholesterolLoading());
    try {
      await deleteCholesterol(id);
      emit(CholesterolLoaded(await getCholesterol()));
    } catch (e) {
      emit(CholesterolError('Không thể xóa dữ liệu cholesterol'));
    }
  }
}
