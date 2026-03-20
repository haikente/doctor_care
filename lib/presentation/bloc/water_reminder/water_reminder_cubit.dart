import 'package:doctor_care/core/services/water_reminder_service.dart';
import 'package:doctor_care/presentation/bloc/water_reminder/water_reminder_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterReminderCubit extends Cubit<WaterReminderState> {
  static const _keyEnabled = 'water_reminder_enabled';
  static const _keyInterval = 'water_reminder_interval';
  static const _keyStart = 'water_reminder_start';
  static const _keyEnd = 'water_reminder_end';

  final WaterReminderService _service;

  WaterReminderCubit(this._service) : super(const WaterReminderState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(
      isEnabled: prefs.getBool(_keyEnabled) ?? false,
      intervalMinutes: prefs.getInt(_keyInterval) ?? 60,
      startHour: prefs.getInt(_keyStart) ?? 7,
      endHour: prefs.getInt(_keyEnd) ?? 21,
    ));
  }

  Future<void> _save(WaterReminderState s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, s.isEnabled);
    await prefs.setInt(_keyInterval, s.intervalMinutes);
    await prefs.setInt(_keyStart, s.startHour);
    await prefs.setInt(_keyEnd, s.endHour);
  }

  Future<bool> toggle() async {
    // Xin quyền nếu muốn bật
    if (!state.isEnabled) {
      final granted = await _service.requestPermission();
      if (!granted) return false;
    }

    final next = state.copyWith(isEnabled: !state.isEnabled);
    emit(next);
    await _save(next);

    if (next.isEnabled) {
      await _service.scheduleReminders(
        intervalMinutes: next.intervalMinutes,
        startHour: next.startHour,
        endHour: next.endHour,
      );
    } else {
      await _service.cancelAllReminders();
    }
    return true;
  }

  Future<void> updateInterval(int minutes) async {
    final next = state.copyWith(intervalMinutes: minutes);
    emit(next);
    await _save(next);
    if (next.isEnabled) {
      await _service.scheduleReminders(
        intervalMinutes: next.intervalMinutes,
        startHour: next.startHour,
        endHour: next.endHour,
      );
    }
  }

  Future<void> updateTimeRange(int start, int end) async {
    final next = state.copyWith(startHour: start, endHour: end);
    emit(next);
    await _save(next);
    if (next.isEnabled) {
      await _service.scheduleReminders(
        intervalMinutes: next.intervalMinutes,
        startHour: next.startHour,
        endHour: next.endHour,
      );
    }
  }
}
