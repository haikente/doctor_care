import 'package:equatable/equatable.dart';

abstract class Failures extends Equatable{
  final String message;

  const Failures(this.message);

  @override
  List<Object> get props => [message];
}

// lớp lỗi chung cho tất cả các loại lỗi
class NotificationFailure extends Failures {
  const NotificationFailure(super.message);
}

// lỗi liên quan đến máy chủ, API, hoặc các lỗi không mong muốn khác
class ServerFailure extends Failures {
  const ServerFailure([super.message = 'Lỗi máy chủ']);
}

// lỗi liên quan đến kết nối mạng
class CacheFailure extends Failures {
  const CacheFailure([super.message = 'Lỗi bộ nhớ đệm']);
}

// lỗi liên quan đến giao diện người dùng
class PresentationFailure extends Failures {
  const PresentationFailure([super.message = 'Lỗi giao diện người dùng']);
}