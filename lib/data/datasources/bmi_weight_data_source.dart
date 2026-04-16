import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/bmi_weight_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

abstract class BMIWeightDataSource {
  Future<List<BMIWeightModel>> getAllBMIWeightRecords();
  Future<void> addBMIWeightRecord(BMIWeightModel record);
  Future<void> updateBMIWeightRecord(BMIWeightModel record);
  Future<void> deleteBMIWeightRecord(String id);
}

class BMIWeightDataSourceImpl implements BMIWeightDataSource {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _bmiweightCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection("users").doc(uid).collection('bmi_weight');
  }

  String _docIdFromLocalId(int localId) => 'bmiw_$localId';

  Future<int?> _getActiveFamilyProfileId(Database db) async {
    final rows = await db.query(
      'family_profile',
      columns: ['id'],
      where: 'isActive = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int;
  }

  Future<void> _syncUpsertToCloud(BMIWeightModel record) async {
    final collection = _bmiweightCollection;
    if (collection == null || record.id == null) return;

    await collection.doc(_docIdFromLocalId(record.id!)).set({
      'id': record.id,
      'timestamp': record.timestamp.toIso8601String(),
      'weight': record.weight,
      'height': record.height,
      'profileId': record.profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDownFromCloud(Database db) async {
    final collection = _bmiweightCollection;
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
        'weight': data['weight'],
        'height': data['height'],
        'profileId': profileId,
      };

      batch.insert(
        'bmi_weight',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> _syncDeleteFromCloud(int localId) async {
    final collection = _bmiweightCollection;
    if (collection == null) return;
    await collection.doc(_docIdFromLocalId(localId)).delete();
  }

  @override
  Future<List<BMIWeightModel>> getAllBMIWeightRecords() async {
    final db = await dbHelper.database;
    try {
      await _syncDownFromCloud(db);
    } catch (_) {}
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final result = await db.query(
      "bmi_weight",
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => BMIWeightModel.fromMap((e))).toList();
  }

  @override
  Future<void> addBMIWeightRecord(BMIWeightModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final id = await db.insert('bmi_weight', {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    });
    try {
      await _syncUpsertToCloud(
        BMIWeightModel(
          id: id,
          timestamp: record.timestamp,
          height: record.height,
          weight: record.weight,
          profileId: activeProfileId,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteBMIWeightRecord(String id) async {
    final db = await dbHelper.database;
    await db.delete('bmi_weight', where: 'id = ?', whereArgs: [id]);
    try {
      await _syncDeleteFromCloud(int.parse(id));
    } catch (_) {}
  }

  @override
  Future<void> updateBMIWeightRecord(BMIWeightModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final payload = {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };
    await db.update(
      'bmi_weight',
      payload,
      where: 'id = ?',
      whereArgs: [record.id],
    );
    try {
      await _syncUpsertToCloud(
        BMIWeightModel(
          id: record.id,
          timestamp: record.timestamp,
          height: record.height,
          weight: record.weight,
          profileId: activeProfileId ?? record.profileId,
        ),
      );
    } catch (_) {}
  }
}
