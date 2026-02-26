import 'package:doctor_care/domain/entities/family_profile.dart';
import 'package:doctor_care/domain/repositories/family_profile_repository.dart';

class GetActiveFamilyProfile {
  final FamilyProfileRepository repository;

  GetActiveFamilyProfile(this.repository);

  Future<FamilyProfile?> call() async {
    return await repository.getActiveProfile();
  }
}
