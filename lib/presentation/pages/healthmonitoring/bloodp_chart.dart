import 'package:doctor_care/core/images/images.dart';
import 'package:doctor_care/domain/entities/blood_pressure.dart';
import 'package:doctor_care/presentation/pages/screens/HbA1c/widgets/Infodialogicon.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BloodpChart extends StatefulWidget {
  final List<BloodPressure> data;
  final VoidCallback? onFilterTap; // optional callback
  const BloodpChart({
    super.key,
    required this.data,
    this.onFilterTap,
  });

  @override
  State<BloodpChart> createState() => _BloodpChartState();
}

class _BloodpChartState extends State<BloodpChart> {
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
      padding: EdgeInsets.only(left: 10, top: 20),
      child: Column(
        children: [
          Row(
            children: [
              Gap(10),
              Text(
                "Biểu đồ huyết áp", 
                style: TextStyle(
                color: Colors.black, 
                fontSize: 14, 
                fontWeight: FontWeight.w500
               ),
              ),
              Gap(3),
              Text(
                "(mmHg)", 
                style: TextStyle(
                color: Colors.grey, 
                fontSize: 14, 
                fontWeight: FontWeight.w300
               ),
              ),
              Gap(3),
              InfoDialogIcon(image: Image.asset(Images.glucose, width: 100, height: 80),
               content: TextSpan(
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1),
               children: [
                TextSpan(text: '• ', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
               ]
               )
             ),
             Spacer(),
             Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: GestureDetector(
                  onTap: widget.onFilterTap,
                  child: Icon(Icons.science_outlined, size: 22, color: Colors.black54),
                ),
              ),
              Gap(20),
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: GestureDetector(
                  onTap: () {
                    
                  },
                  child: Icon(Icons.add_chart_sharp, size: 22, color: Colors.black54),
                ),
              ),
            ],
          ),
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
                : InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 3.0,
                    boundaryMargin: EdgeInsets.all(50),
                    child: Stack(
                      children: [
                        // Layer 1: Axes và grid cố định
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BloodPressureAxesPainter(widget.data),
                          ),
                        ),
                        
