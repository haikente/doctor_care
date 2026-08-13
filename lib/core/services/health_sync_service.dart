import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

/// Kết quả đồng bộ SpO2 & Heart Rate từ Health Connect
class HealthConnectSpo2Result {
  final int? spo2;        // % SpO2 (null nếu không có)
  final int? heartRate;   // bpm (null nếu không có)
  final DateTime timestamp;

  HealthConnectSpo2Result({
    this.spo2,
    this.heartRate,
    required this.timestamp,
  });

  bool get hasSpo2 => spo2 != null;
  bool get hasHeartRate => heartRate != null;
  bool get hasAnyData => hasSpo2 || hasHeartRate;
}

class HealthSyncService {
  HealthSyncService._();
  static final HealthSyncService instance = HealthSyncService._();

  static final _health = Health();

  /// Types chỉ cho Steps (backward compatible)
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

  /// Request permissions cho Steps (backward compatible)
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

  /// Request permissions cho SpO2 & Heart Rate
  Future<bool> requestSpo2HeartRatePermissions() async {
    configure();

    try {
      if (Platform.isAndroid) {
        final activityStatus = await Permission.activityRecognition.request();
        if (activityStatus.isDenied || activityStatus.isPermanentlyDenied) {
          _log('HealthSync: ACTIVITY_RECOGNITION denied');
          return false;
        }
      }

      final spo2HrTypes = [
        HealthDataType.HEART_RATE,
        HealthDataType.BLOOD_OXYGEN,
      ];
      final spo2HrPermissions = [
        HealthDataAccess.READ,
        HealthDataAccess.READ,
      ];

      final hasPermissions = await _health.hasPermissions(
            spo2HrTypes,
            permissions: spo2HrPermissions,
          ) ??
          false;

      if (!hasPermissions) {
        final granted = await _health.requestAuthorization(
          spo2HrTypes,
          permissions: spo2HrPermissions,
        );
        if (!granted) {
          _log('HealthSync: SpO2/HR Authorization denied');
          return false;
        }
      }

      return true;
    } catch (e) {
      _log('HealthSync Exception in requestSpo2HeartRatePermissions: $e');
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

  /// Lấy tổng số bước của một ngày bất kỳ.
  ///
  /// Với ngày hôm nay, khoảng thời gian kết thúc ở thời điểm hiện tại.
  /// Với ngày quá khứ, khoảng thời gian kết thúc ở 00:00 ngày kế tiếp.
  Future<int?> getStepsForDay(
    DateTime date, {
    bool requestPermission = true,
  }) async {
    try {
      if (requestPermission) {
        final ok = await requestPermissions();
        if (!ok) return null;
      }

      final dayStart = DateTime(date.year, date.month, date.day);
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final dayEnd = dayStart == todayStart
          ? now
          : dayStart.add(const Duration(days: 1));

      final steps = await _health.getTotalStepsInInterval(dayStart, dayEnd);
      return steps;
    } catch (e) {
      _log('HealthSync Exception getting steps for day: $e');
      return null;
    }
  }

  /// Lấy dữ liệu SpO2 & Heart Rate từ Health Connect
  /// [daysBack] - Số ngày lấy dữ liệu ngược lại (mặc định 7 ngày)
  /// Trả về danh sách kết quả, mỗi kết quả chứa SpO2 và/hoặc Heart Rate
  Future<List<HealthConnectSpo2Result>> getSpo2HeartRateData({
    int daysBack = 7,
  }) async {
    try {
      final ok = await requestSpo2HeartRatePermissions();
      if (!ok) {
        _log('HealthSync: SpO2/HR permissions not granted');
        return [];
      }

      final now = DateTime.now();
      final startDate = DateTime(
        now.year,
        now.month,
        now.day - daysBack,
      );

      // Lấy Heart Rate data
      final hrData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startDate,
        endTime: now,
      );

      // Lấy SpO2 data
      final spo2Data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_OXYGEN],
        startTime: startDate,
        endTime: now,
      );

      _log('HealthSync: Got ${hrData.length} HR records, ${spo2Data.length} SpO2 records');

      // Kết hợp dữ liệu theo timestamp (ghép HR và SpO2 gần nhau)
      final results = <HealthConnectSpo2Result>[];

      // Tạo map SpO2 theo giờ để merge
      final spo2Map = <String, int>{};
      for (final point in spo2Data) {
        final key = _hourKey(point.dateFrom);
        final value = (point.value as NumericHealthValue).numericValue;
        // SpO2 từ Health Connect có thể ở dạng 0-1 hoặc 0-100
        int spo2Value = value.toInt();
        if (spo2Value <= 1) {
          spo2Value = (value * 100).toInt();
        }
        if (spo2Value >= 70 && spo2Value <= 100) {
          spo2Map[key] = spo2Value;
        }
      }

      // Process Heart Rate records
      final processedHours = <String>{};
      for (final point in hrData) {
        final key = _hourKey(point.dateFrom);
        if (processedHours.contains(key)) continue;
        processedHours.add(key);

        final hrValue = (point.value as NumericHealthValue).numericValue.toInt();
        if (hrValue < 30 || hrValue > 250) continue;

        results.add(HealthConnectSpo2Result(
          heartRate: hrValue,
          spo2: spo2Map[key],
          timestamp: point.dateFrom,
        ));
      }

      // Process SpO2 records that don't have matching HR
      for (final point in spo2Data) {
        final key = _hourKey(point.dateFrom);
        if (processedHours.contains(key)) continue;
        processedHours.add(key);

        final value = (point.value as NumericHealthValue).numericValue;
        int spo2Value = value.toInt();
        if (spo2Value <= 1) {
          spo2Value = (value * 100).toInt();
        }
        if (spo2Value < 70 || spo2Value > 100) continue;

        results.add(HealthConnectSpo2Result(
          spo2: spo2Value,
          heartRate: null,
          timestamp: point.dateFrom,
        ));
      }

      // Sắp xếp theo thời gian
      results.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      _log('HealthSync: Merged into ${results.length} SpO2/HR results');
      return results;
    } catch (e) {
      _log('HealthSync Exception getting SpO2/HR: $e');
      return [];
    }
  }

  /// Lấy dữ liệu SpO2 & Heart Rate mới nhất từ Health Connect
  Future<HealthConnectSpo2Result?> getLatestSpo2HeartRate() async {
    try {
      final results = await getSpo2HeartRateData(daysBack: 1);
      if (results.isEmpty) return null;
      return results.last;
    } catch (e) {
      _log('HealthSync Exception getting latest SpO2/HR: $e');
      return null;
    }
  }

  /// Kiểm tra Health Connect có sẵn trên thiết bị không
  Future<bool> isHealthConnectAvailable() async {
    try {
      if (!Platform.isAndroid) return false;
      configure();
      // Thử request — nếu Health Connect không cài, sẽ throw
      await _health.getHealthConnectSdkStatus();
      return true;
    } catch (e) {
      _log('HealthSync: Health Connect not available: $e');
      return false;
    }
  }

  /// Helper: tạo key theo giờ để gom nhóm dữ liệu
  String _hourKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}_${dt.hour.toString().padLeft(2, '0')}';
  }
}
