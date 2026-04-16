import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/cholesterol_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

abstract class CholesterolDataSource {
  Future<void> addCholesterol(CholesterolModel record);
  Future<void> updateCholesterol(CholesterolModel record);
  Future<List<CholesterolModel>> getAllCholesterols();
  Future<void> deleteCholesterol(int id);
}

class CholesterolDataSourceImpl implements CholesterolDataSource {
  final dbHelper = DbHelper.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _cholesterolCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('cholesterol');
  }

  String _docIdFromLocalId(int localId) => 'cholesterol_$localId';

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

  Future<void> _syncUpsertToCloud(CholesterolModel record) async {
    final collection = _cholesterolCollection;
    if (collection == null || record.id == null) return;

    await collection.doc(_docIdFromLocalId(record.id!)).set({
      'id': record.id,
      'totalCholesterol': record.totalCholesterol,
      'profileId': record.profileId,
      'hdl': record.hdl,
      'ldl': record.ldl,
      'triglycerides': record.triglycerides,
      'timestamp': record.timestamp.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDeleteFromCloud(int localId) async {
    final collection = _cholesterolCollection;
    if (collection == null) return;
    await collection.doc(_docIdFromLocalId(localId)).delete();
  }

  @override
  Future<void> addCholesterol(CholesterolModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final id = await db.insert('cholesterol', {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    });
    try {
      await _syncUpsertToCloud(
        CholesterolModel(
          id: id,
          totalCholesterol: record.totalCholesterol,
          hdl: record.hdl,
          ldl: record.ldl,
          triglycerides: record.triglycerides,
          timestamp: record.timestamp,
          profileId: activeProfileId,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteCholesterol(int id) async {
    final db = await dbHelper.database;
    await db.delete('cholesterol', where: 'id = ?', whereArgs: [id]);
    try {
      await _syncDeleteFromCloud(id);
    } catch (_) {}
  }

  @override
  Future<List<CholesterolModel>> getAllCholesterols() async {
    final db = await dbHelper.database;
    try {
      await _syncDownFromCloud(db);
    } catch (_) {}

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final result = await db.query(
      'cholesterol',
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => CholesterolModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateCholesterol(CholesterolModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final payload = {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };
    await db.update(
      'cholesterol',
      payload,
      where: 'id = ?',
      whereArgs: [record.id],
    );
    try {
      await _syncUpsertToCloud(
        CholesterolModel(
          id: record.id,
          timestamp: record.timestamp,
          totalCholesterol: record.totalCholesterol,
          hdl: record.hdl,
          ldl: record.ldl,
          triglycerides: record.triglycerides,
          profileId: activeProfileId ?? record.profileId,
        ),
      );
    } catch (_) {}
  }

  Future<void> _syncDownFromCloud(Database db) async {
    final collection = _cholesterolCollection;
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

      if (profileId == null) continue;

      final payload = <String, dynamic>{
        'totalCholesterol': data['totalCholesterol'],
        'profileId': profileId,
        'hdl': data['hdl'],
        'ldl': data['ldl'],
        'triglycerides': data['triglycerides'],
        'timestamp': timestampRaw,
      };

      batch.update(
        'cholesterol',
        payload,
        where: 'profileId = ? AND timestamp = ?',
        whereArgs: [profileId, timestampRaw],
      );

      batch.insert(
        'cholesterol',
        payload,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }
}
