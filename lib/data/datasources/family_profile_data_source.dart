import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/family_profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqlite_api.dart';

abstract class FamilyProfileDataSource {
  Future<List<FamilyProfileModel>> getAllProfiles();
  Future<void> addProfile(FamilyProfileModel profile);
  Future<void> updateProfile(FamilyProfileModel profile);
  Future<void> deleteProfile(int id);
  Future<void> setActiveProfile(int id);
  Future<FamilyProfileModel?> getActiveProfile();
}

class FamilyProfileDataSourceImpl implements FamilyProfileDataSource {
  final dbHelper = DbHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const tables = "family_profile";

  CollectionReference<Map<String, dynamic>>? get _familyProfileCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('family_profile');
  }

  String _cloudDocId(int localId) => 'fp_$localId';

  DateTime? _parseCloudDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  Future<void> _syncUpsertToCloud(FamilyProfileModel record) async {
    final collection = _familyProfileCollection;
    if (collection == null || record.id == null) return;

    final docId = _cloudDocId(record.id!);

    await collection.doc(docId).set({
      'localId': record.id,
      'name': record.name,
      'relationship': record.relationship,
      'dateOfBirth': record.dateOfBirth?.toUtc().millisecondsSinceEpoch,
      'gender': record.gender,
      'bloodType': record.bloodType,
      'height': record.height,
      'weight': record.weight,
      'avatar': record.avatar,
      'isActive': record.isActive == true,
      'createdAt': record.createdAt.toUtc().millisecondsSinceEpoch,
      'updatedAt': FieldValue.serverTimestamp(),
      'deleted': false,
    }, SetOptions(merge: true));
  }

  Future<void> _syncDeleteFromCloud(int localId) async {
    final collection = _familyProfileCollection;
    if (collection == null) return;
    final docId = _cloudDocId(localId);

    await collection.doc(docId).set({
      'localId': localId,
      'deleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncDownFromCloud(Database db) async {
    final collection = _familyProfileCollection;
    if (collection == null) return;

    final snap = await collection.get();
    final batch = db.batch();

    for (final doc in snap.docs) {
      final data = doc.data();

      final deleted = data['deleted'] == true;
      final localIdRaw = data['localId'];
      final localId = (localIdRaw is int)
          ? localIdRaw
          : int.tryParse('${localIdRaw ?? ''}');
      if (localId == null) continue;

      if (deleted) {
        batch.delete(
          tables,
          where: 'id = ?',
          whereArgs: [localId],
        );
        continue;
      }

      final createdAt =
          _parseCloudDate(data['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      final dateOfBirth = _parseCloudDate(data['dateOfBirth']);

      final map = <String, dynamic>{
        'id': localId,
        'name': data['name'] ?? '',
        'relationship': data['relationship'] ?? 'other',
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': data['gender'],
        'bloodType': data['bloodType'],
        'height': (data['height'] as num?)?.toDouble(),
        'weight': (data['weight'] as num?)?.toDouble(),
        'avatar': data['avatar'],
        'isActive': (data['isActive'] == true) ? 1 : 0,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

      batch.insert(
        tables,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<List<FamilyProfileModel>> getAllProfiles() async {
    final db = await dbHelper.database;

    try {
      await _syncDownFromCloud(db);
    } catch (_) {}

    final result = await db.query('family_profile', orderBy: 'createdAt ASC');
    return result.map((e) => FamilyProfileModel.fromMap(e)).toList();
  }

  @override
  Future<void> addProfile(FamilyProfileModel profile) async {
    final db = await dbHelper.database;
    final id = await db.insert('family_profile', profile.toMap());

    try {
      // ensure cloud gets the same local id so other devices can reconstruct
      await _syncUpsertToCloud(
        FamilyProfileModel(
          id: id,
          name: profile.name,
          relationship: profile.relationship,
          dateOfBirth: profile.dateOfBirth,
          gender: profile.gender,
          bloodType: profile.bloodType,
          height: profile.height,
          weight: profile.weight,
          avatar: profile.avatar,
          isActive: profile.isActive,
          createdAt: profile.createdAt,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> updateProfile(FamilyProfileModel profile) async {
    final db = await dbHelper.database;
    await db.update(
      'family_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );

    try {
      await _syncUpsertToCloud(profile);
    } catch (_) {}
  }

  @override
  Future<void> deleteProfile(int id) async {
    final db = await dbHelper.database;
    await db.delete('family_profile', where: 'id = ?', whereArgs: [id]);

    try {
      await _syncDeleteFromCloud(id);
    } catch (_) {}
  }

  @override
  Future<void> setActiveProfile(int id) async {
    final db = await dbHelper.database;
    await db.update('family_profile', {'isActive': 0});
    await db.update(
      'family_profile',
      {'isActive': 1},
      where: 'id = ?',
      whereArgs: [id],
    );

    try {
      final all = await db.query(tables, orderBy: 'createdAt ASC');
      for (final row in all) {
        await _syncUpsertToCloud(FamilyProfileModel.fromMap(row));
      }
    } catch (_) {}
  }

  @override
  Future<FamilyProfileModel?> getActiveProfile() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'family_profile',
      where: 'isActive = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return FamilyProfileModel.fromMap(result.first);
  }
}
