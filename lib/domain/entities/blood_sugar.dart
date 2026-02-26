import 'package:flutter/material.dart';

class BloodSugar {
  final int? id;
  final double value; // mg/dL
  final String mealStatus; // 'fasting', 'before_meal', 'after_meal', 'random'
  final DateTime timestamp;
  final String? note;

  BloodSugar({
    this.id,
    required this.value,
    required this.mealStatus,
    required this.timestamp,
    this.note,
  });

  /// Tên trạng thái bữa ăn
  String get mealStatusLabel {
    switch (mealStatus) {
      case 'fasting':
        return 'Lúc đói';
      case 'before_meal':
        return 'Trước ăn';
      case 'after_meal':
        return 'Sau ăn 2h';
      case 'random':
        return 'Ngẫu nhiên';
      default:
        return 'Không xác định';
    }
  }

  /// Phân loại đường huyết theo ADA (American Diabetes Association)
  String get status {
    if (value < 70) {
      return 'Hạ đường huyết';
    }
    if (mealStatus == 'fasting' || mealStatus == 'before_meal') {
      if (value < 100) return 'Bình thường';
      if (value < 126) return 'Tiền đái tháo đường';
      return 'Đái tháo đường';
    } else {
      // after_meal hoặc random
      if (value < 140) return 'Bình thường';
      if (value < 200) return 'Tiền đái tháo đường';
      return 'Đái tháo đường';
    }
  }

  Color get statusColor {
    if (value < 70) return Colors.blue;
    final s = status;
    if (s == 'Bình thường') return Colors.green;
    if (s == 'Tiền đái tháo đường') return Colors.orange;
    return Colors.red;
  }

  Color get backgroundColor {
    if (value < 70) return Colors.blue.shade50;
    final s = status;
    if (s == 'Bình thường') return Colors.green.shade50;
    if (s == 'Tiền đái tháo đường') return Colors.orange.shade50;
    return Colors.red.shade50;
  }

  IconData get statusIcon {
    if (value < 70) return Icons.trending_down;
    final s = status;
    if (s == 'Bình thường') return Icons.check_circle_outline;
    if (s == 'Tiền đái tháo đường') return Icons.warning_amber_outlined;
    return Icons.dangerous_outlined;
  }
}
