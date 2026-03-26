import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/spO2heartratemodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

abstract class Spo2heartrateDataSource {
  Future<List<Spo2heartratemodel>> getAllSpo2heartrate();
  Future<void> addSpo2heartrate(Spo2heartratemodel spO2heartrate);
  Future<void> updateSpo2heartrate(Spo2heartratemodel spO2heartrate);
  Future<void> deleteSpo2heartrate(String id);
}

class Spo2heartrateDataSourceImpl implements Spo2heartrateDataSource {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _spo2heartrateCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('spo2heartrate');
  }

  String _docIdFromLocalId(int localId) => 'spo2heartrate_$localId';

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

  Future<void> _syncUpsertToCloud(Spo2heartratemodel record) async {
    final collection = _spo2heartrateCollection;
    if (collection == null || record.id == null) return;

    await collection.doc(_docIdFromLocalId(record.id!)).set({
      'id': record.id,
      'timestamp': record.timestamp.toIso8601String(),
      'spo2': record.spo2,
      'heartRate': record.heartRate,
      'profileId': record.profileId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDeleteFromCloud(int localId) async {
    final collection = _spo2heartrateCollection;
    if (collection == null) return;
    await collection.doc(_docIdFromLocalId(localId)).delete();
  }

  @override
  Future<void> addSpo2heartrate(Spo2heartratemodel spO2heartrate) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final id = await db.insert('spo2heartrate', {
      ...spO2heartrate.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    });
    try {
      await _syncUpsertToCloud(
        Spo2heartratemodel(
          id: id,
          timestamp: spO2heartrate.timestamp,
          spo2: spO2heartrate.spo2,
          heartRate: spO2heartrate.heartRate,
          profileId: activeProfileId,
        ),
      );
    } catch (_) {}
  }

  Future<void> _hydrateLocalFromCloudIfEmpty(Database db) async {
    final collection = _spo2heartrateCollection;
    if (collection == null) return;

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final localCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM spo2heartrate'),
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
        'spo2': data['spo2'],
        'heartRate': data['heartRate'],
        'profileId': data['profileId'] ?? activeProfileId,
      };
      await db.insert('spo2heartrate', map);
    }
  }

  @override
  Future<void> deleteSpo2heartrate(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'spo2heartrate',
      where: 'id = ?',
      whereArgs: [int.parse(id)],
    );
    try {
      await _syncDeleteFromCloud(int.parse(id));
    } catch (_) {}
  }

  @override
  Future<List<Spo2heartratemodel>> getAllSpo2heartrate() async {
    final db = await dbHelper.database;
    try {
      await _hydrateLocalFromCloudIfEmpty(db);
    } catch (_) {}

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final result = await db.query(
      'spo2heartrate',
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => Spo2heartratemodel.fromMap(e)).toList();
  }

  @override
  Future<void> updateSpo2heartrate(Spo2heartratemodel spO2heartrate) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final payload = {
      ...spO2heartrate.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };
    await db.update(
      'spo2heartrate',
      payload,
      where: 'id = ?',
      whereArgs: [spO2heartrate.id],
    );
    try {
      await _syncUpsertToCloud(
        Spo2heartratemodel(
          id: spO2heartrate.id,
          timestamp: spO2heartrate.timestamp,
          spo2: spO2heartrate.spo2,
          heartRate: spO2heartrate.heartRate,
          profileId: activeProfileId ?? spO2heartrate.profileId,
        ),
      );
    } catch (_) {}
  }
}
