import 'package:doctor_care/domain/entities/sleep_record.dart';
import 'package:doctor_care/domain/usecase/sleep_record/delete_sleep_record.dart';
import 'package:doctor_care/domain/usecase/sleep_record/get_sleep_record.dart';
import 'package:doctor_care/domain/usecase/sleep_record/insert_sleep_record.dart';
import 'package:doctor_care/domain/usecase/sleep_record/update_sleep_record.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sleep_record_state.dart';

class SleepRecordCubit extends Cubit<SleepRecordState> {
  final GetSleepRecord getSleepRecord;
  final InsertSleepRecord insertSleepRecord;
  final UpdateSleepRecord updateSleepRecord;
  final DeleteSleepRecord deleteSleepRecord;

  SleepRecordCubit(
    this.getSleepRecord,
    this.insertSleepRecord,
    this.updateSleepRecord,
    this.deleteSleepRecord,
  ) : super(SleepRecordInitial());

  Future<void> loadSleepRecords() async {
    emit(SleepRecordLoading());
    try {
      final records = await getSleepRecord();
      emit(SleepRecordLoaded(records));
    } catch (e) {
      emit(SleepRecordError('Không tải được dữ liệu giấc ngủ'));
    }
  }

  Future<void> insertSleepRecordData(SleepRecord record) async {
    emit(SleepRecordLoading());
    try {
      await insertSleepRecord(record);
      emit(SleepRecordLoaded(await getSleepRecord()));
    } catch (e) {
      emit(SleepRecordError('Không thể thêm dữ liệu giấc ngủ'));
    }
  }

  Future<void> updateSleepRecordData(SleepRecord record) async {
    emit(SleepRecordLoading());
    try {
      await updateSleepRecord(record);
      emit(SleepRecordLoaded(await getSleepRecord()));
    } catch (e) {
      emit(SleepRecordError('Không thể cập nhật dữ liệu giấc ngủ'));
    }
  }

  Future<void> deleteSleepRecordData(String id) async {
    emit(SleepRecordLoading());
    try {
      await deleteSleepRecord(id);
      emit(SleepRecordLoaded(await getSleepRecord()));
    } catch (e) {
      emit(SleepRecordError('Không thể xóa dữ liệu giấc ngủ'));
    }
  }
}
