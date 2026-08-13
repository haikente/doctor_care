import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/blood_pressure_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

abstract class BloodPressureDataSources {
  Future<void> addBloodPressure(BloodPressureModel bp);
  Future<void> updateBloodPressure(BloodPressureModel bp);
  Future<List<BloodPressureModel>> getAllBloodPressures();
  Future<void> deleteBloodPressure(int id);
}

class BloodPressureDataSourcesImpl implements BloodPressureDataSources {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _bloodPressureCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('blood_pressure');
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

  String _cloudeDocId({required int profileId, required DateTime timestamp}) {
    final ts = timestamp.toUtc().millisecondsSinceEpoch;
    return 'p${profileId}_t$ts';
  }

  Future<void> _syncUpsertToCloud(BloodPressureModel record) async {
    final collection = _bloodPressureCollection;
    if (collection == null || record.id == null) return;

    final profileId = record.profileId;
    if (profileId == null) return;

    final docId = _cloudeDocId(
      profileId: profileId,
      timestamp: record.timestamp,
    );
    await collection.doc(docId).set({
      'localId': record.id,
      'timestamp': record.timestamp.toIso8601String(),
      'systolic': record.systolic,
      'diastolic': record.diastolic,
      'source': record.source,
      'profileId': record.profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDeleteFromCloud({
    required int profileId,
    required DateTime timestamp,
  }) async {
    final collection = _bloodPressureCollection;
    if (collection == null) return;

    final docId = _cloudeDocId(profileId: profileId, timestamp: timestamp);
    await collection.doc(docId).delete();
  }

  Future<void> _syncDownFromCloud(Database db) async {
    final collection = _bloodPressureCollection;
    if (collection == null) return;

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final cloudSnapshot = await collection
        .orderBy('timestamp', descending: false)
        .get();

    final batch = db.batch();

    for (final doc in cloudSnapshot.docs) {
      final data = doc.data();
      final timestampRaw = data['timestamp'];
      if (timestampRaw is! String) continue;

      final profileIdRaw = data['profileId'];
      final profileId = (profileIdRaw is int)
          ? profileIdRaw
          : (int.tryParse('${profileIdRaw ?? ''}') ?? activeProfileId);

      final map = <String, dynamic>{
        'timestamp': timestampRaw,
        'profileId': profileId,
        'systolic': data['systolic'],
        'diastolic': data['diastolic'],
        'source': data['source'] ?? 'manual',
      };

      batch.insert(
        'blood_pressure',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteBloodPressure(int id) async {
    final db = await dbHelper.database;

    final rows = await db.query(
      'blood_pressure',
      columns: ['profileId', 'timestamp'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    await db.delete('blood_pressure', where: 'id = ?', whereArgs: [id]);

    if (rows.isEmpty) return;
    final profileId = rows.first['profileId'] as int?;
    final timestampRaw = rows.first['timestamp'];

    DateTime? timestamp;
    if (timestampRaw is String) {
      timestamp = DateTime.tryParse(timestampRaw);
    }

    if (profileId == null || timestamp == null) return;

    try {
      await _syncDeleteFromCloud(profileId: profileId, timestamp: timestamp);
    } catch (_) {}
  }

  @override
  Future<void> addBloodPressure(BloodPressureModel bp) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);

    final id = await db.insert('blood_pressure', {
      ...bp.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    });

    try {
      await _syncUpsertToCloud(
        BloodPressureModel(
          id: id,
          profileId: activeProfileId,
          timestamp: bp.timestamp,
          systolic: bp.systolic,
          diastolic: bp.diastolic,
          source: bp.source,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<List<BloodPressureModel>> getAllBloodPressures() async {
    final db = await dbHelper.database;
    try {
      await _syncDownFromCloud(db);
    } catch (_) {}

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final result = await db.query(
      'blood_pressure',
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => BloodPressureModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateBloodPressure(BloodPressureModel bp) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final payload = {
      ...bp.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };

    await db.update(
      'blood_pressure',
      payload,
      where: 'id = ?',
      whereArgs: [bp.id],
    );

    try {
      await _syncUpsertToCloud(
        BloodPressureModel(
          id: bp.id,
          systolic: bp.systolic,
          diastolic: bp.diastolic,
          profileId: activeProfileId,
          timestamp: bp.timestamp,
          source: bp.source,
        ),
      );
    } catch (_) {}
  }
}
