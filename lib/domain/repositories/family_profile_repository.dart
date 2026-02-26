import 'package:doctor_care/domain/entities/family_profile.dart';

abstract class FamilyProfileRepository {
  Future<List<FamilyProfile>> getAllProfiles();
  Future<void> addProfile(FamilyProfile profile);
  Future<void> updateProfile(FamilyProfile profile);
  Future<void> deleteProfile(int id);
  Future<void> setActiveProfile(int id);
  Future<FamilyProfile?> getActiveProfile();
}
