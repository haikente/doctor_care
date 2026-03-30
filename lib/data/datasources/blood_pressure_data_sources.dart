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

  String _docIdFromLocalId(int localId) => 'bp_$localId';

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

  Future<void> _syncUpsertToCloud(BloodPressureModel record) async {
    final collection = _bloodPressureCollection;
    if (collection == null || record.id == null) return;

    await collection.doc(_docIdFromLocalId(record.id!)).set({
      'localId': record.id,
      'timestamp': record.timestamp.toIso8601String(),
      'systolic': record.systolic,
      'diastolic': record.diastolic,
      'profileId': record.profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDeleteFromCloud(int localId) async {
    final collection = _bloodPressureCollection;
    if (collection == null) return;
    await collection.doc(_docIdFromLocalId(localId)).delete();
  }

  Future<void> _hydrateLocalFromCloudIfEmpty(Database db) async {
    final collection = _bloodPressureCollection;
    if (collection == null) return;

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final localCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM blood_pressure'),
        ) ??
        0;
    if (localCount > 0) return;

    final cloudSnapshot = await collection
        .orderBy('timestamp', descending: false)
        .get();

    for (final doc in cloudSnapshot.docs) {
      final data = doc.data();
      final timestampRaw = data['timestamp'];
      if (timestampRaw is! String) continue;

      final map = <String, dynamic>{
        'timestamp': timestampRaw,
        'systolic': data['systolic'],
        'diastolic': data['diastolic'],
        'profileId': data['profileId'] ?? activeProfileId,
      };
      await db.insert('blood_pressure', map);
    }
  }

  @override
  Future<void> deleteBloodPressure(int id) async {
    final db = await dbHelper.database;
    await db.delete('blood_pressure', where: 'id = ?', whereArgs: [id]);
    try {
      await _syncDeleteFromCloud(id);
    } catch (_) {
      // Keep local delete successful even if cloud sync fails.
    }
  }

  @override
  Future<List<BloodPressureModel>> getAllBloodPressures() async {
    final db = await dbHelper.database;
    try {
      await _hydrateLocalFromCloudIfEmpty(db);
    } catch (_) {
      // Keep app usable from local DB even if cloud read fails.
    }

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
          timestamp: bp.timestamp,
          systolic: bp.systolic,
          diastolic: bp.diastolic,
          profileId: activeProfileId ?? bp.profileId,
        ),
      );
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
          timestamp: bp.timestamp,
          systolic: bp.systolic,
          diastolic: bp.diastolic,
          profileId: activeProfileId,
        ),
      );
    } catch (_) {}
  }
}
