import 'package:flutter/material.dart';

class HbA1c {
  final int? id;
  final double value;
  final DateTime date;

  HbA1c({
    this.id,
    required this.value,
    required this.date,
  });


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
