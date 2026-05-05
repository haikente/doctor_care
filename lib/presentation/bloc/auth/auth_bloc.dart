import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/core/services/session_service.dart';
import 'package:doctor_care/domain/entities/user_entity.dart';
import 'package:doctor_care/domain/usecase/auth/check_auth_status_usecase.dart';
import 'package:doctor_care/domain/usecase/auth/sign_in_usecase.dart';
import 'package:doctor_care/domain/usecase/auth/sign_in_with_google_usecase.dart';
import 'package:doctor_care/domain/usecase/auth/sign_up_usecase.dart';
import 'package:doctor_care/domain/usecase/auth/sign_out_usecase.dart';
import 'package:doctor_care/domain/usecase/auth/reset_password_usecase.dart';
import 'package:doctor_care/core/services/role_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signInWithGoogleUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.checkAuthStatusUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<ResetPasswordEvent>(_onResetPassword);
    on<ForceSignOutEvent>(_onForceSignOut);
  }

  void _startSessionListener() {
    SessionService.instance.listenForSessionConflict(
      onConflict: () => add(ForceSignOutEvent()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await checkAuthStatusUseCase();
    await result.fold(
      ifLeft: (failure) async => emit(Unauthenticated()),
      ifRight: (user) async {
        await DbHelper.instance.setCurrentUser(user.uid);
        await SessionService.instance.restoreLocalToken();
        _startSessionListener();
        final role = await RoleService.getCurrentUserRole();
        emit(Authenticated(user, role: role));
      },
    );
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signInUseCase(event.email, event.password);
    await result.fold(
      ifLeft: (failure) async => emit(AuthError(failure.message)),
      ifRight: (user) async {
        await DbHelper.instance.setCurrentUser(user.uid);
        _startSessionListener();
        final role = await RoleService.getCurrentUserRole();
        emit(Authenticated(user, role: role));
      },
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    SessionService.instance.stopListening();
    await signOutUseCase();
    await DbHelper.instance.setCurrentUser(null);
    emit(Unauthenticated());
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signUpUseCase(
      event.fullName,
      event.email,
      event.password,
    );
    await result.fold(
      ifLeft: (failure) async => emit(AuthError(failure.message)),
      ifRight: (user) async {
        await DbHelper.instance.setCurrentUser(user.uid);
        final role = await RoleService.getCurrentUserRole();
        emit(Authenticated(user, role: role));
      },
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithGoogleUseCase();
    await result.fold(
      ifLeft: (failure) async => emit(AuthError(failure.message)),
      ifRight: (user) async {
        await DbHelper.instance.setCurrentUser(user.uid);
        _startSessionListener();
        final role = await RoleService.getCurrentUserRole();
        emit(Authenticated(user, role: role));
      },
    );
  }

  Future<void> _onForceSignOut(
    ForceSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    SessionService.instance.stopListening();
    await signOutUseCase();
    await DbHelper.instance.setCurrentUser(null);
    emit(SessionConflict());
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase(event.email);
    result.fold(
      ifLeft: (failure) => emit(AuthError(failure.message)),
      ifRight: (_) => emit(PasswordResetSent()),
    );
  }
}
