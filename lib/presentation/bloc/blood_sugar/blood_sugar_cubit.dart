import 'package:doctor_care/domain/entities/blood_sugar.dart';
import 'package:doctor_care/domain/usecase/blood_sugar/delete_blood_sugar.dart';
import 'package:doctor_care/domain/usecase/blood_sugar/get_blood_sugar.dart';
import 'package:doctor_care/domain/usecase/blood_sugar/insert_blood_sugar.dart';
import 'package:doctor_care/domain/usecase/blood_sugar/update_blood_sugar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blood_sugar_state.dart';

class BloodSugarCubit extends Cubit<BloodSugarState> {
  final GetBloodSugar getBloodSugar;
  final InsertBloodSugar insertBloodSugar;
  final UpdateBloodSugar updateBloodSugar;
  final DeleteBloodSugar deleteBloodSugar;

  BloodSugarCubit(
    this.getBloodSugar,
    this.insertBloodSugar,
    this.updateBloodSugar,
    this.deleteBloodSugar,
  ) : super(BloodSugarInitial());

  Future<void> loadBloodSugarRecords() async {
    emit(BloodSugarLoading());
    try {
      final records = await getBloodSugar();
      emit(BloodSugarLoaded(records));
    } catch (e) {
      emit(BloodSugarError('Không tải được dữ liệu đường huyết'));
    }
  }

  Future<void> insertBloodSugarRecord(BloodSugar record) async {
    emit(BloodSugarLoading());
    try {
      await insertBloodSugar(record);
      emit(BloodSugarLoaded(await getBloodSugar()));
    } catch (e) {
      emit(BloodSugarError('Không thể thêm dữ liệu đường huyết'));
    }
  }

  Future<void> updateBloodSugarRecord(BloodSugar record) async {
    emit(BloodSugarLoading());
    try {
      await updateBloodSugar(record);
      emit(BloodSugarLoaded(await getBloodSugar()));
    } catch (e) {
      emit(BloodSugarError('Không thể cập nhật dữ liệu đường huyết'));
    }
  }

  Future<void> deleteBloodSugarRecord(String id) async {
    emit(BloodSugarLoading());
    try {
      await deleteBloodSugar(id);
      emit(BloodSugarLoaded(await getBloodSugar()));
    } catch (e) {
      emit(BloodSugarError('Không thể xóa dữ liệu đường huyết'));
    }
  }
}
