
import 'package:doctor_care/domain/entities/temperature.dart';
import 'package:doctor_care/domain/usecase/temperature/delete_temperature.dart';
import 'package:doctor_care/domain/usecase/temperature/get_temperature.dart';
import 'package:doctor_care/domain/usecase/temperature/insert_temperature.dart';
import 'package:doctor_care/domain/usecase/temperature/update_temperature.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'temperature_state.dart';

class TemperatureCubit extends Cubit<TemperatureState> {
  final GetTemperature getTemperature;
  final InsertTemperature insertTemperature;
  final UpdateTemperature updateTemperature;
  final DeleteTemperature deleteTemperature;

  TemperatureCubit(
      this.getTemperature,
      this.insertTemperature,
      this.updateTemperature,
      this.deleteTemperature) : super(TemperatureInitial());

  Future<void> loadTemperatureRecords() async {
    emit(TemperatureLoading());
    try {
      final temperatures = await getTemperature();
      emit(TemperatureLoaded(temperatures));
    } catch (e) {
      emit(TemperatureError('Không tải được dữ liệu nhiệt độ'));
    }
  }

  Future<void> addTemperatureRecords(Temperature temperature) async {
    try {
       emit(TemperatureLoading());
      await insertTemperature(temperature);
      final temperatures = await getTemperature();
      emit(TemperatureLoaded(temperatures));
    } catch (e) {
      emit(TemperatureError('Không thêm được dữ liệu nhiệt độ'));
    }
  }

  Future<void> updateTemperatureRecord(Temperature temperature) async {
    try {
      emit(TemperatureLoading());
      await updateTemperature(temperature);
      final temperatures = await getTemperature();
      emit(TemperatureLoaded(temperatures));
    } catch (e) {
      emit(TemperatureError('Không cập nhật được dữ liệu nhiệt độ'));
    }
  }

  Future<void> deleteTemperatureRecord(String id) async {
    try {
      emit(TemperatureLoading());
      await deleteTemperature(id);
      final temperatures = await getTemperature();
      emit(TemperatureLoaded(temperatures));
    } catch (e) {
      emit(TemperatureError('Không xóa được dữ liệu nhiệt độ'));
    }
  }
}