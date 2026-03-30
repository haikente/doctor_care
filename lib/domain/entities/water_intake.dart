import 'package:flutter/material.dart';

class WaterIntake {
  final int? id;
  final int amount; // ml
  final DateTime timestamp;
  final String? note;
  final int? profileId;

  WaterIntake({
    this.id,
    required this.amount,
    required this.timestamp,
    this.note,
    this.profileId,
  });

  // Getter: Icon theo lượng nước
  IconData get sizeIcon {
    if (amount <= 200) return Icons.local_cafe; // Cốc nhỏ
    if (amount <= 500) return Icons.local_drink; // Cốc vừa
    if (amount <= 1000) return Icons.water_drop; // Chai nhỏ
    return Icons.water; // Chai lớn
  }

  // Getter: Trạng thái hydration dựa trên tổng trong ngày
  static String getDailyStatus(int totalAmount) {
    if (totalAmount < 1500) return 'Cần uống thêm';
    if (totalAmount < 2000) return 'Gần đạt mục tiêu';
    if (totalAmount <= 2500) return 'Đạt mục tiêu';
    return 'Vượt mục tiêu';
  }

  // Getter: Màu theo trạng thái
  static Color getStatusColor(int totalAmount) {
    if (totalAmount < 1500) return Colors.orange;
    if (totalAmount < 2000) return Colors.blue;
    if (totalAmount <= 2500) return Colors.green;
    return Colors.lightBlue;
  }

  // Getter: Phần trăm hoàn thành mục tiêu
  static double getProgressPercent(int totalAmount) {
    const dailyGoal = 2000; // ml
    return (totalAmount / dailyGoal * 100).clamp(0, 100);
  }
}
