part of 'family_profile_cubit.dart';

abstract class FamilyProfileState extends Equatable {
  const FamilyProfileState();

  @override
  List<Object?> get props => [];
}

class FamilyProfileInitial extends FamilyProfileState {}

class FamilyProfileLoading extends FamilyProfileState {}

class FamilyProfileLoaded extends FamilyProfileState {
  final List<FamilyProfile> profiles;
  final FamilyProfile? activeProfile;

  const FamilyProfileLoaded(this.profiles, {this.activeProfile});

  @override
  List<Object?> get props => [profiles, activeProfile];
}

class FamilyProfileError extends FamilyProfileState {
  final String message;

  const FamilyProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
