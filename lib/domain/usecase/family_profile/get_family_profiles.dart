import 'package:doctor_care/domain/entities/family_profile.dart';
import 'package:doctor_care/domain/repositories/family_profile_repository.dart';

class GetFamilyProfiles {
  final FamilyProfileRepository repository;

  GetFamilyProfiles(this.repository);

  Future<List<FamilyProfile>> call() async {
    return await repository.getAllProfiles();
  }
}
