import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model đại diện cho cấu hình hệ thống toàn cục
class SystemConfig {
  final String appName;
  final bool maintenanceMode;
  final String minAppVersion;
  final int defaultStepGoal;
  final int defaultWaterGoal;
  final String announcement;
  final bool announcementEnabled;
  final int dataRetentionDays;
  final DateTime? lastUpdated;
  final String? updatedBy;

  const SystemConfig({
    this.appName = 'DrCare',
    this.maintenanceMode = false,
    this.minAppVersion = '1.0.0',
    this.defaultStepGoal = 10000,
    this.defaultWaterGoal = 2000,
    this.announcement = '',
    this.announcementEnabled = false,
    this.dataRetentionDays = 365,
    this.lastUpdated,
    this.updatedBy,
  });

  static int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  static bool _readBool(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = '$value'.toLowerCase().trim();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return fallback;
  }

  factory SystemConfig.fromMap(Map<String, dynamic> map) {
    return SystemConfig(
      appName: map['appName'] ?? 'DrCare',
      maintenanceMode: _readBool(map['maintenanceMode'], false),
      minAppVersion: map['minAppVersion'] ?? '1.0.0',
      defaultStepGoal: _readInt(map['defaultStepGoal'], 10000),
      defaultWaterGoal: _readInt(map['defaultWaterGoal'], 2000),
      announcement: map['announcement'] ?? '',
      announcementEnabled: _readBool(map['announcementEnabled'], false),
      dataRetentionDays: _readInt(map['dataRetentionDays'], 365),
      lastUpdated: map['lastUpdated'] is Timestamp
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
      updatedBy: map['updatedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'maintenanceMode': maintenanceMode,
      'minAppVersion': minAppVersion,
      'defaultStepGoal': defaultStepGoal,
      'defaultWaterGoal': defaultWaterGoal,
      'announcement': announcement,
      'announcementEnabled': announcementEnabled,
      'dataRetentionDays': dataRetentionDays,
      'lastUpdated': FieldValue.serverTimestamp(),
      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
    };
  }

  SystemConfig copyWith({
    String? appName,
    bool? maintenanceMode,
    String? minAppVersion,
    int? defaultStepGoal,
    int? defaultWaterGoal,
    String? announcement,
    bool? announcementEnabled,
    int? dataRetentionDays,
    DateTime? lastUpdated,
    String? updatedBy,
  }) {
    return SystemConfig(
      appName: appName ?? this.appName,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      defaultStepGoal: defaultStepGoal ?? this.defaultStepGoal,
      defaultWaterGoal: defaultWaterGoal ?? this.defaultWaterGoal,
      announcement: announcement ?? this.announcement,
      announcementEnabled: announcementEnabled ?? this.announcementEnabled,
      dataRetentionDays: dataRetentionDays ?? this.dataRetentionDays,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// Service quản lý cấu hình hệ thống trên Firestore
class SystemConfigService {
  static final SystemConfigService _instance = SystemConfigService._internal();
  factory SystemConfigService() => _instance;
  SystemConfigService._internal();

  static const String _collection = 'system_config';
  static const String _document = 'global';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy stream cấu hình real-time
  Stream<SystemConfig> get configStream {
    return _firestore.collection(_collection).doc(_document).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) {
        return const SystemConfig();
      }
      return SystemConfig.fromMap(snapshot.data()!);
    });
  }

  /// Lấy cấu hình một lần
  Future<SystemConfig> getConfig() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_document).get();
      if (!doc.exists || doc.data() == null) {
        return const SystemConfig();
      }
      return SystemConfig.fromMap(doc.data()!);
    } catch (e) {
      print('❌ Error fetching system config: $e');
      return const SystemConfig();
    }
  }

  /// Cập nhật toàn bộ cấu hình
  Future<void> updateConfig(SystemConfig config) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(_document)
          .set(config.toMap(), SetOptions(merge: true));
      print('✅ System config updated');
    } catch (e) {
      print('❌ Error updating system config: $e');
      throw Exception('Không thể cập nhật cấu hình: $e');
    }
  }

  /// Cập nhật một trường cụ thể
  Future<void> updateField(String field, dynamic value) async {
    try {
      await _firestore.collection(_collection).doc(_document).set({
        field: value,
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.uid,
      }, SetOptions(merge: true));
      print('✅ Updated field $field = $value');
    } catch (e) {
      print('❌ Error updating field $field: $e');
      throw Exception('Không thể cập nhật $field: $e');
    }
  }

  /// Bật/tắt chế độ bảo trì
  Future<void> setMaintenanceMode(bool enabled) async {
    await updateField('maintenanceMode', enabled);
  }

  /// Cập nhật thông báo hệ thống
  Future<void> setAnnouncement(String text, bool enabled) async {
    await _firestore.collection(_collection).doc(_document).set({
      'announcement': text,
      'announcementEnabled': enabled,
      'lastUpdated': FieldValue.serverTimestamp(),
      'updatedBy': FirebaseAuth.instance.currentUser?.uid,
    }, SetOptions(merge: true));
  }

  /// Khởi tạo config mặc định nếu chưa tồn tại
  Future<void> initializeDefaultConfig() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_document).get();
      if (!doc.exists) {
        final defaultConfig = const SystemConfig().toMap();
        await _firestore
            .collection(_collection)
            .doc(_document)
            .set(defaultConfig);
        print('✅ Default system config initialized');
      }
    } catch (e) {
      print('❌ Error initializing system config: $e');
    }
  }
}
