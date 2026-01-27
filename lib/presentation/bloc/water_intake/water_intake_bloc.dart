import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/water_intake_model.dart';
import 'package:doctor_care/domain/entities/water_intake.dart';

part 'water_intake_event.dart';
part 'water_intake_state.dart';

class WaterIntakeBloc extends Bloc<WaterIntakeEvent, WaterIntakeState> {
  final DbHelper dbHelper;

  WaterIntakeBloc(this.dbHelper) : super(WaterIntakeInitial()) {
    on<LoadWaterIntakeRecords>(_onLoadRecords);
    on<AddWaterIntakeRecord>(_onAddRecord);
    on<UpdateWaterIntakeRecord>(_onUpdateRecord);
    on<DeleteWaterIntakeRecord>(_onDeleteRecord);
  }

  Future<void> _onLoadRecords(
    LoadWaterIntakeRecords event,
    Emitter<WaterIntakeState> emit,
  ) async {
    emit(WaterIntakeLoading());
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'water_intake',
        orderBy: 'timestamp DESC',
      );

      final records = maps.map((map) => WaterIntakeModel.fromMap(map)).toList();
      emit(WaterIntakeLoaded(records));
    } catch (e) {
      emit(WaterIntakeError(e.toString()));
    }
  }

  Future<void> _onAddRecord(
    AddWaterIntakeRecord event,
    Emitter<WaterIntakeState> emit,
  ) async {
    try {
      final db = await dbHelper.database;
      final model = WaterIntakeModel(
        amount: event.record.amount,
        timestamp: event.record.timestamp,
        note: event.record.note,
      );

      await db.insert('water_intake', model.toMap());
      add(LoadWaterIntakeRecords());
    } catch (e) {
      emit(WaterIntakeError(e.toString()));
    }
  }

  Future<void> _onUpdateRecord(
    UpdateWaterIntakeRecord event,
    Emitter<WaterIntakeState> emit,
  ) async {
    try {
      final db = await dbHelper.database;
      final model = WaterIntakeModel(
        id: event.record.id,
        amount: event.record.amount,
        timestamp: event.record.timestamp,
        note: event.record.note,
      );

      await db.update(
        'water_intake',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [event.record.id],
      );
      add(LoadWaterIntakeRecords());
    } catch (e) {
      emit(WaterIntakeError(e.toString()));
    }
  }

  Future<void> _onDeleteRecord(
    DeleteWaterIntakeRecord event,
    Emitter<WaterIntakeState> emit,
  ) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'water_intake',
        where: 'id = ?',
        whereArgs: [int.parse(event.id)],
      );
      add(LoadWaterIntakeRecords());
    } catch (e) {
      emit(WaterIntakeError(e.toString()));
    }
  }
}
