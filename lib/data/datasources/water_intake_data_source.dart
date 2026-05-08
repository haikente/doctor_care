import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/water_intake_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

abstract class WaterIntakeDataSource {
  Future<List<WaterIntakeModel>> getAllWaterIntakeRecords();
  Future<void> insertWaterIntakeRecord(WaterIntakeModel record);
  Future<void> updateWaterIntakeRecord(WaterIntakeModel record);
  Future<void> deleteWaterIntakeRecord(String id);
}

class WaterIntakeDataSourceImpl implements WaterIntakeDataSource {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection("users").doc(uid).collection('water_intake');
  }

  String _docIdFromLocalId(int localId) => 'wi_$localId';

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

  Future<void> _syncUpsertToCloud(WaterIntakeModel record) async {
    final collection = _collection;
    if (collection == null || record.id == null) return;

    await collection.doc(_docIdFromLocalId(record.id!)).set({
      'id': record.id,
      'timestamp': record.timestamp.toIso8601String(),
      'amount': record.amount,
      'note': record.note,
      'profileId': record.profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDownFromCloud(Database db) async {
    final collection = _collection;
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
        if (data['id'] != null) 'id': data['id'],
        'timestamp': timestampRaw,
        'amount': data['amount'],
        'note': data['note'],
        'profileId': profileId,
      };

      batch.insert(
        'water_intake',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> _syncDeleteFromCloud(int localId) async {
    final collection = _collection;
    if (collection == null) return;
    await collection.doc(_docIdFromLocalId(localId)).delete();
  }

  @override
  Future<List<WaterIntakeModel>> getAllWaterIntakeRecords() async {
    final db = await dbHelper.database;
    try {
      await _syncDownFromCloud(db);
    } catch (_) {}

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final result = await db.query(
      'water_intake',
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'timestamp DESC',
    );
    return result.map((e) => WaterIntakeModel.fromMap(e)).toList();
  }

  @override
  Future<void> insertWaterIntakeRecord(WaterIntakeModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);

    final id = await db.insert('water_intake', {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    });

    try {
      await _syncUpsertToCloud(
        WaterIntakeModel(
          id: id,
          timestamp: record.timestamp,
          amount: record.amount,
          note: record.note,
          profileId: activeProfileId,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> updateWaterIntakeRecord(WaterIntakeModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);

    final payload = {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };

    await db.update(
      'water_intake',
      payload,
      where: 'id = ?',
      whereArgs: [record.id],
    );

    try {
      await _syncUpsertToCloud(
        WaterIntakeModel(
          id: record.id,
          timestamp: record.timestamp,
          amount: record.amount,
          note: record.note,
          profileId: activeProfileId ?? record.profileId,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteWaterIntakeRecord(String id) async {
    final db = await dbHelper.database;
    await db.delete('water_intake', where: 'id = ?', whereArgs: [id]);
    try {
      await _syncDeleteFromCloud(int.parse(id));
    } catch (_) {}
  }
}

