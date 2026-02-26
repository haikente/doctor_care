import 'package:doctor_care/domain/repositories/family_profile_repository.dart';

class SetActiveFamilyProfile {
  final FamilyProfileRepository repository;

  SetActiveFamilyProfile(this.repository);

  Future<void> call(int id) async {
    await repository.setActiveProfile(id);
  }
}
