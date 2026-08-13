import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/step_count_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

abstract class StepCountDataSource {
  Future<void> addStepCount(StepCountModel record);
  Future<void> updateStepCount(StepCountModel record);
  Future<List<StepCountModel>> getAllStepCounts();
  Future<void> deleteStepCount(int id);
}

class StepCountDataSourceImpl implements StepCountDataSource {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _stepCountCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('step_count');
  }

  Future<int?> _getActiveFamilyProfile(Database db) async {
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

  String _cloudDocId({required int profileId, required DateTime timestamp}) {
    final ts = timestamp.toUtc().millisecondsSinceEpoch;
    return 'p${profileId}_t$ts';
  }

  Future<void> _syncUpsertToCloud(StepCountModel record) async {
    final collection = _stepCountCollection;
    if (collection == null) return;

    final profileId = record.profileId;
    if (profileId == null) return;

    final docId = _cloudDocId(
      profileId: profileId,
      timestamp: record.timestamp,
    );
    await collection.doc(docId).set({
      'localId': record.id,
      'profileId': profileId,
      'steps': record.steps,
      'distance': record.distance,
      'caloriesBurned': record.caloriesBurned,
      'timestamp': record.timestamp.toIso8601String(),
      'note': record.note,
      'source': record.source.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDeleteFromCloud({
    required int profileId,
    required DateTime timestamp,
  }) async {
    final collection = _stepCountCollection;
    if (collection == null) return;

    final docId = _cloudDocId(profileId: profileId, timestamp: timestamp);
    await collection.doc(docId).delete();
  }

  Future<void> _syncDownFromCloud(Database db) async {
    final collection = _stepCountCollection;
    if (collection == null) return;

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
          : int.tryParse('${profileIdRaw ?? ''}');
      if (profileId == null) continue;

      final map = <String, dynamic>{
        'timestamp': timestampRaw,
        'profileId': profileId,
        'steps': data['steps'],
        'distance': data['distance'],
        'caloriesBurned': data['caloriesBurned'],
        'note': data['note'],
        'source': data['source'] ?? 'manual',
      };

      batch.insert(
        'step_count',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> addStepCount(StepCountModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfile(db);
    final payload = {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };

    int id;
    if (activeProfileId != null) {
      final existingRows = await db.query(
        'step_count',
        columns: ['id'],
        where: 'profileId = ? AND timestamp = ?',
        whereArgs: [activeProfileId, record.timestamp.toIso8601String()],
        limit: 1,
      );

      if (existingRows.isNotEmpty) {
        id = existingRows.first['id'] as int;
        final updatePayload = Map<String, dynamic>.from(payload)..remove('id');
        await db.update(
          'step_count',
          updatePayload,
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        id = await db.insert('step_count', payload);
      }
    } else {
      id = await db.insert('step_count', payload);
    }

    try {
      await _syncUpsertToCloud(
        StepCountModel(
          id: id,
          distance: record.distance,
          caloriesBurned: record.caloriesBurned,
          profileId: activeProfileId,
          steps: record.steps,
          timestamp: record.timestamp,
          note: record.note,
          source: record.source,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteStepCount(int id) async {
    final db = await dbHelper.database;

    final rows = await db.query(
      'step_count',
      columns: ['profileId', 'timestamp'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    await db.delete('step_count', where: 'id = ?', whereArgs: [id]);

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
  Future<List<StepCountModel>> getAllStepCounts() async {
    final db = await dbHelper.database;
    try {
      await _syncDownFromCloud(db);
    } catch (_) {}

    final activeProfileId = await _getActiveFamilyProfile(db);
    final result = await db.query(
      'step_count',
      where: activeProfileId == null ? null : 'profileId = ?',
      whereArgs: activeProfileId == null ? null : [activeProfileId],
      orderBy: 'timestamp ASC',
    );
    return result.map((e) => StepCountModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateStepCount(StepCountModel record) async {
    final db = await dbHelper.database;
    final activeProfileId = await _getActiveFamilyProfile(db);
    final payload = {
      ...record.toMap(),
      if (activeProfileId != null) 'profileId': activeProfileId,
    };

    await db.update(
      'step_count',
      payload,
      where: 'id = ?',
      whereArgs: [record.id],
    );

    try {
      await _syncUpsertToCloud(
        StepCountModel(
          id: record.id,
          distance: record.distance,
          caloriesBurned: record.caloriesBurned,
          profileId: activeProfileId,
          steps: record.steps,
          timestamp: record.timestamp,
          note: record.note,
          source: record.source,
        ),
      );
    } catch (_) {}
  }
}
