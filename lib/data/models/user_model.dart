import 'package:doctor_care/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.role,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map,
    String uid,
    String email,
  ) {
    return UserModel(
      uid: uid,
      email: email,
      role: map['role'] ?? 'patient', // Không có role mặc định là 'patient'
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'role': role};
  }
}
