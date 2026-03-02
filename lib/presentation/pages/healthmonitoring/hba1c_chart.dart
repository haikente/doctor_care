import 'package:doctor_care/core/images/images.dart';
import 'package:doctor_care/domain/entities/hba1c.dart';
import 'package:doctor_care/presentation/pages/screens/HbA1c/widgets/Infodialogicon.dart';
import 'package:doctor_care/presentation/pages/screens/HbA1c/fullscreen_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Hba1cChart extends StatefulWidget {
  final List<HbA1c> data;
  final VoidCallback? onFilterTap;
  
  const Hba1cChart({
    super.key, 
    required this.data,
    this.onFilterTap,
  });

  @override
  State<Hba1cChart> createState() => _Hba1cChartState();
}

class _Hba1cChartState extends State<Hba1cChart> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double pointSpacing = 80.0;
    const double leftMargin = 50.0;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 10, top: 22),
      child: Column(
        children: [
          // Header row với title và icons
          Row(
            children: [
              Text(
                "Biểu đồ HbA1c", 
                style: TextStyle(
                  color: Colors.black, 
                  fontSize: 16, 
                  fontWeight: FontWeight.w500
                ),
              ),
              Gap(3),
              InfoDialogIcon(
                image: Image.asset(Images.glucose, width: 100, height: 80), 
                content: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1,
                  ),
                  children: [
                    TextSpan(text: 'Chỉ số '),
                    TextSpan(text: 'HbA1c', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' phản ánh mức đường huyết trung bình trong '),
                    TextSpan(
                      text: '2–3 tháng gần nhất. ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'Mục tiêu điều trị được khuyến cáo cho người mắc đái tháo đường là',
                    ),
                    TextSpan(text: ' <7%', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: GestureDetector(
                  onTap: widget.onFilterTap,  
                  child: Icon(Icons.science_outlined, size: 24, color: Colors.black54),
                ),
              ),
              Gap(20),
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullscreenHba1cChart(data: widget.data),
                      ),
                    );
                  },
                  child: Icon(Icons.add_chart_sharp, size: 24, color: Colors.black54),
                ),
              ),
            ],
          ),
          
          // Chart area hoặc Empty state
          Expanded(
            child: widget.data.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insert_chart_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không có dữ liệu',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Vui lòng chọn bộ lọc khác',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                 : LayoutBuilder(
                      builder: (context, constraints) {
                        final double chartWidth = widget.data.length * pointSpacing + 60;
                        // Đảm bảo width tối thiểu bằng vùng hiển thị
                        final double effectiveWidth = chartWidth < (constraints.maxWidth - leftMargin - 10) 
                            ? constraints.maxWidth - leftMargin - 10 
                            : chartWidth;

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: Hba1cAxesPainter(widget.data),
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: EdgeInsets.only(left: leftMargin, right: 10),
                                child: ClipRect(
                                  child: InteractiveViewer(
                                    transformationController: _transformationController,
                                    minScale: 1.0,
                                    maxScale: 3.0,
                                    constrained: false,
                                    scaleEnabled: true,
                                    panEnabled: true,
                                    child: SizedBox(
                                      width: effectiveWidth,
                                      height: constraints.maxHeight,
                                      child: CustomPaint(
                                        painter: Hba1cDataPainter(widget.data),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
        ],
      ),
    );
  }
}

// Painter cho trục Y và X (cố định)
class Hba1cAxesPainter extends CustomPainter {
  final List<HbA1c> data;

  Hba1cAxesPainter(this.data);
  
  @override
  void paint(Canvas canvas, Size size) {
    if(data.isEmpty) return;
    
    const double leftMargin = 50;
    const double topMargin = 50;
    const double bottomMargin = 70;
    const double axisPadding = 40;
    
    final double chartHeight = size.height - topMargin - bottomMargin;
    final double bottomY = topMargin + chartHeight - axisPadding;

    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2;

    // Vẽ trục Y
    canvas.drawLine(
      Offset(leftMargin, topMargin), 
      Offset(leftMargin, bottomY),
      axisPaint
    );

    // Vẽ trục X
    canvas.drawLine(
      Offset(leftMargin, bottomY),
      Offset(size.width - 10, bottomY),
      axisPaint
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
            fontWeight: FontWeight.w500
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

    // Vẽ legend
    final targetPaint = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(leftMargin - 30, leftMargin + chartHeight + 40),
      4,
      targetPaint
    );

    final targetText = TextPainter(
      text: TextSpan(
        text: "Mục tiêu",
        style: TextStyle(
          color: Colors.black54, 
          fontSize: 12, 
          letterSpacing: 0.5, 
          fontWeight: FontWeight.w500
        )
      ),
      textDirection: TextDirection.ltr
    );
    targetText.layout();
    targetText.paint(canvas, Offset(leftMargin - 20, leftMargin + chartHeight + 32));

    final hba1cText = TextPainter(
      text: TextSpan(
        text: "HbA1c < 7%",
        style: TextStyle(
          color: Colors.green, 
          fontSize: 12, 
          letterSpacing: 0.5, 
          fontWeight: FontWeight.bold
        )
      ),
      textDirection: TextDirection.ltr
    );
    hba1cText.layout();
    hba1cText.paint(canvas, Offset(leftMargin + 230, leftMargin + chartHeight + 32));
  }
  
  @override
  bool shouldRepaint(Hba1cAxesPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

// Painter cho data points và gradient
class Hba1cDataPainter extends CustomPainter {
  final List<HbA1c> data;

  Hba1cDataPainter(this.data);
  
  @override
  void paint(Canvas canvas, Size size) {
    if(data.isEmpty) return;
    
    const double topMargin = 50;
    const double bottomMargin = 70;
    const double axisPadding = 40;
    const double xOffset = 30;
    const double pointSpacing = 80;
    
    final double chartHeight = size.height - topMargin - bottomMargin;
    final double bottomY = topMargin + chartHeight - axisPadding;
    final double chartTop = topMargin;

    // Vẽ grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;
    
    final values = [0, 5, 10, 15, 20];
    for (int i = 0; i < values.length; i++) {
      final step = (bottomY - chartTop) / (values.length - 1);
      final y = bottomY - step * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vẽ labels thời gian và ngày
    for (int i = 0; i < data.length; i++) {
      final double x = xOffset + (i * pointSpacing);
      
      final timeText = '${data[i].date.hour.toString().padLeft(2, '0')}:${data[i].date.minute.toString().padLeft(2, '0')}';
      final timeTextPainter = TextPainter(
        text: TextSpan(
          text: timeText,
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
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

      final dateText = '${data[i].date.day}/${data[i].date.month}/${data[i].date.year}';
      final dateTextPainter = TextPainter(
        text: TextSpan(
          text: dateText,
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      dateTextPainter.layout();
      dateTextPainter.paint(
        canvas,
        Offset(x - dateTextPainter.width / 2, bottomY + 20),
      );
    }

    // Vẽ gradient area
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

    // Vẽ line
    final linePaint = Paint()
      ..color = Colors.blue.shade800
      ..strokeWidth = 2.25
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

    // Vẽ points và values
    final pointPaint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < data.length; i++) {
      final double x = xOffset + (i * pointSpacing);
      final valueRatio = data[i].value / 20.0;
      final y = bottomY - (valueRatio * (bottomY - chartTop));
      
      pointPaint.color = Colors.blue.shade800;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      
      final valueText = TextPainter(
        text: TextSpan(
          text: '${data[i].value.toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valueText.layout();
      
      // Vẽ background cho value
      final bgRect = RRect.fromRectAndRadius( 
        Rect.fromCenter(
          center: Offset(x, y - valueText.height / 2 - 12),
          width: valueText.width + 8,
          height: valueText.height + 4,
        ),
        Radius.circular(4),
      );

      // Vẽ background cho value
      canvas.drawRRect(
        bgRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      // Vẽ viền cho background
      canvas.drawRRect(
        bgRect,
        Paint()
          ..color = Colors.blue.shade800
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      // Vẽ value
      valueText.paint(
        canvas,
        Offset(x - valueText.width / 2, y - valueText.height - 13),
      );
    }
  }
  
  @override
  bool shouldRepaint(Hba1cDataPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}