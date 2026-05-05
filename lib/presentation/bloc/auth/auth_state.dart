part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  final String role;

  const Authenticated(this.user, {this.role = 'user'});

  @override
  List<Object> get props => [user, role];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordResetSent extends AuthState {}

/// Bị đăng xuất vì tài khoản đã đăng nhập trên thiết bị khác.
class SessionConflict extends AuthState {}
