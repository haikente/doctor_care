import 'package:doctor_care/data/datasources/family_profile_data_source.dart';
import 'package:doctor_care/data/models/family_profile_model.dart';
import 'package:doctor_care/domain/entities/family_profile.dart';
import 'package:doctor_care/domain/repositories/family_profile_repository.dart';

class FamilyProfileRepositoryImpl implements FamilyProfileRepository {
  final FamilyProfileDataSource dataSource;

  FamilyProfileRepositoryImpl(this.dataSource);

  @override
  Future<List<FamilyProfile>> getAllProfiles() async {
    return await dataSource.getAllProfiles();
  }

  @override
  Future<void> addProfile(FamilyProfile profile) async {
    await dataSource.addProfile(
      FamilyProfileModel(
        id: profile.id,
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
  }

  @override
  Future<void> updateProfile(FamilyProfile profile) async {
    await dataSource.updateProfile(
      FamilyProfileModel(
        id: profile.id,
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
  }

  @override
  Future<void> deleteProfile(int id) async {
    await dataSource.deleteProfile(id);
  }

  @override
  Future<void> setActiveProfile(int id) async {
    await dataSource.setActiveProfile(id);
  }

  @override
  Future<FamilyProfile?> getActiveProfile() async {
    return await dataSource.getActiveProfile();
  }
}
