import 'package:equatable/equatable.dart';
import 'package:doctor_care/domain/entities/spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/delete_spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/get_spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/insert_spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/update_spO2heartrate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'spo2heartrate_event.dart';
part 'spo2heartrate_state.dart';

class Spo2heartrateBloc extends Bloc<Spo2heartrateEvent, Spo2heartrateState> {
  final GetSpo2heartrate getSpo2heartrate;
  final InsertSpo2heartrate insertSpo2heartrate;
  final UpdateSpo2heartrate updateSpo2heartrate;
  final DeleteSpo2heartrate deleteSpo2heartrate;

  Spo2heartrateBloc({
    required this.getSpo2heartrate,
    required this.insertSpo2heartrate,
    required this.updateSpo2heartrate,
    required this.deleteSpo2heartrate,
  }) : super(Spo2heartrateInitial()) {
    on<LoadSpo2HeartRateRecords>(_onLoadSpo2HeartRateRecords);
    on<AddSpo2HeartRateRecord>(_onAddSpo2HeartRateRecord);
    on<UpdateSpo2HeartRateRecord>(_onUpdateSpo2HeartRateRecord);
    on<DeleteSpo2HeartRateRecord>(_onDeleteSpo2HeartRateRecord);
  }

  Future<void> _onLoadSpo2HeartRateRecords(
    LoadSpo2HeartRateRecords event,
    Emitter<Spo2heartrateState> emit,
  ) async {
    emit(Spo2heartrateLoading());
    try {
      final records = await getSpo2heartrate();
      emit(Spo2heartrateLoaded(records));
    } catch (e) {
      emit(Spo2heartrateError(e.toString()));
    }
  }

  Future<void> _onAddSpo2HeartRateRecord(
    AddSpo2HeartRateRecord event,
    Emitter<Spo2heartrateState> emit,
  ) async {
    emit(Spo2heartrateLoading());
    try {
      await insertSpo2heartrate(event.record);
      add(LoadSpo2HeartRateRecords());
    } catch (e) {
      emit(Spo2heartrateError(e.toString()));
    }
  }

  Future<void> _onUpdateSpo2HeartRateRecord(
    UpdateSpo2HeartRateRecord event,
    Emitter<Spo2heartrateState> emit,
  ) async {
    emit(Spo2heartrateLoading());
    try {
      await updateSpo2heartrate(event.record);
      add(LoadSpo2HeartRateRecords());
    } catch (e) {
      emit(Spo2heartrateError(e.toString()));
    }
  }

  Future<void> _onDeleteSpo2HeartRateRecord(
    DeleteSpo2HeartRateRecord event,
    Emitter<Spo2heartrateState> emit,
  ) async {
    emit(Spo2heartrateLoading());
    try {
      await deleteSpo2heartrate(event.id);
      add(LoadSpo2HeartRateRecords());
    } catch (e) {
      emit(Spo2heartrateError(e.toString()));
    }
  }
}