                        //Layer 2: Data scrollable
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.only(left: leftMargin, right: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: widget.data.length * pointSpacing + 60,
                                child: CustomPaint(
                                  painter: BloodPressureDataPainter(widget.data),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class BloodPressureAxesPainter extends CustomPainter {
  final List<BloodPressure> data;

  BloodPressureAxesPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if(data.isEmpty) return;

    const double leftMargin = 50;
    const double topMargin = 40;
    const double bottomMargin = 50;
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

    //nhãn y
    final values = [0, 40, 80, 120, 160, 200, 240];
    double maxWidth = 0; // Tìm chiều rộng lớn nhất của nhãn
    final textPainters = <TextPainter>[]; // Danh sách để lưu TextPainter

    for(int i=0; i < values.length; i++){
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
      if(textPainter.width > maxWidth) {
        maxWidth = textPainter.width; 
      }
    }
    for (int i = 0; i < values.length; i++) {
      final step = (bottomY - topMargin) / (values.length - 1); // khoảng cách giữa các nhãn
      final y = bottomY - step * i; // vị trí y của nhãn hiện tại
      textPainters[i].paint(
        canvas,
        Offset(leftMargin - maxWidth - 15, y - textPainters[i].height / 2), // canh giữa theo chiều dọc
      );
    }

    final targetPaint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

      canvas.drawCircle(
      Offset(leftMargin + 15, leftMargin + chartHeight + 10),
      3.5,
      targetPaint
    );

    final targetText = TextPainter(
      text: TextSpan(
        text: "Huyết áp tâm thu",
        style: TextStyle(
          color: Colors.blue, 
          fontSize: 11.5,  
          fontWeight: FontWeight.w500
        )
      ),
      textDirection: TextDirection.ltr
    );
    targetText.layout();
    targetText.paint(canvas, Offset(leftMargin + 25 , leftMargin + chartHeight - targetText.height / 2 + 10));

    final targetPaint1 = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

      canvas.drawCircle(
      Offset(leftMargin + 155, leftMargin + chartHeight + 10),
      3.5,
      targetPaint1
    );

    final targetText1 = TextPainter(
      text: TextSpan(
        text: "Huyết áp tâm trương",
        style: TextStyle(
          color: Colors.green, 
          fontSize: 11.5,  
          fontWeight: FontWeight.w500
        )
      ),
      textDirection: TextDirection.ltr
    );
    targetText1.layout();
    targetText1.paint(canvas, Offset(leftMargin + 165 , leftMargin + chartHeight - targetText1.height / 2 + 10));
  }
  
  @override
  bool shouldRepaint(BloodPressureAxesPainter oldDelegate) {
     return oldDelegate.data != data;
  }
}

class BloodPressureDataPainter extends CustomPainter {
   final List<BloodPressure> data;

  BloodPressureDataPainter(this.data);
  @override
  void paint(Canvas canvas, Size size) {
     if(data.isEmpty) return;
    
    const double topMargin = 40;
    const double bottomMargin = 60;
    const double axisPadding = 30; 
    const double xOffset = 40;
    const double pointSpacing = 75; // khoảng cách giữa các điểm

    final double chartHeight = size.height - topMargin - bottomMargin; // chiều cao biểu đồ
    final double bottomY = topMargin + chartHeight - axisPadding; // vị trí y dưới cùng của biểu đồ
    final double chartTop = topMargin; // vị trí y trên cùng của biểu đồ

     final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
      
    final values = [0, 40, 80, 120, 160, 200, 240];
    for (int i = 0; i < values.length; i++) {
      final step = (bottomY - chartTop) / (values.length - 3);
      final y = bottomY - step * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    //nhãn x
    for(int i = 0 ; i < data.length; i++) {
     final double x = xOffset + (i * pointSpacing); // vị trí x của điểm hiện tại

     final timeText = '${data[i].timestamp.hour.toString().padLeft(2, '0')}:${data[i].timestamp.minute.toString().padLeft(2, '0')}';
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
     timeTextPainter.paint(canvas, Offset(x - timeTextPainter.width / 2 - 10, bottomY + 5));

     final dateText = '${data[i].timestamp.day}/${data[i].timestamp.month}/${data[i].timestamp.year}';
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
        Offset(x - dateTextPainter.width / 2 - 10, bottomY + 20),
      );
    }

    // Vẽ điểm dữ liệu huyết áp
    final systolicPaint = Paint()..style = PaintingStyle.fill;

    for(int i = 0 ; i < data.length; i++) {
       final double x = xOffset + (i * pointSpacing); // vị trí x của điểm hiện tại
       final valueRatio = data[i].systolic / 240.0; // tỷ lệ giá trị so với giá trị tối đa (240)
       final y = bottomY - (valueRatio * (bottomY - chartTop)); // vị trí y của điểm hiện tại

      systolicPaint.color = Colors.blue.shade800;
      canvas.drawCircle(Offset(x, y), 4, systolicPaint);

      final valueText = TextPainter(
        text: TextSpan(
          text: '${data[i].systolic}',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valueText.layout();

      final bgRect = RRect.fromRectAndRadius( 
        Rect.fromCenter(
          center: Offset(x, y - valueText.height / 2 - 12),
          width: valueText.width + 8,
          height: valueText.height + 4,
        ),
        Radius.circular(4),
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
          ..strokeWidth = 1.2,
      );
      // Vẽ value
      valueText.paint(
        canvas,
        Offset(x - valueText.width / 2, y - valueText.height - 13),
      );
    }

    final diastolicPaint = Paint()..style = PaintingStyle.fill;
    for(int i = 0 ; i < data.length; i++) {
       final double x = xOffset + (i * pointSpacing); // vị trí x của điểm hiện tại
       final valueRatio = data[i].diastolic / 240.0; // tỷ lệ giá trị so với giá trị tối đa (240)
       final y = bottomY - (valueRatio * (bottomY - chartTop)); // vị trí y của điểm hiện tại

      diastolicPaint.color = Colors.green;
      canvas.drawCircle(Offset(x, y), 4, diastolicPaint);

      final valueText = TextPainter(
        text: TextSpan(
          text: '${data[i].diastolic}',
          style: TextStyle(
            color: Colors.green,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valueText.layout();

      final bgRect = RRect.fromRectAndRadius( 
        Rect.fromCenter(
          center: Offset(x, y - valueText.height / 2 - 12),
          width: valueText.width + 8,
          height: valueText.height + 4,
        ),
        Radius.circular(4),
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
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      // Vẽ value
      valueText.paint(
        canvas,
        Offset(x - valueText.width / 2, y - valueText.height - 13),
      );
    }

    // nỗi các điểm dữ liệu
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // nối huyết áp tâm thu
    linePaint.color = Colors.blue.shade800;
    for(int i = 0 ; i < data.length - 1; i++) {
       final double x1 = xOffset + (i * pointSpacing);
       final valueRatio1 = data[i].systolic / 240.0;
       final y1 = bottomY - (valueRatio1 * (bottomY - chartTop));

       final double x2 = xOffset + ((i + 1) * pointSpacing);
       final valueRatio2 = data[i + 1].systolic / 240.0;
       final y2 = bottomY - (valueRatio2 * (bottomY - chartTop));

       canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    } 

    // nối huyết áp tâm trương
    linePaint.color = Colors.green;
    for(int i = 0 ; i < data.length - 1; i++) {
       final double x1 = xOffset + (i * pointSpacing);
       final valueRatio1 = data[i].diastolic / 240.0;
       final y1 = bottomY - (valueRatio1 * (bottomY - chartTop));

       final double x2 = xOffset + ((i + 1) * pointSpacing);
       final valueRatio2 = data[i + 1].diastolic / 240.0;
       final y2 = bottomY - (valueRatio2 * (bottomY - chartTop));

       canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }

    // vẽ gradient fill dưới đường nối
   final systolicPath = Path();
    systolicPath.moveTo(xOffset, bottomY); // ✅ Bắt đầu từ bottom-left
    
    for(int i = 0; i < data.length; i++) {
      final double x = xOffset + (i * pointSpacing);
      final valueRatio = data[i].systolic / 240.0;
      final y = bottomY - (valueRatio * (bottomY - chartTop));
      systolicPath.lineTo(x, y);
    }
    
    systolicPath.lineTo(xOffset + (data.length - 1) * pointSpacing, bottomY); // ✅ Xuống bottom-right
    systolicPath.close(); // ✅ Đóng path
    
    final systolicGradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade800.withOpacity(0.5), // ✅ Giảm opacity
          Colors.blue.shade50.withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, chartTop, size.width, bottomY - chartTop))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(systolicPath, systolicGradientPaint);

    final diastolicPath = Path();
    diastolicPath.moveTo(xOffset, bottomY); // ✅ Bắt đầu từ bottom-left
    
    for(int i = 0; i < data.length; i++) {
      final double x = xOffset + (i * pointSpacing);
      final valueRatio = data[i].diastolic / 240.0;
      final y = bottomY - (valueRatio * (bottomY - chartTop));
      diastolicPath.lineTo(x, y);
    }
    
    diastolicPath.lineTo(xOffset + (data.length - 1) * pointSpacing, bottomY); // ✅ Xuống bottom-right
    diastolicPath.close(); // ✅ Đóng path
    
    final diastolicGradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.green.withOpacity(0.5), // ✅ Giảm opacity
          Colors.green.shade50.withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, chartTop, size.width, bottomY - chartTop))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(diastolicPath, diastolicGradientPaint);
  }

  @override
  bool shouldRepaint(BloodPressureDataPainter oldDelegate) {
     return oldDelegate.data != data;
  }

}