import 'package:dart_either/dart_either.dart';
import 'package:doctor_care/domain/failures/failures.dart';
import 'package:doctor_care/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signUp(
    String fullName,
    String email,
    String password,
  );
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, String>> getUserRole(String uid);
  Future<Either<Failure, void>> resetPassword(String email);
}
