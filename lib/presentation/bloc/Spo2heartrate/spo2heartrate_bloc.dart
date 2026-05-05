import 'package:equatable/equatable.dart';
import 'package:doctor_care/domain/entities/spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/delete_spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/get_spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/insert_spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/update_spO2heartrate.dart';
import 'package:doctor_care/core/services/health_sync_service.dart';
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
    on<SyncFromHealthConnect>(_onSyncFromHealthConnect);
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

  Future<void> _onSyncFromHealthConnect(
    SyncFromHealthConnect event,
    Emitter<Spo2heartrateState> emit,
  ) async {
    emit(Spo2heartrateSyncing());
    try {
      final healthService = HealthSyncService.instance;
      final results = await healthService.getSpo2HeartRateData(
        daysBack: event.daysBack,
      );

      if (results.isEmpty) {
        emit(const Spo2heartrateSyncResult(
          syncedCount: 0,
          message: 'Không tìm thấy dữ liệu từ Health Connect',
        ));
        // Reload existing records
        add(LoadSpo2HeartRateRecords());
        return;
      }

      int syncedCount = 0;
      for (final result in results) {
        if (!result.hasAnyData) continue;

        // Chỉ lưu nếu có cả SpO2 và Heart Rate, hoặc điền giá trị mặc định
        final spo2 = result.spo2 ?? 98;       // mặc định 98% nếu chỉ có HR
        final heartRate = result.heartRate ?? 75; // mặc định 75 bpm nếu chỉ có SpO2

        final record = SpO2HeartRate(
          spo2: spo2,
          heartRate: heartRate,
          timestamp: result.timestamp,
          note: _buildSyncNote(result),
          source: SpO2Source.healthConnect,
        );

        try {
          await insertSpo2heartrate(record);
          syncedCount++;
        } catch (e) {
          // Bỏ qua nếu đã tồn tại (trùng timestamp + profileId)
        }
      }

      emit(Spo2heartrateSyncResult(
        syncedCount: syncedCount,
        message: 'Đã đồng bộ $syncedCount bản ghi từ Health Connect',
      ));

      // Reload dữ liệu
      add(LoadSpo2HeartRateRecords());
    } catch (e) {
      emit(Spo2heartrateError('Lỗi đồng bộ Health Connect: ${e.toString()}'));
    }
  }

  String _buildSyncNote(HealthConnectSpo2Result result) {
    final parts = <String>[];
    if (result.hasSpo2) parts.add('SpO2: ${result.spo2}%');
    if (result.hasHeartRate) parts.add('HR: ${result.heartRate} bpm');
    if (!result.hasSpo2) parts.add('SpO2: mặc định');
    if (!result.hasHeartRate) parts.add('HR: mặc định');
    return 'Health Connect - ${parts.join(', ')}';
  }
}
