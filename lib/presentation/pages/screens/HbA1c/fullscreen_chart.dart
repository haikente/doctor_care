import 'package:doctor_care/domain/entities/hba1c.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullscreenHba1cChart extends StatefulWidget {
  final List<HbA1c> data;

  const FullscreenHba1cChart({
    super.key,
    required this.data,
  });

  @override
  State<FullscreenHba1cChart> createState() => _FullscreenHba1cChartState();
}

class _FullscreenHba1cChartState extends State<FullscreenHba1cChart> {
  @override
  void initState() {
    super.initState();
    // Ẩn status bar và navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Khóa màn hình ở chế độ ngang
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Khôi phục lại trạng thái bình thường khi thoát
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    // Cho phép tất cả các hướng
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double pointSpacing = 75; // Giảm xuống 80 để chart co lại, gọn hơn
    const double leftMargin = 60.0;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Chart content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Stack(
              children: [
                // Layer 1: Axes cố định
                Positioned.fill(
                  child: CustomPaint(
                    painter: FullscreenHba1cAxesPainter(widget.data),
                  ),
                ),

                // Layer 2: Scrollable content
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(left: leftMargin, right: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: widget.data.length * pointSpacing,
                        child: CustomPaint(
                          painter: FullscreenHba1cDataPainter(
                            widget.data,
                            availableWidth: screenWidth - leftMargin - 30, // Truyền chiều rộng khả dụng
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Header với nút đóng
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Row(
                    children: [
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, size: 25),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Painter cho trục Y và X (fullscreen)
class FullscreenHba1cAxesPainter extends CustomPainter {
  final List<HbA1c> data;

  FullscreenHba1cAxesPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double leftMargin = 60;
    const double topMargin = 40; // Giảm từ 60 xuống 40 để kéo dài trục Y
    const double bottomMargin = 50;
    const double axisPadding = 30;

    final double chartHeight = size.height - topMargin - bottomMargin;
    final double bottomY = topMargin + chartHeight - axisPadding;

    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2;

    // Vẽ trục Y
    canvas.drawLine(
      Offset(leftMargin, topMargin),
      Offset(leftMargin, bottomY),
      axisPaint,
    );

    // Vẽ trục X
    canvas.drawLine(
      Offset(leftMargin, bottomY),
      Offset(size.width, bottomY),
      axisPaint,
    );

    // Vẽ labels trục Y
    final values = [0, 5, 10, 15, 20];
    double maxWidth = 0;
    final textPainters = <TextPainter>[];

    for (int i = 0; i < values.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: i == 0 ? '${values[i]} %' : '${values[i]}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainters.add(textPainter);
      if (textPainter.width > maxWidth) {
        maxWidth = textPainter.width;
      }
    }

    for (int i = 0; i < values.length; i++) {
      final step = (bottomY - topMargin) / (values.length - 1);
      final y = bottomY - step * i;
      textPainters[i].paint(
        canvas,
        Offset(leftMargin - maxWidth - 15, y - textPainters[i].height / 2),
      );
    }

  }

  @override
  bool shouldRepaint(FullscreenHba1cAxesPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

// Painter cho data points (fullscreen)
class FullscreenHba1cDataPainter extends CustomPainter {
  final List<HbA1c> data;
  final double availableWidth;

  FullscreenHba1cDataPainter(this.data, {required this.availableWidth});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double topMargin = 40; // Khớp với FullscreenHba1cAxesPainter
    const double bottomMargin = 50;
    const double axisPadding = 30;
    const double pointSpacing = 75; // Khớp với build method - co lại compact hơn

    final double chartHeight = size.height - topMargin - bottomMargin;
    final double bottomY = topMargin + chartHeight - axisPadding;
    final double chartTop = topMargin;

    // Tính xOffset để căn giữa dữ liệu
    final double totalDataWidth = (data.length - 1) * pointSpacing;
    final double xOffset = (size.width - totalDataWidth);

    // Vẽ grid lines - khớp hoàn toàn với trục X và Y
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    final values = [0, 5, 10, 15, 20];
    for (int i = 0; i < values.length; i++) {
      final step = (bottomY - chartTop) / (values.length - 1);
      final y = bottomY - step * i;
      // Vẽ từ điểm đầu tiên đến điểm cuối cùng (khớp với trục X)
      final firstX = xOffset;
      final lastX = xOffset + ((data.length - 1) * pointSpacing);
      canvas.drawLine(
        Offset(firstX, y),
        Offset(lastX, y),
        gridPaint,
      );
    }

    // Vẽ labels trục X
    for (int i = 0; i < data.length; i++) {
      final double x = xOffset + (i * pointSpacing);

      // Thời gian
      final timeText = '${data[i].date.hour.toString().padLeft(2, '0')}:${data[i].date.minute.toString().padLeft(2, '0')}';
      final timeTextPainter = TextPainter(
        text: TextSpan(
          text: timeText,
          style: TextStyle(
            color: Colors.black,
            fontSize: 11, // Giảm từ 13 xuống 11
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      timeTextPainter.layout();
      timeTextPainter.paint(
        canvas,
        Offset(x - timeTextPainter.width / 2, bottomY + 5),
      );

      // Ngày tháng
      final dateText = '${data[i].date.day}/${data[i].date.month}/${data[i].date.year}';
      final dateTextPainter = TextPainter(
        text: TextSpan(
          text: dateText,
          style: TextStyle(
            color: Colors.black,
            fontSize: 11, // Giảm từ 13 xuống 11
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      dateTextPainter.layout();
      dateTextPainter.paint(
        canvas,
        Offset(x - dateTextPainter.width / 2, bottomY + 22), // Điều chỉnh khoảng cách
      );
    }

    // Vẽ gradient
    final gradientPath = Path();
    gradientPath.moveTo(xOffset, bottomY);

    for (int i = 0; i < data.length; i++) {
      final double x = xOffset + (i * pointSpacing);
      final valueRatio = data[i].value / 20.0;
      final y = bottomY - (valueRatio * (bottomY - chartTop));
      gradientPath.lineTo(x, y);
    }

    final lastX = xOffset + ((data.length - 1) * pointSpacing);
    gradientPath.lineTo(lastX, bottomY);
    gradientPath.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade800,
          Colors.blue.shade50.withOpacity(0.5),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, chartTop, size.width, bottomY - chartTop))
      ..style = PaintingStyle.fill;

    canvas.drawPath(gradientPath, gradientPaint);

    // Vẽ đường line
    final linePaint = Paint()
      ..color = Colors.blue.shade800
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final double x = xOffset + (i * pointSpacing);
      final valueRatio = data[i].value / 20.0;
      final y = bottomY - (valueRatio * (bottomY - chartTop));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // Vẽ data points
    final pointPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final double x = xOffset + (i * pointSpacing);
      final valueRatio = data[i].value / 20.0;
      final y = bottomY - (valueRatio * (bottomY - chartTop));

      pointPaint.color = Colors.blue.shade800;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      // Vẽ value labels
      final valueText = TextPainter(
        text: TextSpan(
          text: '${data[i].value.toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valueText.layout();

      final bgRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, y - valueText.height / 2 - 16),
          width: valueText.width + 12,
          height: valueText.height + 6,
        ),
        Radius.circular(5),
      );

      canvas.drawRRect(
        bgRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      canvas.drawRRect(
        bgRect,
        Paint()
          ..color = Colors.blue.shade800
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      valueText.paint(
        canvas,
        Offset(x - valueText.width / 2, y - valueText.height - 17),
      );
    }
  }

  @override
  bool shouldRepaint(FullscreenHba1cDataPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
