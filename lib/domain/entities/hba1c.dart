import 'package:flutter/material.dart';

class HbA1c {
  final int? id;
  final double value;
  final DateTime date;

  // Valid HbA1c range: 2-20%
  static const double minValidValue = 2.0;
  static const double maxValidValue = 20.0;

  HbA1c({
    this.id,
    required this.value,
    required this.date,
  });

  /// Validates if the HbA1c value is within the acceptable range (2-20%)
  bool get isValid => value >= minValidValue && value <= maxValidValue;

  /// Returns validation error message if invalid, null if valid
  String? get validationError {
    if (value < minValidValue) {
      return 'Giá trị HbA1c phải ít nhất là $minValidValue%';
    }
    if (value > maxValidValue) {
      return 'Giá trị HbA1c không được vượt quá $maxValidValue%';
    }
    return null;
  }


   //kiểm tra theo WHO
  String get getInterpretation {
    if (value < 5.7) {
      return "Bình thường";
    } else if (value >= 5.7 && value < 6.5) {
      return "Tiền đái tháo đường";
    } else {
      return "Đái tháo đường";
    }
  }

  Color get getColor {
    if (value < 5.7) {
      return Colors.green;
    } else if (value >= 5.7 && value < 6.5) {
      return Colors.orange.shade700;
    } else {
      return Colors.red;
    }
  }

  Color get getBackgroundColor {
    if (value < 5.7) {
      return Colors.green.shade50;
    } else if (value >= 5.7 && value < 6.5) {
      return Colors.orange.shade50;
    } else {
      return Colors.red.shade50;
    }
  }
}
