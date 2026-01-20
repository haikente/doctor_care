import 'package:dart_either/dart_either.dart';
import 'package:doctor_care/domain/failures/failures.dart';
import 'package:doctor_care/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.resetPassword(email);
  }
}
