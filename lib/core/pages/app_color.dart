import 'package:flutter/material.dart';

class AppColor {
  static Color background = Colors.blue.shade600;

  // Theme-aware helpers
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade600;
  static Color divider(BuildContext context) => Theme.of(context).dividerColor;
}
