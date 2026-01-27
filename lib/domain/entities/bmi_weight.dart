import 'dart:math';
import 'package:flutter/material.dart';

class BMIWeight {
  final int? id;
  final double weight; // kg
  final double height; // cm
  final DateTime timestamp; 
  final String? note;

  BMIWeight({
    this.id,
    required this.weight,
    required this.height,
    required this.timestamp,
    this.note,
  });

// Tính chỉ số BMI
  double get bmi {
    if (height <= 0) return 0;
    double heightInMeters = height / 100;
    return weight / pow(heightInMeters, 2);
  }

  String get bmiStatus {
    double value = bmi;
    if (value < 18.5) {
      return "Thiếu cân";
    } else if (value >= 18.5 && value < 24.9) {
      return "Bình thường";
    } else if (value >= 25 && value < 29.9) {
      return "Thừa cân";
    } else if (value >= 30 && value < 34.9) {
      return "Béo phì độ I";
    } else if (value >= 35 && value < 39.9) {
      return "Béo phì độ II";
    } else {
      return "Béo phì độ III";
    }
  }

  Color get bmiColor {
    double value = bmi;
    if (value < 18.5) {
      return Colors.blue;
    } else if (value >= 18.5 && value < 24.9) {
      return Colors.green;
    } else if (value >= 25 && value < 29.9) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color get bmiBackgroundColor {
    double value = bmi;
    if (value < 18.5) {
      return Colors.blue.shade50;
    } else if (value >= 18.5 && value < 24.9) {
      return Colors.green.shade50;
    } else if (value >= 25 && value < 29.9) {
      return Colors.orange.shade50;
    } else {
      return Colors.red.shade50;
    }
  }

  IconData get bmiIcon {
    double value = bmi;
    if (value < 18.5) {
      return Icons.info_outline;
    } else if (value >= 18.5 && value < 24.9) {
      return Icons.check_circle_outline;
    } else if (value >= 25 && value < 29.9) {
      return Icons.warning_amber_outlined;
    } else {
      return Icons.dangerous_outlined;
    }
  }
}
