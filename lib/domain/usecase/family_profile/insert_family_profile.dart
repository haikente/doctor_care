import 'package:doctor_care/domain/entities/family_profile.dart';
import 'package:doctor_care/domain/repositories/family_profile_repository.dart';

class InsertFamilyProfile {
  final FamilyProfileRepository repository;

  InsertFamilyProfile(this.repository);

  Future<void> call(FamilyProfile profile) async {
    await repository.addProfile(profile);
  }
}
