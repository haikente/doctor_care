import 'package:dart_either/dart_either.dart';
import 'package:doctor_care/domain/failures/failures.dart';
import 'package:doctor_care/domain/entities/user_entity.dart';
import 'package:doctor_care/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getCurrentUser();
  }
}
