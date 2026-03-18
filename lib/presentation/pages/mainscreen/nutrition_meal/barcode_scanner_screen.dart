import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Màn hình quét mã vạch dạng full-screen
/// Trả về [String] barcode khi quét thành công, null nếu thoát
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false; // chống quét nhiều lần

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    final value = barcode?.rawValue;
    if (value == null || value.isEmpty) return;

    _scanned = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Quét mã vạch',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          // Bật/tắt đèn flash
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Khung ngắm
          _buildScanOverlay(context),

          // Hướng dẫn
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Hướng camera vào mã vạch sản phẩm',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const scanAreaSize = 260.0;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2 - 40;

    return Stack(
      children: [
        // Lớp tối xung quanh khung ngắm
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.55),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Positioned(
                left: left,
                top: top,
                child: Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Góc khung ngắm (4 góc)
        Positioned(
          left: left,
          top: top,
          child: _buildCornerFrame(scanAreaSize),
        ),
      ],
    );
  }

  Widget _buildCornerFrame(double size) {
    const cornerSize = 24.0;
    const thickness = 3.5;
    const color = Colors.blue;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Trên trái
          Positioned(
            top: 0,
            left: 0,
            child: _corner(cornerSize, thickness, color,
                top: true, left: true),
          ),
          // Trên phải
          Positioned(
            top: 0,
            right: 0,
            child: _corner(cornerSize, thickness, color,
                top: true, left: false),
          ),
          // Dưới trái
          Positioned(
            bottom: 0,
            left: 0,
            child: _corner(cornerSize, thickness, color,
                top: false, left: true),
          ),
          // Dưới phải
          Positioned(
            bottom: 0,
            right: 0,
            child: _corner(cornerSize, thickness, color,
                top: false, left: false),
          ),
        ],
      ),
    );
  }

  Widget _corner(
    double size,
    double thickness,
    Color color, {
    required bool top,
    required bool left,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          thickness: thickness,
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top;
  final bool left;

  _CornerPainter({
    required this.color,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    if (top && left) {
      path.moveTo(0, h);
      path.lineTo(0, 0);
      path.lineTo(w, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      path.lineTo(w, h);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, h);
      path.lineTo(w, h);
    } else {
      path.moveTo(0, h);
      path.lineTo(w, h);
      path.lineTo(w, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
