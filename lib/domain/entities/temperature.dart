import 'package:flutter/material.dart';

class Temperature {
   final int? id;
   final double value; 
   final DateTime timestamp;

  Temperature({
    this.id,
    required this.value,
    required this.timestamp,
  });

  //trạng thái nhiệt độ
  String get getStatus {
    if (value < 36.0) {
      return "Hạ nhiệt";
    } else if (value >= 36.0 && value <= 37.5) {
      return "Bình thường";
    } else if (value > 37.5 && value <= 38.5) {
      return "Sốt nhẹ";
    } else if (value > 38.5 && value <= 39.5) {
      return "Sốt vừa";
    } else {
      return "Sốt cao";
    }
  }

  Color get getColor {
    if (value < 36.0) {
      return Colors.blue;
    } else if (value >= 36.0 && value <= 37.5) {
      return Colors.green;
    } else if (value > 37.5 && value <= 38.5) {
      return Colors.orange;
    } else if (value > 38.5 && value <= 39.5) {
      return Colors.redAccent;
    } else {
      return Colors.red;
    }
  }

  Color get getBackgroundColor {
    if (value < 36.0) {
      return Colors.blue.shade50;
    } else if (value >= 36.0 && value <= 37.5) {
      return Colors.green.shade50;
    } else if (value > 37.5 && value <= 38.5) {
      return Colors.orange.shade50;
    } else if (value > 38.5 && value <= 39.5) {
      return Colors.red.shade50;
    } else {
      return Colors.red.shade100;
    }
  }

}