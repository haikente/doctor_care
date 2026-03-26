import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/blood_sugar_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

abstract class BloodSugarDataSource {
  Future<void> addBloodSugar(BloodSugarModel record);
  Future<void> updateBloodSugar(BloodSugarModel record);
  Future<List<BloodSugarModel>> getAllBloodSugars();
  Future<void> deleteBloodSugar(int id);
}

class BloodSugarDataSourceImpl implements BloodSugarDataSource {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _bloodSugarCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('blood_sugar');
  }

  String _docIdFromLocalId(int localId) => 'bloodsugar_$localId';

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

  Future<void> _syncUpsertToCloud(BloodSugarModel record) async {
    final collection = _bloodSugarCollection;
    if (collection == null || record.id == null) return;

    await collection.doc(_docIdFromLocalId(record.id!)).set({
      'id': record.id,
      'timestamp': record.timestamp.toIso8601String(),
      'value': record.value,
      'mealStatus': record.mealStatus,
      'profileId': record.profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDeleteFromCloud(int localId) async {
    final collection = _bloodSugarCollection;
    if (collection == null) return;
    await collection.doc(_docIdFromLocalId(localId)).delete();
  }

  Future<void> _hydrateLocalFromCloudIfEmpty(Database db) async {
    final collection = _bloodSugarCollection;
    if (collection == null) return;

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final localCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM blood_sugar'),
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
        'value': data['value'],
        'mealStatus': data['mealStatus'],
        'profileId': data['profileId'] ?? activeProfileId,
      };
      await db.insert('blood_sugar', map);
    }
  }

  @override
  Future<void> addBloodSugar(BloodSugarModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final id = await db.insert('blood_sugar', {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    });
    try {
      await _syncUpsertToCloud(
        BloodSugarModel(
          id: id,
          value: record.value,
          mealStatus: record.mealStatus,
          timestamp: record.timestamp,
          profileId: activeProfileId,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteBloodSugar(int id) async {
    final db = await dbHelper.database;
    await db.delete('blood_sugar', where: 'id = ?', whereArgs: [id]);
    try {
      await _syncDeleteFromCloud(id);
    } catch (_) {}
  }

  @override
  Future<List<BloodSugarModel>> getAllBloodSugars() async {
    final db = await dbHelper.database;
    try {
      await _hydrateLocalFromCloudIfEmpty(db);
    } catch (_) {}

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final result = await db.query(
      'blood_sugar',
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => BloodSugarModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateBloodSugar(BloodSugarModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final payload = {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };
    await db.update(
      'blood_sugar',
      payload,
      where: 'id = ?',
      whereArgs: [record.id],
    );
    try {
      await _syncUpsertToCloud(
        BloodSugarModel(
          id: record.id,
          value: record.value,
          mealStatus: record.mealStatus,
          timestamp: record.timestamp,
          profileId: activeProfileId ?? record.profileId,
        ),
      );
    } catch (_) {}
  }
}
