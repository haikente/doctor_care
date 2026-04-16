import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/hba1c_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

abstract class Hba1cDataSources {
  Future<List<Hba1cModel>> getAllHba1c();
  Future<void> addHba1c(Hba1cModel hba1cModel);
  Future<void> updateHba1c(Hba1cModel hba1cModel);
  Future<void> deleteHba1c(int id);
}

class Hba1cDataSourcesImpl implements Hba1cDataSources {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _hba1cCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('hba1c');
  }

  String _docIdFromLocalId(int localId) => 'hba1c_$localId';

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

  Future<void> _syncUpsertToCloud(Hba1cModel record) async {
    final collection = _hba1cCollection;

    if (collection == null || record.id == null) return;

    await collection.doc(_docIdFromLocalId(record.id!)).set({
      'localId': record.id,
      'date': record.date.toIso8601String(),
      'value': record.value,
      'profileId': record.profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDeleteFromCloud(int localId) async {
    final collection = _hba1cCollection;
    if (collection == null) return;
    await collection.doc(_docIdFromLocalId(localId)).delete();
  }

  Future<void> _syncDownFromCloud(Database db) async {
    final collection = _hba1cCollection;
    if (collection == null) return;

    final activeProfileId = await _getActiveFamilyProfileId(db);

    final cloudSnapshot = await collection
        .orderBy('date', descending: false)
        .get();

    final batch = db.batch();

    for (final doc in cloudSnapshot.docs) {
      final data = doc.data();
      final dateRaw = data['date'];
      if (dateRaw is! String) continue;

      final profileIdRaw = data['profileId'];
      final profileId = (profileIdRaw is int)
          ? profileIdRaw
          : (int.tryParse('${profileIdRaw ?? ''}') ?? activeProfileId);

      final map = <String, dynamic>{
        'date': dateRaw,
        'value': data['value'],
        'profileId': profileId,
      };

      batch.insert(
        'hba1c',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> addHba1c(Hba1cModel hba1c) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final id = await db.insert('hba1c', {
      ...hba1c.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    });
    try {
      await _syncUpsertToCloud(
        Hba1cModel(
          id: id,
          value: hba1c.value,
          date: hba1c.date,
          profileId: activeProfileId,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<List<Hba1cModel>> getAllHba1c() async {
    final db = await dbHelper.database;
    try {
      await _syncDownFromCloud(db);
    } catch (_) {}

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final result = await db.query(
      'hba1c',
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'date ASC',
    );
    return result.map((e) => Hba1cModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateHba1c(Hba1cModel hba1c) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final payload = {
      ...hba1c.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };
    await db.update('hba1c', payload, where: 'id = ?', whereArgs: [hba1c.id]);
    try {
      await _syncUpsertToCloud(
        Hba1cModel(
          id: hba1c.id,
          value: hba1c.value,
          date: hba1c.date,
          profileId: activeProfileId ?? hba1c.profileId,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteHba1c(int id) async {
    final db = await dbHelper.database;
    await db.delete('hba1c', where: 'id = ?', whereArgs: [id]);
    try {
      await _syncDeleteFromCloud(id);
    } catch (_) {}
  }
}
