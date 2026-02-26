import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/family_profile_model.dart';

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

  @override
  Future<List<FamilyProfileModel>> getAllProfiles() async {
    final db = await dbHelper.database;
    final result = await db.query('family_profile', orderBy: 'createdAt ASC');
    return result.map((e) => FamilyProfileModel.fromMap(e)).toList();
  }

  @override
  Future<void> addProfile(FamilyProfileModel profile) async {
    final db = await dbHelper.database;
    await db.insert('family_profile', profile.toMap());
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
  }

  @override
  Future<void> deleteProfile(int id) async {
    final db = await dbHelper.database;
    await db.delete('family_profile', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> setActiveProfile(int id) async {
    final db = await dbHelper.database;
    // Đặt tất cả thành inactive
    await db.update('family_profile', {'isActive': 0});
    // Đặt profile được chọn thành active
    await db.update(
      'family_profile',
      {'isActive': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
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
