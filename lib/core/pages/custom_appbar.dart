import 'package:doctor_care/core/pages/app_color.dart';
import 'package:flutter/material.dart';

class CustomStackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final String title;
  final bool centerTitle;
  final Widget? icon;
  

  const CustomStackAppBar({
    super.key,
    this.onBack,
    this.onInfo, 
    required this.title, 
    this.centerTitle = false, 
    this.icon,
  });

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Nền AppBar
        Container(
          height: preferredSize.height,
          color: AppColor.background,
        ),

        // Các đường bút trên cùng (vẽ ở trên nền, trước nội dung)
        Positioned.fill(
          child: CustomPaint(
            painter: BrushLinesPainter(),
          ),
        ),

        // Sóng đáy AppBar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 20),
          ),
        ),

      // ...existing code...

// Nội dung AppBar (icon + title + action)
SafeArea(
  child: SizedBox(
    height: 70,
    child: Row(
      children: [
        // ✅ FIX 1: Luôn có SizedBox để cân bằng
        if (onBack != null)
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: onBack,
          )
        else
          const SizedBox(width: 48), // ✅ Placeholder khi không có back button

        // Title
        Expanded(
          child: centerTitle
              ? Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
              : Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),

        // ✅ FIX 2: Luôn có SizedBox bên phải để cân bằng
        if (onInfo != null)
          IconButton(
            icon: icon ??
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
            onPressed: onInfo,
          )
        else
          const SizedBox(width: 48), // ✅ Placeholder khi không có info button
      ],
    ),
  ),
),

// ...existing code...
      ],
    );
  }
}



class BrushLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    // Line 1: sóng nhẹ uốn lượn ngang trên cùng
    final path1 = Path();
    path1.moveTo(0, height * 0.2);
    path1.quadraticBezierTo(width * 0.25, height * 0.1, width * 0.5, height * 0.25);
    path1.quadraticBezierTo(width * 0.75, height * 0.4, width, height * 0.3);
    canvas.drawPath(path1, paint);

    // Line 2: line thẳng ngang phía dưới line 1
    final y2 = height * 0.4;
    canvas.drawLine(Offset(0, y2), Offset(width, y2), paint);

    // Line 3: sóng nhẹ uốn lượn ngang phía dưới line 2
    final path3 = Path();
    path3.moveTo(0, height * 0.6);
    path3.quadraticBezierTo(width * 0.3, height * 0.5, width * 0.6, height * 0.7);
    path3.quadraticBezierTo(width * 0.85, height * 0.9, width, height * 0.65);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
