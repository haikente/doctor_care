import 'package:flutter/material.dart';

enum SnackBarType { add, update, delete }

class AppSnackBar {

  static void showBloodPressure({
    required BuildContext context,
    required SnackBarType type,
  }) {
    final config = {
      SnackBarType.add: _SnackBarConfig(
        color: Colors.green,
        icon: Icons.check_circle,
        text: 'Đã thêm chỉ số huyết áp thành công',
      ),
      SnackBarType.update: _SnackBarConfig(
        color: Colors.orange,
        icon: Icons.edit,
        text: 'Cập nhật chỉ số huyết áp thành công',
      ),
      SnackBarType.delete: _SnackBarConfig(
        color: Colors.red,
        icon: Icons.delete_outline,
        text: 'Đã xóa chỉ số huyết áp thành công',
      ),
    };

    final settings = config[type]!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: settings.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(settings.icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(settings.text)),
          ],
        ),
      ),
    );
  }

  static void showSpo2heartRate({
    required BuildContext context,
    required SnackBarType type,
  }) {
    final config = {
      SnackBarType.add: _SnackBarConfig(
        color: Colors.green,
        icon: Icons.check_circle,
        text: 'Đã thêm chỉ số Spo2 và nhịp tim thành công',
      ),
      SnackBarType.update: _SnackBarConfig(
        color: Colors.orange,
        icon: Icons.edit,
        text: 'Cập nhật chỉ số Spo2 và nhịp tim thành công',
      ),
      SnackBarType.delete: _SnackBarConfig(
        color: Colors.red,
        icon: Icons.delete_outline,
        text: 'Đã xóa chỉ số Spo2 và nhịp tim thành công',
      ),
    };

    final settings = config[type]!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: settings.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(settings.icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(settings.text)),
          ],
        ),
      ),
    );
  }

  

  static void showtemperature({
    required BuildContext context,
    required SnackBarType type,
  }) {
    final config = {
      SnackBarType.add: _SnackBarConfig(
        color: Colors.green,
        icon: Icons.check_circle,
        text: 'Đã thêm chỉ số nhiệt độ thành công',
      ),
      SnackBarType.update: _SnackBarConfig(
        color: Colors.orange,
        icon: Icons.edit,
        text: 'Cập nhật chỉ số nhiệt độ thành công',
      ),
      SnackBarType.delete: _SnackBarConfig(
        color: Colors.red,
        icon: Icons.delete_outline,
        text: 'Đã xóa chỉ số nhiệt độ thành công',
      ),
    };

    final settings = config[type]!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: settings.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(settings.icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(settings.text)),
          ],
        ),
      ),
    );
  }


  static void show({
    required BuildContext context,
    required SnackBarType type,
  }) {
    final config = {
      SnackBarType.add: _SnackBarConfig(
        color: Colors.green,
        icon: Icons.check_circle,
        text: 'Đã thêm chỉ số HbA1c thành công',
      ),
      SnackBarType.update: _SnackBarConfig(
        color: Colors.orange,
        icon: Icons.edit,
        text: 'Cập nhật chỉ số HbA1c thành công',
      ),
      SnackBarType.delete: _SnackBarConfig(
        color: Colors.red,
        icon: Icons.delete_outline,
        text: 'Đã xóa chỉ số HbA1c thành công',
      ),
    };

    final settings = config[type]!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: settings.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(settings.icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(settings.text)),
          ],
        ),
      ),
    );
  }
}

class _SnackBarConfig {
  final Color color;
  final IconData icon;
  final String text;

  _SnackBarConfig({
    required this.color,
    required this.icon,
    required this.text,
  });
}
