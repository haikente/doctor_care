import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/temperature_model.dart';
import 'package:doctor_care/domain/entities/temperature.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

abstract class TemperatureDataSource {
  Future<void> insertTemperature(TemperatureModel temperature);
  Future<void> updateTemperature(TemperatureModel temperature);
  Future<void> deleteTemperature(String id);
  Future<List<Temperature>> getAllTemperatures();
}

class TemperatureDataSourceImpl implements TemperatureDataSource {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _temperatureCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('temperature');
  }

  String _docIdFromLocalId(int localId) => 'temperature_$localId';

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

  Future<void> _syncUpsertToCloud(TemperatureModel temperature) async {
    final collection = _temperatureCollection;
    if (collection == null || temperature.id == null) return;

    await collection.doc(_docIdFromLocalId(temperature.id!)).set({
      'id': temperature.id,
      'timestamp': temperature.timestamp.toIso8601String(),
      'value': temperature.value,
      'profileId': temperature.profileId,
      'updateAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDeleteFromCloud(int localId) async {
    final collection = _temperatureCollection;
    if (collection == null) return;
    await collection.doc(_docIdFromLocalId(localId)).delete();
  }

  //cấp nguồn cục bộ từ đám mây
  Future<void> _hydrateLocalFromCloudIfEmpty(Database db) async {
    final collection = _temperatureCollection;
    if (collection == null) return;

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final localCount =
        Sqflite.firstIntValue(
          await db.rawQuery('Select count(*) from temperature'),
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
        'profileId': data['profileId'] ?? activeProfileId,
      };
      await db.insert('temperature', map);
    }
  }

  @override
  Future<void> insertTemperature(TemperatureModel temperature) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final id = await db.insert('temperature', {
      ...temperature.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    });
    try {
      await _syncUpsertToCloud(
        TemperatureModel(
          id: id,
          value: temperature.value,
          timestamp: temperature.timestamp,
          profileId: activeProfileId,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> updateTemperature(TemperatureModel temperature) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfileId(db);
    final payload = {
      ...temperature.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };
    await db.update(
      'temperature',
      payload,
      where: 'id = ?',
      whereArgs: [temperature.id],
    );
    try {
      await _syncUpsertToCloud(
        TemperatureModel(
          id: temperature.id,
          value: temperature.value,
          timestamp: temperature.timestamp,
          profileId: activeProfileId ?? temperature.profileId,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteTemperature(String id) async {
    final db = await dbHelper.database;
    await db.delete('temperature', where: 'id = ?', whereArgs: [int.parse(id)]);
    try {
      await _syncDeleteFromCloud(int.parse(id));
    } catch (_) {}
  }

  @override
  Future<List<TemperatureModel>> getAllTemperatures() async {
    final db = await dbHelper.database;
    try {
      await _hydrateLocalFromCloudIfEmpty(db);
    } catch (_) {}

    final activeProfileId = await _getActiveFamilyProfileId(db);
    final result = await db.query(
      'temperature',
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => TemperatureModel.fromMap(e)).toList();
  }
}
