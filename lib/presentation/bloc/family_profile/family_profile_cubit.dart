import 'package:doctor_care/domain/entities/family_profile.dart';
import 'package:doctor_care/domain/usecase/family_profile/delete_family_profile.dart';
import 'package:doctor_care/domain/usecase/family_profile/get_active_family_profile.dart';
import 'package:doctor_care/domain/usecase/family_profile/get_family_profiles.dart';
import 'package:doctor_care/domain/usecase/family_profile/insert_family_profile.dart';
import 'package:doctor_care/domain/usecase/family_profile/set_active_family_profile.dart';
import 'package:doctor_care/domain/usecase/family_profile/update_family_profile.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'family_profile_state.dart';

class FamilyProfileCubit extends Cubit<FamilyProfileState> {
  final GetFamilyProfiles getFamilyProfiles;
  final InsertFamilyProfile insertFamilyProfile;
  final UpdateFamilyProfile updateFamilyProfile;
  final DeleteFamilyProfile deleteFamilyProfile;
  final SetActiveFamilyProfile setActiveFamilyProfile;
  final GetActiveFamilyProfile getActiveFamilyProfile;

  FamilyProfileCubit(
    this.getFamilyProfiles,
    this.insertFamilyProfile,
    this.updateFamilyProfile,
    this.deleteFamilyProfile,
    this.setActiveFamilyProfile,
    this.getActiveFamilyProfile,
  ) : super(FamilyProfileInitial());

  Future<void> loadProfiles() async {
    emit(FamilyProfileLoading());
    try {
      final profiles = await getFamilyProfiles();
      final active = await getActiveFamilyProfile();
      emit(FamilyProfileLoaded(profiles, activeProfile: active));
    } catch (e) {
      emit(FamilyProfileError('Không tải được danh sách hồ sơ'));
    }
  }

  Future<void> addProfile(FamilyProfile profile) async {
    emit(FamilyProfileLoading());
    try {
      await insertFamilyProfile(profile);
      final profiles = await getFamilyProfiles();
      // Nếu đây là hồ sơ đầu tiên, tự động set active
      if (profiles.length == 1) {
        await setActiveFamilyProfile(profiles.first.id!);
      }
      final active = await getActiveFamilyProfile();
      emit(FamilyProfileLoaded(await getFamilyProfiles(), activeProfile: active));
    } catch (e) {
      emit(FamilyProfileError('Không thể thêm hồ sơ'));
    }
  }

  Future<void> editProfile(FamilyProfile profile) async {
    emit(FamilyProfileLoading());
    try {
      await updateFamilyProfile(profile);
      final profiles = await getFamilyProfiles();
      final active = await getActiveFamilyProfile();
      emit(FamilyProfileLoaded(profiles, activeProfile: active));
    } catch (e) {
      emit(FamilyProfileError('Không thể cập nhật hồ sơ'));
    }
  }

  Future<void> removeProfile(int id) async {
    emit(FamilyProfileLoading());
    try {
      await deleteFamilyProfile(id);
      final profiles = await getFamilyProfiles();
      final active = await getActiveFamilyProfile();
      // Nếu xóa profile đang active, chọn cái đầu tiên
      if (active == null && profiles.isNotEmpty) {
        await setActiveFamilyProfile(profiles.first.id!);
        final newActive = await getActiveFamilyProfile();
        emit(FamilyProfileLoaded(await getFamilyProfiles(), activeProfile: newActive));
      } else {
        emit(FamilyProfileLoaded(profiles, activeProfile: active));
      }
    } catch (e) {
      emit(FamilyProfileError('Không thể xóa hồ sơ'));
    }
  }

  Future<void> switchProfile(int id) async {
    emit(FamilyProfileLoading());
    try {
      await setActiveFamilyProfile(id);
      final profiles = await getFamilyProfiles();
      final active = await getActiveFamilyProfile();
      emit(FamilyProfileLoaded(profiles, activeProfile: active));
    } catch (e) {
      emit(FamilyProfileError('Không thể chuyển hồ sơ'));
    }
  }
}
