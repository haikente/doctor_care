import 'package:doctor_care/domain/repositories/hba1c_repository.dart';

class DeleteHba1c {
  final Hba1cRepository repository;

  DeleteHba1c(this.repository);

  Future<void> call(String id) async {
    await repository.deleteHba1c(id);
  }
}
