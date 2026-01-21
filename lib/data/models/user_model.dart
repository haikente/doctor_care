import 'package:doctor_care/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.role,
    super.profilePhotoUrl,
    super.fullName,
    super.phoneNumber,
    super.dateOfBirth,
    super.gender,
    super.bloodType,
    super.height,
    super.weight,
    super.address,
    super.emergencyContact,
    super.emergencyPhone,
    super.allergies,
    super.chronicDiseases,
    super.medications,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map,
    String uid,
    String email,
  ) {
    return UserModel(
      uid: uid,
      email: email,
      role: map['role'] ?? 'patient',
      profilePhotoUrl: map['profilePhotoUrl'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.parse(map['dateOfBirth']) 
          : null,
      gender: map['gender'],
      bloodType: map['bloodType'],
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      address: map['address'],
      emergencyContact: map['emergencyContact'],
      emergencyPhone: map['emergencyPhone'],
      allergies: map['allergies'] != null 
          ? List<String>.from(map['allergies']) 
          : null,
      chronicDiseases: map['chronicDiseases'] != null
          ? List<String>.from(map['chronicDiseases'])
          : null,
      medications: map['medications'] != null
          ? List<String>.from(map['medications'])
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
      if (fullName != null) 'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (gender != null) 'gender': gender,
      if (bloodType != null) 'bloodType': bloodType,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (address != null) 'address': address,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (emergencyPhone != null) 'emergencyPhone': emergencyPhone,
      if (allergies != null) 'allergies': allergies,
      if (chronicDiseases != null) 'chronicDiseases': chronicDiseases,
      if (medications != null) 'medications': medications,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? role,
    String? profilePhotoUrl,
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    List<String>? allergies,
    List<String>? chronicDiseases,
    List<String>? medications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      medications: medications ?? this.medications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
