import 'package:doctor_care/domain/entities/blood_pressure.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/delete_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/get_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/insert_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/update_blood_pressure.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blood_pressure_state.dart';

class BloodPressureCubit extends Cubit<BloodPressureState> {
  final GetBloodPressure getBloodPressure;
  final InsertBloodPressure insertBloodPressure;
  final UpdateBloodPressure updateBloodPressure;
  final DeleteBloodPressure deleteBloodPressure;

  BloodPressureCubit(
    this.getBloodPressure,
    this.insertBloodPressure,
    this.updateBloodPressure, 
    this.deleteBloodPressure
    ) : super(BloodPressureInitial());

  Future<void> loadBloodPressureRecords() async {
    emit(BloodPressureLoading());
    try {
      final bloodPressure = await getBloodPressure();
      emit(BloodPressureLoaded(bloodPressure));
    } catch (e) {
      emit(BloodPressureError('Không tải được dữ liệu huyết áp'));
    }
  }

  Future<void> insertBloodPressureRecord(BloodPressure record) async {
    emit(BloodPressureLoading());
    try {
      await insertBloodPressure(record);
      emit(BloodPressureLoaded(await getBloodPressure()));
    } catch (e) {
      emit(BloodPressureFailure('Không thể thêm dữ liệu huyết áp'));
    }
  }

  Future<void> updateBloodPressureRecord(BloodPressure record) async {
    emit(BloodPressureLoading());
    try {
      await updateBloodPressure(record);
      emit(BloodPressureLoaded(await getBloodPressure()));
    } catch (e) {
      emit(BloodPressureFailure('Không thể cập nhật dữ liệu huyết áp'));
    }
  }

  Future<void> deleteBloodPressureRecord(String id) async {
    emit(BloodPressureLoading());
    try {
      await deleteBloodPressure(id);
      emit(BloodPressureLoaded(await getBloodPressure()));
    } catch (e) {
      emit(BloodPressureFailure('Không thể xóa dữ liệu huyết áp'));
    }
  }

}
