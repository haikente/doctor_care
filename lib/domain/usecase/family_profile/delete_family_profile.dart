import 'package:doctor_care/domain/repositories/family_profile_repository.dart';

class DeleteFamilyProfile {
  final FamilyProfileRepository repository;

  DeleteFamilyProfile(this.repository);

  Future<void> call(int id) async {
    await repository.deleteProfile(id);
  }
}
