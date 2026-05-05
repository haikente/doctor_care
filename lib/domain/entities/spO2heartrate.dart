import 'package:flutter/material.dart';

/// Nguồn dữ liệu SpO2/Heart Rate
enum SpO2Source {
  manual,       // Nhập tay
  healthConnect, // Đồng bộ từ Health Connect (thiết bị đeo)
}

class SpO2HeartRate {
  final int? id;
  final int spo2;
  final int heartRate;
  final DateTime timestamp;
  final String? note;
  final SpO2Source source;

  SpO2HeartRate({
    this.id,
    required this.spo2,
    required this.heartRate,
    required this.timestamp,
    this.note,
    this.source = SpO2Source.manual,
  });

  /// Label hiển thị nguồn dữ liệu
  String get sourceLabel {
    switch (source) {
      case SpO2Source.manual:
        return 'Nhập tay';
      case SpO2Source.healthConnect:
        return 'Health Connect';
    }
  }

  /// Icon nguồn dữ liệu
  IconData get sourceIcon {
    switch (source) {
      case SpO2Source.manual:
        return Icons.edit_note;
      case SpO2Source.healthConnect:
        return Icons.watch;
    }
  }

  /// Màu nguồn dữ liệu
  Color get sourceColor {
    switch (source) {
      case SpO2Source.manual:
        return Colors.blueGrey;
      case SpO2Source.healthConnect:
        return Colors.teal;
    }
  }

  String get spo2Status {
    if (spo2 >= 95) {
      return "Bình thường";
    } else if (spo2 >= 90 && spo2 < 95) {
      return "Thiếu oxy nhẹ";
    } else if (spo2 >= 85 && spo2 < 90) {
      return "Thiếu oxy vừa";
    } else {
      return "Thiếu oxy nghiêm trọng";
    }
  }

  Color get spo2Color {
    if (spo2 >= 95) {
      return Colors.green;
    } else if (spo2 >= 90) {
      return Colors.orange;
    } else if (spo2 >= 85) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }

  Color get spo2BackgroundColor {
    if (spo2 >= 95) {
      return Colors.green.shade50;
    } else if (spo2 >= 90) {
      return Colors.orange.shade50;
    } else if (spo2 >= 85) {
      return Colors.deepOrange.shade50;
    } else {
      return Colors.red.shade50;
    }
  }

  IconData get spo2Icon {
    if (spo2 >= 95) {
      return Icons.check_circle_outline;
    } else if (spo2 >= 90) {
      return Icons.warning_amber_outlined;
    } else if (spo2 >= 85) {
      return Icons.error_outline;
    } else {
      return Icons.dangerous_outlined;
    }
  }

  String get heartRateStatus {
    if (heartRate < 60) {
      return "Nhịp chậm"; // Bradycardia
    } else if (heartRate >= 60 && heartRate <= 100) {
      return "Bình thường";
    } else if (heartRate > 100 && heartRate <= 120) {
      return "Nhịp nhanh nhẹ"; // Mild Tachycardia
    } else if (heartRate > 120 && heartRate <= 150) {
      return "Nhịp nhanh vừa"; // Moderate Tachycardia
    } else {
      return "Nhịp nhanh cao"; // Severe Tachycardia
    }
  }

  Color get heartRateColor {
    if (heartRate < 60) {
      return Colors.blue;
    } else if (heartRate >= 60 && heartRate <= 100) {
      return Colors.green;
    } else if (heartRate > 100 && heartRate <= 120) {
      return Colors.orange;
    } else if (heartRate > 120 && heartRate <= 150) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }

  Color get heartRateBackgroundColor {
    if (heartRate < 60) {
      return Colors.blue.shade50;
    } else if (heartRate >= 60 && heartRate <= 100) {
      return Colors.green.shade50;
    } else if (heartRate > 100 && heartRate <= 120) {
      return Colors.orange.shade50;
    } else if (heartRate > 120 && heartRate <= 150) {
      return Colors.deepOrange.shade50;
    } else {
      return Colors.red.shade50;
    }
  }

  IconData get heartRateIcon {
    if (heartRate < 60) {
      return Icons.trending_down;
    } else if (heartRate >= 60 && heartRate <= 100) {
      return Icons.favorite_outline;
    } else if (heartRate > 100 && heartRate <= 120) {
      return Icons.trending_up;
    } else if (heartRate > 120 && heartRate <= 150) {
      return Icons.warning_amber_outlined;
    } else {
      return Icons.dangerous_outlined;
    }
  }

  // ========== COMBINED STATUS ==========
  String get combinedStatus {
    // Ưu tiên hiển thị trạng thái nghiêm trọng nhất
    if (spo2 < 85 || heartRate > 150 || heartRate < 40) {
      return "Nguy hiểm";
    } else if (spo2 < 90 || heartRate > 120 || heartRate < 50) {
      return "Cần chú ý";
    } else if (spo2 < 95 || heartRate > 100 || heartRate < 60) {
      return "Theo dõi";
    } else {
      return "Bình thường";
    }
  }

  Color get combinedColor {
    if (spo2 < 85 || heartRate > 150 || heartRate < 40) {
      return Colors.red;
    } else if (spo2 < 90 || heartRate > 120 || heartRate < 50) {
      return Colors.deepOrange;
    } else if (spo2 < 95 || heartRate > 100 || heartRate < 60) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}