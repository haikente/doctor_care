import 'package:flutter/material.dart';

class Cholesterol {
  final int? id;
  final double totalCholesterol; // mg/dL
  final double hdl; // mg/dL (có lợi)
  final double ldl; // mg/dL (có hại)
  final double triglycerides; // mg/dL
  final DateTime timestamp;
  final String? note;

  Cholesterol({
    this.id,
    required this.totalCholesterol,
    required this.hdl,
    required this.ldl,
    required this.triglycerides,
    required this.timestamp,
    this.note,
  });

  /// Phân loại Total Cholesterol (theo AHA)
  String get totalStatus {
    if (totalCholesterol < 200) return 'Tối ưu';
    if (totalCholesterol < 240) return 'Giới hạn cao';
    return 'Cao';
  }

  Color get totalColor {
    if (totalCholesterol < 200) return Colors.green;
    if (totalCholesterol < 240) return Colors.orange;
    return Colors.red;
  }

  /// Phân loại HDL (Cholesterol tốt - càng cao càng tốt)
  String get hdlStatus {
    if (hdl >= 60) return 'Tối ưu';
    if (hdl >= 40) return 'Bình thường';
    return 'Thấp (nguy cơ)';
  }

  Color get hdlColor {
    if (hdl >= 60) return Colors.green;
    if (hdl >= 40) return Colors.orange;
    return Colors.red;
  }

  /// Phân loại LDL (Cholesterol xấu - càng thấp càng tốt)
  String get ldlStatus {
    if (ldl < 100) return 'Tối ưu';
    if (ldl < 130) return 'Gần tối ưu';
    if (ldl < 160) return 'Giới hạn cao';
    if (ldl < 190) return 'Cao';
    return 'Rất cao';
  }

  Color get ldlColor {
    if (ldl < 100) return Colors.green;
    if (ldl < 130) return Colors.lightGreen;
    if (ldl < 160) return Colors.orange;
    if (ldl < 190) return Colors.deepOrange;
    return Colors.red;
  }

  /// Phân loại Triglycerides
  String get triglyceridesStatus {
    if (triglycerides < 150) return 'Bình thường';
    if (triglycerides < 200) return 'Giới hạn cao';
    if (triglycerides < 500) return 'Cao';
    return 'Rất cao';
  }

  Color get triglyceridesColor {
    if (triglycerides < 150) return Colors.green;
    if (triglycerides < 200) return Colors.orange;
    if (triglycerides < 500) return Colors.deepOrange;
    return Colors.red;
  }

  /// Tổng hợp đánh giá nguy cơ tim mạch
  String get overallStatus {
    if (totalCholesterol >= 240 ||
        ldl >= 160 ||
        hdl < 40 ||
        triglycerides >= 200) {
      return 'Nguy cơ cao';
    }
    if (totalCholesterol >= 200 ||
        ldl >= 130 ||
        hdl < 50 ||
        triglycerides >= 150) {
      return 'Cần chú ý';
    }
    return 'Tốt';
  }

  Color get overallColor {
    final s = overallStatus;
    if (s == 'Tốt') return Colors.green;
    if (s == 'Cần chú ý') return Colors.orange;
    return Colors.red;
  }

  Color get overallBackgroundColor {
    final s = overallStatus;
    if (s == 'Tốt') return Colors.green.shade50;
    if (s == 'Cần chú ý') return Colors.orange.shade50;
    return Colors.red.shade50;
  }
}
