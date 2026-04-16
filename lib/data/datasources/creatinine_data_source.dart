import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/creatinine_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

// lớp trừu tượng để định nghĩa các phương thức cần thiết cho việc quản lý dữ liệu creatinine
abstract class CreatinineDataSource {
  Future<void> addCreatinine(CreatinineModel record);
  Future<void> updateCreatinine(CreatinineModel record);
  Future<List<CreatinineModel>> getAllCreatinines();
  Future<void> deleteCreatinine(int id);
}

// lớp triển khai các phương thức của CreatinineDataSource
class CreatinineDataSourceImpl implements CreatinineDataSource {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _creatinineCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('creatinine');
  }

  String _docIdFromLocalId(int localId) => 'creatinine_$localId';

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

  Future<void> _syncUpsertToCloud(CreatinineModel record) async {
    final collection = _creatinineCollection;
    if (collection == null || record.id == null) return;

    await collection.doc(_docIdFromLocalId(record.id!)).set({
      'id': record.id,
      'timestamp': record.timestamp.toIso8601String(),
      'value': record.value,
      'note': record.note,
      'age': record.age,
      'gender': record.gender,
      'profileId': record.profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDeleteFromCloud(int localId) async {
    final collection = _creatinineCollection;
    if (collection == null) return;
    await collection.doc(_docIdFromLocalId(localId)).delete();
  }

  Future<void> _syncDownFromCloud(Database db) async {
    final collection = _creatinineCollection;
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
        'value': data['value'],
        'note': data['note'],
        'age': data['age'],
        'gender': data['gender'],
        'profileId': profileId,
      };

      batch.insert(
        'creatinine',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> addCreatinine(CreatinineModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final id = await db.insert('creatinine', {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    });
    try {
      await _syncUpsertToCloud(
        CreatinineModel(
          id: id,
          value: record.value,
          timestamp: record.timestamp,
          note: record.note,
          age: record.age,
          gender: record.gender,
          profileId: activeProfileId,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteCreatinine(int id) async {
    final db = await dbHelper.database;
    await db.delete('creatinine', where: 'id = ?', whereArgs: [id]);
    try {
      await _syncDeleteFromCloud(id);
    } catch (_) {}
  }

  @override
  Future<List<CreatinineModel>> getAllCreatinines() async {
    final db = await dbHelper.database;
    try {
      await _syncDownFromCloud(db);
    } catch (_) {}

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final result = await db.query(
      'creatinine',
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => CreatinineModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateCreatinine(CreatinineModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final payload = {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };
    await db.update(
      'creatinine',
      payload,
      where: 'id = ?',
      whereArgs: [record.id],
    );
    try {
      await _syncUpsertToCloud(
        CreatinineModel(
          id: record.id,
          value: record.value,
          timestamp: record.timestamp,
          note: record.note,
          age: record.age,
          gender: record.gender,
          profileId: activeProfileId ?? record.profileId,
        ),
      );
    } catch (_) {}
  }
}
