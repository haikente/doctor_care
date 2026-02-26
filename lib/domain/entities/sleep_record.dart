import 'package:flutter/material.dart';

class SleepRecord {
  final int? id;
  final DateTime bedTime; // Giờ đi ngủ
  final DateTime wakeTime; // Giờ thức dậy
  final int quality; // 1-5 (Rất tệ → Rất tốt)
  final DateTime timestamp; // Ngày ghi nhận
  final String? note;

  SleepRecord({
    this.id,
    required this.bedTime,
    required this.wakeTime,
    required this.quality,
    required this.timestamp,
    this.note,
  });

  /// Tính tổng thời gian ngủ (phút)
  int get totalMinutes {
    return wakeTime.difference(bedTime).inMinutes;
  }

  /// Tính thời gian ngủ (giờ, phút)
  String get durationText {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}p';
    if (hours > 0) return '${hours}h';
    return '${minutes}p';
  }

  /// Tính thời gian ngủ (giờ - dạng số thực)
  double get durationHours => totalMinutes / 60.0;

  /// Phân loại theo National Sleep Foundation
  String get durationStatus {
    final hours = durationHours;
    if (hours < 5) return 'Thiếu ngủ nghiêm trọng';
    if (hours < 6) return 'Thiếu ngủ';
    if (hours < 7) return 'Tạm đủ';
    if (hours <= 9) return 'Tốt';
    return 'Ngủ quá nhiều';
  }

  Color get durationColor {
    final hours = durationHours;
    if (hours < 5) return Colors.red;
    if (hours < 6) return Colors.orange;
    if (hours < 7) return Colors.amber.shade700;
    if (hours <= 9) return Colors.green;
    return Colors.blue;
  }

  Color get durationBackgroundColor {
    final hours = durationHours;
    if (hours < 5) return Colors.red.shade50;
    if (hours < 6) return Colors.orange.shade50;
    if (hours < 7) return Colors.amber.shade50;
    if (hours <= 9) return Colors.green.shade50;
    return Colors.blue.shade50;
  }

  /// Chất lượng giấc ngủ
  String get qualityLabel {
    switch (quality) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Tệ';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Rất tốt';
      default:
        return 'Không xác định';
    }
  }

  Color get qualityColor {
    switch (quality) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber.shade700;
      case 4:
        return Colors.green;
      case 5:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData get qualityIcon {
    switch (quality) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.help_outline;
    }
  }
}
