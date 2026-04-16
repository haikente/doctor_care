import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/menstrual_cycle_model.dart';
import 'package:doctor_care/domain/entities/menstrual_cycle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
 
abstract class MenstrualCycleDataSource {
  Future<List<MenstrualCycleModel>> getAll();
  Future<void> insert(MenstrualCycle cycle);
  Future<void> update(MenstrualCycle cycle);
  Future<void> delete(int id);
}
 
class MenstrualCycleDataSourceImpl implements MenstrualCycleDataSource {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  static const _tableName = 'menstrual_cycle';
 
  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('menstrual_cycle');
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
 
  /// Chuẩn hóa DateTime về UTC ISO8601 để đảm bảo nhất quán giữa local và cloud.
  String _stableDateKey(DateTime dt) {
    final ms = dt.toUtc().millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();
  }
 
  String _docId({required int profileId, required DateTime startDate}) {
    final ts = startDate.toUtc().millisecondsSinceEpoch;
    return 'p${profileId}_t$ts';
  }
 
  Future<void> _syncUpsertToCloud(MenstrualCycleModel record) async {
    final col = _collection;
    if (col == null || record.profileId == null) return;
 
    final docId = _docId(
      profileId: record.profileId!,
      startDate: record.startDate,
    );
    await col.doc(docId).set({
      if (record.id != null) 'localId': record.id,
      'startDate': record.startDate.toUtc().millisecondsSinceEpoch,
      'endDate': record.endDate?.toUtc().millisecondsSinceEpoch,
      'cycleLength': record.cycleLength,
      'periodLength': record.periodLength,
      'symptoms': record.symptoms,
      'note': record.note,
      'profileId': record.profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
 
  Future<void> _syncDeleteFromCloud({
    required int profileId,
    required DateTime startDate,
  }) async {
    final col = _collection;
    if (col == null) return;
    final docId = _docId(profileId: profileId, startDate: startDate);
    await col.doc(docId).delete();
  }
 
  DateTime? _parseCloudDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
 
  int? _tryParseDocIdMillis(String docId) {
    final idx = docId.lastIndexOf('_t');
    if (idx < 0) return null;
    return int.tryParse(docId.substring(idx + 2));
  }
 
  /// Tạo UNIQUE index trên (profileId, startDate) nếu chưa có.
  /// Gọi một lần khi khởi tạo hoặc trong DbHelper migration.
  Future<void> _ensureUniqueIndex(Database db) async {
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_mc_profile_start '
      'ON $_tableName(profileId, startDate)',
    );
  }
 
  /// Xóa các bản ghi trùng cũ (giữ lại id nhỏ nhất) trước khi tạo index.
  Future<void> _deduplicateExisting(Database db) async {
    await db.execute('''
      DELETE FROM $_tableName
      WHERE id NOT IN (
        SELECT MIN(id) FROM $_tableName
        GROUP BY profileId, startDate
      )
    ''');
  }
 
  Future<void> _syncDownFromCloud(Database db) async {
    final col = _collection;
    if (col == null) return;
 
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final snap = await col.orderBy('startDate', descending: false).get();
    final batch = db.batch();
 
    for (final doc in snap.docs) {
      final data = doc.data();
 
      final profileIdRaw = data['profileId'];
      final profileId = (profileIdRaw is int)
          ? profileIdRaw
          : (int.tryParse('${profileIdRaw ?? ''}') ?? activeProfileId);
      if (profileId == null) continue;
 
      DateTime? startDate;
      final docMillis = _tryParseDocIdMillis(doc.id);
      if (docMillis != null) {
        startDate = DateTime.fromMillisecondsSinceEpoch(docMillis, isUtc: true);
      } else {
        startDate = _parseCloudDate(data['startDate']);
      }
      if (startDate == null) continue;
 
      final endDate = _parseCloudDate(data['endDate']);
 
      final symptomsRaw = data['symptoms'];
      String symptomsJson = '[]';
      if (symptomsRaw is List) {
        symptomsJson = '[${symptomsRaw.map((e) => '"$e"').join(',')}]';
      } else if (symptomsRaw is String && symptomsRaw.trim().isNotEmpty) {
        symptomsJson = symptomsRaw;
      }
 
      final map = <String, dynamic>{
        // FIX: dùng _stableDateKey (UTC ISO) để khớp với format khi insert local
        'startDate': _stableDateKey(startDate),
        'endDate': endDate != null ? _stableDateKey(endDate) : null,
        'cycleLength': data['cycleLength'],
        'periodLength': data['periodLength'] ?? 5,
        'symptoms': symptomsJson,
        'note': data['note'],
        'profileId': profileId,
      };
 
      // FIX: ConflictAlgorithm.replace hoạt động đúng khi có UNIQUE index
      batch.insert(
        _tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
 
  @override
  Future<List<MenstrualCycleModel>> getAll() async {
    final db = await dbHelper.database;
 
    // FIX: Đảm bảo UNIQUE index tồn tại để tránh duplicate khi sync
    await _deduplicateExisting(db);
    await _ensureUniqueIndex(db);
 
    try {
      await _syncDownFromCloud(db);
    } catch (_) {}
 
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final result = await db.query(
      _tableName,
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'startDate DESC',
    );
    return result.map((e) => MenstrualCycleModel.fromMap(e)).toList();
  }
 
  @override
  Future<void> insert(MenstrualCycle cycle) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
 
    // FIX: Chuẩn hóa startDate về UTC ISO để khớp với format khi sync down
    final normalizedStartDate = _stableDateKey(cycle.startDate);
 
    final model = MenstrualCycleModel.fromEntity(
      cycle,
      profileId: activeProfileId,
    );
 
    final id = await db.insert(
      _tableName,
      {
        ...model.toMap(),
        'startDate': normalizedStartDate,
        if (activeProfileId != null) 'profileId': activeProfileId,
      },
      // FIX: Dùng replace thay vì insert thuần để tránh duplicate nếu gọi lại
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
 
    try {
      await _syncUpsertToCloud(
        MenstrualCycleModel.fromEntity(
          cycle.copyWith(id: id),
          profileId: activeProfileId,
        ),
      );
    } catch (_) {}
  }
 
  @override
  Future<void> update(MenstrualCycle cycle) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
 
    // FIX: Chuẩn hóa startDate khi update để giữ nhất quán
    final normalizedStartDate = _stableDateKey(cycle.startDate);
 
    final model = MenstrualCycleModel.fromEntity(
      cycle,
      profileId: activeProfileId,
    );
 
    await db.update(
      _tableName,
      {
        ...model.toMap(),
        'startDate': normalizedStartDate,
        if (activeProfileId != null) 'profileId': activeProfileId,
      },
      where: 'id = ?',
      whereArgs: [cycle.id],
    );
 
    try {
      await _syncUpsertToCloud(
        MenstrualCycleModel.fromEntity(cycle, profileId: activeProfileId),
      );
    } catch (_) {}
  }
 
  @override
  Future<void> delete(int id) async {
    final db = await dbHelper.database;
 
    final rows = await db.query(
      _tableName,
      columns: ['profileId', 'startDate'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
 
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
 
    if (rows.isEmpty) return;
    final profileId = rows.first['profileId'] as int?;
    final startRaw = rows.first['startDate'];
    DateTime? startDate;
    if (startRaw is String) startDate = DateTime.tryParse(startRaw);
    if (profileId == null || startDate == null) return;
 
    try {
      await _syncDeleteFromCloud(profileId: profileId, startDate: startDate);
    } catch (_) {}
  }
}