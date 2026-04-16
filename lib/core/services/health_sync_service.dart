import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthSyncService {
  HealthSyncService._();
  static final HealthSyncService instance = HealthSyncService._();

  static final _health = Health();

  static const types = [HealthDataType.STEPS];
  static const permissions = [HealthDataAccess.READ];

  bool _isConfigured = false;

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Cấu hình Health. Gọi ở main (hoặc trước khi dùng).
  void configure() {
    if (_isConfigured) return;
    _health.configure();
    _isConfigured = true;
  }

  /// Request permissions for Health Sync
  Future<bool> requestPermissions() async {
    configure();

    try {
      // Android: Bắt buộc xin quyền ACTIVITY_RECOGNITION trước
      if (Platform.isAndroid) {
        final activityStatus = await Permission.activityRecognition.request();
        if (activityStatus.isDenied || activityStatus.isPermanentlyDenied) {
          _log('HealthSync: ACTIVITY_RECOGNITION denied');
          return false;
        }
      }

      // Xin quyền Health (HealthKit/HealthConnect)
      final hasPermissions =
          await _health.hasPermissions(types, permissions: permissions) ?? false;
      if (!hasPermissions) {
        final granted =
            await _health.requestAuthorization(types, permissions: permissions);
        if (!granted) {
          _log('HealthSync: Authorization denied');
          return false;
        }
      }

      return true;
    } catch (e) {
      _log('HealthSync Exception in requestPermissions: $e');
      return false;
    }
  }

  /// Lấy tổng số bước chân của ngày hôm nay (từ 00:00:00 đến hiện tại)
  ///
  /// Note: method will request permission if needed.
  Future<int?> getTodaysSteps() async {
    try {
      final ok = await requestPermissions();
      if (!ok) return null;

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps;
    } catch (e) {
      _log('HealthSync Exception getting steps: $e');
      return null;
    }
  }
}
