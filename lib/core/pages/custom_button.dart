import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
 final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool expanded;
  final EdgeInsets padding;
  final List<Color>? gradient;
  final Color? textColor;
  final BorderRadius borderRadius;

  final Color? borderColor;
  final double borderWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.expanded = false,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.gradient,
    this.textColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),

    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradient ??
        (enabled
            ? [Colors.blue.shade400, Colors.blue.shade900]
            : [Colors.blue.shade100, Colors.blue.shade200]);

    final button = Container(
      height: 48,
      width: expanded ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: borderRadius,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(
          text,
          style: TextStyle(
            color: textColor ??
                (enabled ? Colors.white : Colors.white60),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    return expanded ? button : button;
  }
}