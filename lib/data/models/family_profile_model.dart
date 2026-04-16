import 'package:doctor_care/domain/entities/family_profile.dart';

class FamilyProfileModel extends FamilyProfile {
  FamilyProfileModel({
    super.id,
    required super.name,
    required super.relationship,
    super.dateOfBirth,
    super.gender,
    super.bloodType,
    super.height,
    super.weight,
    super.avatar,
    super.isActive,
    super.createdAt,
  });

  factory FamilyProfileModel.fromMap(Map<String, dynamic> map) {
    return FamilyProfileModel(
      id: map['id'],
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? 'other',
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
      gender: map['gender'],
      bloodType: map['bloodType'],
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      avatar: map['avatar'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'avatar': avatar,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
