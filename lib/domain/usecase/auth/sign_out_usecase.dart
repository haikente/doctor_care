import 'package:dart_either/dart_either.dart';
import 'package:doctor_care/domain/failures/failures.dart';
import 'package:doctor_care/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}
