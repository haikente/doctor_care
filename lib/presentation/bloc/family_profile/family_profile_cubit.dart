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

  bool _selfEnsured = false;

  Future<void> loadProfiles() async {
    emit(FamilyProfileLoading());
    try {
      // Dọn dẹp hồ sơ "self" trùng lặp (chỉ giữ bản đầu tiên)
      var profiles = await getFamilyProfiles();
      final selfProfiles = profiles.where((p) => p.relationship == 'self').toList();
      if (selfProfiles.length > 1) {
        for (int i = 1; i < selfProfiles.length; i++) {
          await deleteFamilyProfile(selfProfiles[i].id!);
        }
        profiles = await getFamilyProfiles();
      }

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

  /// Tự động tạo hồ sơ "Bản thân" từ thông tin tài khoản nếu chưa có
  Future<void> ensureSelfProfile({
    required String name,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
    DateTime? dateOfBirth,
  }) async {
    if (_selfEnsured) return; // Chỉ chạy 1 lần
    _selfEnsured = true;

    try {
      final profiles = await getFamilyProfiles();
      final selfProfiles = profiles.where((p) => p.relationship == 'self').toList();

      // Xoá các bản ghi "self" trùng lặp, chỉ giữ 1
      if (selfProfiles.length > 1) {
        for (int i = 1; i < selfProfiles.length; i++) {
          await deleteFamilyProfile(selfProfiles[i].id!);
        }
        await loadProfiles();
        return;
      }

      if (selfProfiles.isEmpty) {
        final selfProfile = FamilyProfile(
          name: name.isNotEmpty ? name : 'Chủ tài khoản',
          relationship: 'self',
          gender: gender,
          bloodType: bloodType,
          height: height,
          weight: weight,
          dateOfBirth: dateOfBirth,
          isActive: true,
        );
        await insertFamilyProfile(selfProfile);
        // Lấy lại danh sách, tìm profile self vừa tạo và set active
        final updatedProfiles = await getFamilyProfiles();
        final selfCreated = updatedProfiles.where((p) => p.relationship == 'self').firstOrNull;
        if (selfCreated != null && selfCreated.id != null) {
          await setActiveFamilyProfile(selfCreated.id!);
        }
        // Reload để cập nhật UI
        await loadProfiles();
      }
    } catch (e) {
      // Không emit error — không ảnh hưởng flow chính
    }
  }
}
