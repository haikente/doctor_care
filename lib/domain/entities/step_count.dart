import 'package:flutter/material.dart';

enum StepCountSource {
  manual,
  healthConnect,
}

class StepCount {
  final int? id;
  final int steps;
  final double? distance; // km
  final double? caloriesBurned; // kcal
  final DateTime timestamp;
  final String? note;
  final StepCountSource source;

  StepCount({
    this.id,
    required this.steps,
    this.distance,
    this.caloriesBurned,
    required this.timestamp,
    this.note,
    this.source = StepCountSource.manual,
  });

  /// Nguồn dữ liệu.
  String get sourceLabel {
    switch (source) {
      case StepCountSource.manual:
        return 'Nhập tay';
      case StepCountSource.healthConnect:
        return 'Thiết bị';
    }
  }

  IconData get sourceIcon {
    switch (source) {
      case StepCountSource.manual:
        return Icons.edit_note;
      case StepCountSource.healthConnect:
        return Icons.watch;
    }
  }

  Color get sourceColor {
    switch (source) {
      case StepCountSource.manual:
        return Colors.blueGrey;
      case StepCountSource.healthConnect:
        return Colors.blue;
    }
  }

  /// Phân loại theo nghiên cứu y khoa.
  String get status {
    if (steps < 3000) return 'Ít vận động';
    if (steps < 6000) return 'Vận động nhẹ';
    if (steps < 10000) return 'Vận động vừa';
    if (steps < 15000) return 'Tốt';
    return 'Rất tích cực';
  }

  Color get statusColor {
    if (steps < 3000) return Colors.red;
    if (steps < 6000) return Colors.orange;
    if (steps < 10000) return Colors.amber.shade700;
    if (steps < 15000) return Colors.green;
    return Colors.teal;
  }

  Color get backgroundColor {
    if (steps < 3000) return Colors.red.shade50;
    if (steps < 6000) return Colors.orange.shade50;
    if (steps < 10000) return Colors.amber.shade50;
    if (steps < 15000) return Colors.green.shade50;
    return Colors.teal.shade50;
  }

  IconData get statusIcon {
    if (steps < 3000) return Icons.airline_seat_recline_normal;
    if (steps < 6000) return Icons.directions_walk;
    if (steps < 10000) return Icons.directions_walk;
    if (steps < 15000) return Icons.directions_run;
    return Icons.emoji_events;
  }

  /// Phần trăm hoàn thành mục tiêu (10000 bước)
  double get progressPercent {
    const goal = 10000;
    return (steps / goal * 100).clamp(0, 100);
  }
}
