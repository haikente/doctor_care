import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model đại diện cho một bản ghi audit
class AuditLog {
  final String id;
  final String action;
  final String description;
  final String adminUid;
  final String? adminEmail;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const AuditLog({
    this.id = '',
    required this.action,
    required this.description,
    required this.adminUid,
    this.adminEmail,
    required this.timestamp,
    this.details,
  });

  factory AuditLog.fromMap(String id, Map<String, dynamic> map) {
    return AuditLog(
      id: id,
      action: map['action'] ?? '',
      description: map['description'] ?? '',
      adminUid: map['adminUid'] ?? '',
      adminEmail: map['adminEmail'],
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      details: map['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'description': description,
      'adminUid': adminUid,
      'adminEmail': adminEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'details': details,
    };
  }
}

/// Service ghi log các hành động của admin
class AdminAuditService {
  static final AdminAuditService _instance = AdminAuditService._internal();
  factory AdminAuditService() => _instance;
  AdminAuditService._internal();

  static const String _collection = 'admin_logs';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ghi log một hành động
  Future<void> log({
    required String action,
    required String description,
    Map<String, dynamic>? details,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final log = AuditLog(
        action: action,
        description: description,
        adminUid: user.uid,
        adminEmail: user.email,
        timestamp: DateTime.now(),
        details: details,
      );

      await _firestore.collection(_collection).add(log.toMap());
      print('📝 Audit log: $action - $description');
    } catch (e) {
      print('❌ Error writing audit log: $e');
    }
  }

  /// Lấy stream logs real-time (50 bản ghi gần nhất)
  Stream<List<AuditLog>> get logsStream {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AuditLog.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// Lấy logs một lần (paginated)
  Future<List<AuditLog>> getLogs({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => AuditLog.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching audit logs: $e');
      return [];
    }
  }

  /// Xóa logs cũ hơn X ngày
  Future<int> deleteOldLogs(int days) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _firestore
          .collection(_collection)
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoff))
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('🗑️ Deleted ${snapshot.docs.length} old audit logs');
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error deleting old logs: $e');
      return 0;
    }
  }

  // === Helper methods cho các hành động phổ biến ===

  Future<void> logResetDatabase() async {
    await log(
      action: 'reset_database',
      description: 'Reset local SQLite database',
    );
  }

  Future<void> logCheckSchema() async {
    await log(action: 'check_schema', description: 'Checked database schema');
  }

  Future<void> logClearCache(String cacheType) async {
    await log(
      action: 'clear_cache',
      description: 'Cleared $cacheType cache',
      details: {'cacheType': cacheType},
    );
  }

  Future<void> logUpdateConfig(String field, dynamic value) async {
    await log(
      action: 'update_config',
      description: 'Updated system config: $field',
      details: {'field': field, 'value': value.toString()},
    );
  }

  Future<void> logDeleteUser(String userId, String email) async {
    await log(
      action: 'delete_user',
      description: 'Deleted user $email',
      details: {'userId': userId, 'email': email},
    );
  }

  Future<void> logEditUser(String userId, String email) async {
    await log(
      action: 'edit_user',
      description: 'Edited user $email',
      details: {'userId': userId, 'email': email},
    );
  }

  Future<void> logToggleUserStatus(
    String userId,
    String email,
    bool isActive,
  ) async {
    await log(
      action: 'toggle_user_status',
      description: '${isActive ? 'Activated' : 'Disabled'} user $email',
      details: {'userId': userId, 'email': email, 'isActive': isActive},
    );
  }

  Future<void> logUpdateUserAccess(
    String userId,
    String email,
    Map<String, bool> permissions,
  ) async {
    await log(
      action: 'update_user_access',
      description: 'Updated access permissions for $email',
      details: {'userId': userId, 'email': email, 'permissions': permissions},
    );
  }

  Future<void> logExportDatabase(String format) async {
    await log(
      action: 'export_database',
      description: 'Exported database to $format',
      details: {'format': format},
    );
  }

  Future<void> logClearOldData(int days) async {
    await log(
      action: 'clear_old_data',
      description: 'Cleared data older than $days days',
      details: {'days': days},
    );
  }
}
