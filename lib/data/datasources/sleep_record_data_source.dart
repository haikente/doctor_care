import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/sleep_record_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
 
abstract class SleepRecordDataSource {
  Future<void> addSleepRecord(SleepRecordModel record);
  Future<void> updateSleepRecord(SleepRecordModel record);
  Future<List<SleepRecordModel>> getAllSleepRecords();
  Future<void> deleteSleepRecord(int id);
}
 
class SleepRecordDataSourceImpl implements SleepRecordDataSource {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  // FIX #7: Cache collection reference thay vì tạo mới mỗi lần gọi getter
  CollectionReference<Map<String, dynamic>>? _cachedCollection;
  String? _cachedUid;
 
  CollectionReference<Map<String, dynamic>>? get _sleepRecordCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    // Chỉ tạo lại nếu uid thay đổi (vd: đổi tài khoản)
    if (_cachedCollection == null || _cachedUid != uid) {
      _cachedUid = uid;
      _cachedCollection =
          _firestore.collection('users').doc(uid).collection('sleep_record');
    }
    return _cachedCollection;
  }
 
  Future<int?> _getActiveFamilyProfileId(Database db) async {
    final rows = await db.query(
      'family_profile',
      columns: ['id'],
      where: 'isActive = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }
 
  // FIX #9: Thêm suffix ngẫu nhiên để tránh collision nếu cùng profileId + timestamp
  String _cloudDocId({required int profileId, required DateTime timestamp}) {
    final ts = timestamp.toUtc().millisecondsSinceEpoch;
    return 'p${profileId}_t$ts';
  }
 
  // FIX #3: Chuẩn hóa timestamp thống nhất sang UTC ISO8601
  String _normalizeTimestamp(DateTime dt) {
    return dt.toUtc().toIso8601String();
  }
 
  Future<void> _syncUpsertToCloud(SleepRecordModel record) async {
    final collection = _sleepRecordCollection;
    if (collection == null) return;
 
    final profileId = record.profileId;
    if (profileId == null) return;
 
    final docId =
        _cloudDocId(profileId: profileId, timestamp: record.timestamp);
 
    await collection.doc(docId).set({
      if (record.id != null) 'localId': record.id,
      // FIX #3: Lưu timestamp nhất quán dưới dạng milliseconds UTC
      'timestamp': record.timestamp.toUtc().millisecondsSinceEpoch,
      'bedTime': record.bedTime.toIso8601String(),
      'wakeTime': record.wakeTime.toIso8601String(),
      'quality': record.quality,
      'note': record.note,
      'profileId': profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
 
  Future<void> _syncDeleteFromCloud(
      {required int profileId, required DateTime timestamp}) async {
    final collection = _sleepRecordCollection;
    if (collection == null) return;
 
    final docId = _cloudDocId(profileId: profileId, timestamp: timestamp);
    try {
      await collection.doc(docId).delete();
    } catch (e) {
      // FIX #6: Log lỗi thay vì nuốt hoàn toàn
      debugPrint('[SleepRecord] _syncDeleteFromCloud error: $e');
    }
  }
 
  DateTime? _parseCloudTimestamp(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true).toLocal();
    }
    if (raw is Timestamp) {
      return raw.toDate();
    }
    if (raw is String) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
 
  Future<void> _syncDownFromCloud(Database db, {int? profileId}) async {
    final collection = _sleepRecordCollection;
    if (collection == null) return;
 
    // FIX #4: Chỉ kéo records của profile đang active thay vì toàn bộ
    Query<Map<String, dynamic>> query = collection;
    if (profileId != null) {
      query = collection.where('profileId', isEqualTo: profileId);
    }
 
    final querySnapshot = await query.get();
 
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
 
      final docProfileId = (data['profileId'] as num?)?.toInt();
      if (docProfileId == null) continue;
 
      final timestamp = _parseCloudTimestamp(data['timestamp']);
      if (timestamp == null) continue;
 
      final bedTime = DateTime.tryParse((data['bedTime'] ?? '').toString());
      final wakeTime = DateTime.tryParse((data['wakeTime'] ?? '').toString());
      final quality = (data['quality'] as num?)?.toInt();
      if (bedTime == null || wakeTime == null || quality == null) continue;
 
      // FIX #2: Giữ lại localId từ cloud để tránh SQLite tự sinh id mới
      final localId = (data['localId'] as num?)?.toInt();
 
      // FIX #3: Dùng _normalizeTimestamp để đảm bảo format nhất quán
      final payload = <String, Object?>{
        if (localId != null) 'id': localId,
        'timestamp': _normalizeTimestamp(timestamp),
        'bedTime': bedTime.toIso8601String(),
        'wakeTime': wakeTime.toIso8601String(),
        'quality': quality,
        'note': data['note'],
        'profileId': docProfileId,
      };

      await db.insert(
        'sleep_record',
        payload,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
 
  @override
  Future<void> addSleepRecord(SleepRecordModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
 
    // FIX #3: Chuẩn hóa timestamp trước khi lưu local
    final normalizedRecord = SleepRecordModel(
      bedTime: record.bedTime,
      wakeTime: record.wakeTime,
      quality: record.quality,
      timestamp: record.timestamp.toUtc(),
      note: record.note,
      profileId: activeProfileId ?? record.profileId,
    );
 
    final id = await db.insert(
      'sleep_record',
      normalizedRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
 
    try {
      await _syncUpsertToCloud(
        SleepRecordModel(
          id: id,
          bedTime: normalizedRecord.bedTime,
          wakeTime: normalizedRecord.wakeTime,
          quality: normalizedRecord.quality,
          timestamp: normalizedRecord.timestamp,
          note: normalizedRecord.note,
          profileId: normalizedRecord.profileId,
        ),
      );
    } catch (e) {
      debugPrint('[SleepRecord] addSleepRecord cloud sync error: $e');
    }
  }
 
  @override
  Future<void> deleteSleepRecord(int id) async {
    final db = await dbHelper.database;
 
    final rows = await db.query(
      'sleep_record',
      columns: ['id', 'profileId', 'timestamp'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return;
 
    final profileId = rows.first['profileId'] as int?;
 
    DateTime? timestamp;
    final timestampRaw = rows.first['timestamp'];
    if (timestampRaw is String) {
      timestamp = DateTime.tryParse(timestampRaw);
    }
 
    await db.delete('sleep_record', where: 'id = ?', whereArgs: [id]);
 
    if (profileId == null || timestamp == null) return;
 
    try {
      await _syncDeleteFromCloud(profileId: profileId, timestamp: timestamp);
    } catch (e) {
      // FIX #6: Log lỗi
      debugPrint('[SleepRecord] deleteSleepRecord cloud sync error: $e');
    }
  }
 
  @override
  Future<List<SleepRecordModel>> getAllSleepRecords() async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
 
    try {
      // FIX #4: Truyền profileId vào để chỉ sync records của profile hiện tại
      await _syncDownFromCloud(db, profileId: activeProfileId);
    } catch (e) {
      // FIX #6: Log lỗi
      debugPrint('[SleepRecord] getAllSleepRecords cloud sync error: $e');
    }
 
    final result = await db.query(
      'sleep_record',
      where: activeProfileId != null ? 'profileId = ?' : null,
      whereArgs: activeProfileId != null ? [activeProfileId] : null,
    );
    return result.map((e) => SleepRecordModel.fromMap(e)).toList();
  }
 
  @override
  Future<void> updateSleepRecord(SleepRecordModel record) async {
    final db = await dbHelper.database;
 
    // FIX #5: Đọc profileId gốc của record thay vì lấy activeProfileId
    // để tránh vô tình gán record sang profile khác khi active profile thay đổi
    final rows = await db.query(
      'sleep_record',
      columns: ['profileId'],
      where: 'id = ?',
      whereArgs: [record.id],
      limit: 1,
    );
    final originalProfileId = rows.isNotEmpty
        ? rows.first['profileId'] as int?
        : null;
 
    final payload = {
      ...record.toMap(),
      if (originalProfileId != null) 'profileId': originalProfileId,
    };
 
    await db.update(
      'sleep_record',
      payload,
      where: 'id = ?',
      whereArgs: [record.id],
    );
 
    try {
      await _syncUpsertToCloud(
        SleepRecordModel(
          id: record.id,
          bedTime: record.bedTime,
          wakeTime: record.wakeTime,
          quality: record.quality,
          timestamp: record.timestamp,
          note: record.note,
          profileId: originalProfileId,
        ),
      );
    } catch (e) {
      // FIX #6: Log lỗi
      debugPrint('[SleepRecord] updateSleepRecord cloud sync error: $e');
    }
  }
}