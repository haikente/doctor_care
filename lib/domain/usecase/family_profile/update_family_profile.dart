import 'package:doctor_care/domain/entities/family_profile.dart';
import 'package:doctor_care/domain/repositories/family_profile_repository.dart';

class UpdateFamilyProfile {
  final FamilyProfileRepository repository;

  UpdateFamilyProfile(this.repository);

  Future<void> call(FamilyProfile profile) async {
    await repository.updateProfile(profile);
  }
}
