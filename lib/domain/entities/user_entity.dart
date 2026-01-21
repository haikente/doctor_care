import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String role; // 'admin' or 'patient'
  
  // Profile photo
  final String? profilePhotoUrl;
  
  // Thông tin bệnh nhân
  final String? fullName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other'
  final String? bloodType; // 'A', 'B', 'AB', 'O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  final double? height; // cm
  final double? weight; // kg
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  
  // Medical history
  final List<String>? allergies;
  final List<String>? chronicDiseases;
  final List<String>? medications;
  
  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.role,
    this.profilePhotoUrl,
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.height,
    this.weight,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    this.allergies,
    this.chronicDiseases,
    this.medications,
    this.createdAt,
    this.updatedAt,
  });

  // Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Calculate BMI
  double? get bmi {
    if (height == null || weight == null || height! <= 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  // BMI status
  String? get bmiStatus {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    
    if (bmiValue < 18.5) return 'Thiếu cân';
    if (bmiValue < 25) return 'Bình thường';
    if (bmiValue < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        role,
        profilePhotoUrl,
        fullName,
        phoneNumber,
        dateOfBirth,
        gender,
        bloodType,
        height,
        weight,
        address,
        emergencyContact,
        emergencyPhone,
        allergies,
        chronicDiseases,
        medications,
        createdAt,
        updatedAt,
      ];
}
