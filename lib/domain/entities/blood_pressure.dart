import 'package:flutter/material.dart';

class BloodPressure {
  final int? id;
  final DateTime timestamp;
  final int systolic;    // Huyết áp tâm thu (mmHg)
  final int diastolic;   // Huyết áp tâm trương (mmHg)

  BloodPressure({
    this.id,
    required this.timestamp, 
    required this.systolic,
    required this.diastolic,
  });

  /// Phân loại huyết áp theo chuẩn WHO/ESC 2023
  String get bloodPressureLevel {
    // Huyết áp thấp (Hypotension)
    if (systolic < 90 && diastolic < 60) {
      return 'Huyết áp thấp';
    }
    
    // Bình thường (Normal)
    if (systolic < 120 && diastolic < 80) {
      return 'Bình thường';
    }
    
    // Bình thường cao (Elevated)
    if (systolic >= 120 && systolic < 130 && diastolic < 80) {
      return 'Bình thường cao';
    }
    
    // Tăng huyết áp độ 1 (Hypertension Stage 1)
    if ((systolic >= 130 && systolic < 140) || (diastolic >= 80 && diastolic < 90)) {
      return 'Tăng huyết áp độ 1';
    }
    
    // Tăng huyết áp độ 2 (Hypertension Stage 2)
    if ((systolic >= 140 && systolic < 180) || (diastolic >= 90 && diastolic < 120)) {
      return 'Tăng huyết áp độ 2';
    }
    
    // Tăng huyết áp độ 3 (Hypertensive Crisis)
    return 'Tăng huyết áp độ 3';
  }

  /// Màu chữ cho từng mức huyết áp
  Color get bloodPressureColor {
    // Huyết áp thấp
    if (systolic < 90 && diastolic < 60) {
      return Colors.blue;
    }
    
    // Bình thường
    if (systolic < 120 && diastolic < 80) {
      return Colors.green;
    }
    
    // Bình thường cao
    if (systolic >= 120 && systolic < 130 && diastolic < 80) {
      return Colors.yellow.shade700;
    }
    
    // Tăng huyết áp độ 1
    if ((systolic >= 130 && systolic < 140) || (diastolic >= 80 && diastolic < 90)) {
      return Colors.orange;
    }
    
    // Tăng huyết áp độ 2
    if ((systolic >= 140 && systolic < 180) || (diastolic >= 90 && diastolic < 120)) {
      return Colors.red.shade400;
    }
    
    // Tăng huyết áp độ 3
    return Colors.red.shade900;
  }

  /// Màu nền cho từng mức huyết áp
  Color get bloodbkColor {
    // Huyết áp thấp
    if (systolic < 90 && diastolic < 60) {
      return Colors.blue.shade50;
    }
    
    // Bình thường
    if (systolic < 120 && diastolic < 80) {
      return Colors.green.shade50;
    }
    
    // Bình thường cao
    if (systolic >= 120 && systolic < 130 && diastolic < 80) {
      return Colors.yellow.shade50;
    }
    
    // Tăng huyết áp độ 1
    if ((systolic >= 130 && systolic < 140) || (diastolic >= 80 && diastolic < 90)) {
      return Colors.orange.shade50;
    }
    
    // Tăng huyết áp độ 2
    if ((systolic >= 140 && systolic < 180) || (diastolic >= 90 && diastolic < 120)) {
      return Colors.red.shade50;
    }
    
    // Tăng huyết áp độ 3
    return Colors.red.shade100;
  }
}