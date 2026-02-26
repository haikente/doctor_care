import 'package:flutter/material.dart';

class FamilyProfile {
  final int? id;
  final String name;
  final String relationship; // 'self', 'spouse', 'child', 'parent', 'sibling', 'other'
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other'
  final String? bloodType;
  final double? height; // cm
  final double? weight; // kg
  final String? avatar; // initials or emoji
  final bool isActive; // currently selected profile
  final DateTime createdAt;

  FamilyProfile({
    this.id,
    required this.name,
    required this.relationship,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.height,
    this.weight,
    this.avatar,
    this.isActive = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Tên mối quan hệ
  String get relationshipLabel {
    switch (relationship) {
      case 'self':
        return 'Bản thân';
      case 'spouse':
        return 'Vợ/Chồng';
      case 'child':
        return 'Con';
      case 'parent':
        return 'Bố/Mẹ';
      case 'sibling':
        return 'Anh/Chị/Em';
      case 'grandparent':
        return 'Ông/Bà';
      case 'other':
        return 'Khác';
      default:
        return 'Không xác định';
    }
  }

  /// Icon cho mối quan hệ
  IconData get relationshipIcon {
    switch (relationship) {
      case 'self':
        return Icons.person;
      case 'spouse':
        return Icons.favorite;
      case 'child':
        return Icons.child_care;
      case 'parent':
        return Icons.elderly;
      case 'sibling':
        return Icons.people;
      case 'grandparent':
        return Icons.elderly_woman;
      case 'other':
        return Icons.person_outline;
      default:
        return Icons.person;
    }
  }

  /// Màu cho mối quan hệ
  Color get relationshipColor {
    switch (relationship) {
      case 'self':
        return Colors.blue;
      case 'spouse':
        return Colors.pink;
      case 'child':
        return Colors.green;
      case 'parent':
        return Colors.orange;
      case 'sibling':
        return Colors.purple;
      case 'grandparent':
        return Colors.brown;
      case 'other':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// Tính tuổi
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

  /// Lấy chữ cái đầu
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return "${parts[parts.length - 2][0]}${parts.last[0]}".toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return "??";
  }

  /// Giới tính label
  String get genderLabel {
    switch (gender) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      case 'other':
        return 'Khác';
      default:
        return 'Chưa xác định';
    }
  }

  FamilyProfile copyWith({
    int? id,
    String? name,
    String? relationship,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
    String? avatar,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return FamilyProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
