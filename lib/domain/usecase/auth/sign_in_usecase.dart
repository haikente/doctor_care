import 'package:dart_either/dart_either.dart';
import 'package:doctor_care/domain/failures/failures.dart';
import 'package:doctor_care/domain/entities/user_entity.dart';
import 'package:doctor_care/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String email,
    String password,
  ) async {
    return await repository.signIn(email, password);
  }
}
