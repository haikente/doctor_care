import 'dart:math' as math;
import 'package:flutter/material.dart';

// lớp định nghĩa các thuộc tính của creatinine
class Creatinine {
  final int? id;
  final double value; // mg/dL
  final DateTime timestamp;
  final String? note;

  // Thông tin bổ sung để tính eGFR
  final int? age;
  final String? gender; // 'male', 'female'

  Creatinine({
    this.id,
    required this.value,
    required this.timestamp,
    this.note,
    this.age,
    this.gender,
  });

  /// Tính eGFR theo công thức CKD-EPI 2021
  /// Chỉ tính được khi có age và gender
  double? get eGFR {
    if (age == null || gender == null || value <= 0) return null;

    // CKD-EPI 2021 (không phân biệt chủng tộc)
    double kappa = gender == 'female' ? 0.7 : 0.9;
    double alpha = gender == 'female' ? -0.241 : -0.302;
    double femaleFactor = gender == 'female' ? 1.012 : 1.0;

    double scrKappa = value / kappa;
    double minVal = scrKappa < 1 ? scrKappa : 1.0;
    double maxVal = scrKappa > 1 ? scrKappa : 1.0;

    double result =
        142 *
        math.pow(minVal, alpha) *
        math.pow(maxVal, -1.200) *
        math.pow(0.9938, age!.toDouble()) *
        femaleFactor;

    return result;
  }

  /// Phân loại Creatinine theo giới tính
  String get status {
    if (gender == 'female') {
      if (value < 0.5) return 'Thấp';
      if (value <= 1.1) return 'Bình thường';
      return 'Cao';
    } else {
      // male hoặc không xác định
      if (value < 0.7) return 'Thấp';
      if (value <= 1.3) return 'Bình thường';
      return 'Cao';
    }
  }

  /// Phân loại CKD dựa trên eGFR
  String get ckdStage {
    final gfr = eGFR;
    if (gfr == null) return 'Chưa tính được';
    if (gfr >= 90) return 'Bình thường (G1)';
    if (gfr >= 60) return 'Giảm nhẹ (G2)';
    if (gfr >= 45) return 'Giảm nhẹ-TB (G3a)';
    if (gfr >= 30) return 'Giảm TB-nặng (G3b)';
    if (gfr >= 15) return 'Giảm nặng (G4)';
    return 'Suy thận (G5)';
  }

  Color get statusColor {
    final s = status;
    if (s == 'Bình thường') return Colors.green;
    if (s == 'Thấp') return Colors.blue;
    return Colors.red;
  }

  Color get backgroundColor {
    final s = status;
    if (s == 'Bình thường') return Colors.green.shade50;
    if (s == 'Thấp') return Colors.blue.shade50;
    return Colors.red.shade50;
  }

  IconData get statusIcon {
    final s = status;
    if (s == 'Bình thường') return Icons.check_circle_outline;
    if (s == 'Thấp') return Icons.trending_down;
    return Icons.warning_amber_outlined;
  }

  /// Khoảng tham chiếu theo giới tính
  String get referenceRange {
    if (gender == 'female') {
      return '0.5 - 1.1 mg/dL';
    }
    return '0.7 - 1.3 mg/dL';
  }
}
