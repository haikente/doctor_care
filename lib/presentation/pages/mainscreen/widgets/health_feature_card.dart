import 'package:flutter/material.dart';

class HealthFeatureCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final VoidCallback? onTap;
  final String? subtitle;

  const HealthFeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.onTap,
    this.subtitle,
  });

  @override
  State<HealthFeatureCard> createState() => _HealthFeatureCardState();
}

class _HealthFeatureCardState extends State<HealthFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // hàm initState để khởi tạo AnimationController và Tween cho hiệu ứng nhấn
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  // hàm giải phóng tài nguyên
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;

    // Màu nền icon và accent theo chế độ sáng/tối
    final iconBg = isDark
        ? widget.color.withOpacity(0.18)
        : widget.color.withOpacity(0.13);
    final gradientStart = isDark
        ? widget.color.withOpacity(0.12)
        : widget.color.withOpacity(0.07);
    final borderColor = isDark
        ? widget.color.withOpacity(0.25)
        : widget.color.withOpacity(0.18);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          (widget.onTap ?? () => Navigator.pushNamed(context, widget.route))();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(isDark ? 0.08 : 0.13),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Gradient nền nhẹ góc trên trái
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  height: 70,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [gradientStart, Colors.transparent],
                      ),
                    ),
                  ),
                ),

                // Vòng trang trí lớn góc phải dưới
                Positioned(
                  right: -22,
                  bottom: -22,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withOpacity(isDark ? 0.08 : 0.06),
                    ),
                  ),
                ),

                // Nội dung chính
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hàng trên: icon + mũi tên
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 22,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: widget.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_outward_rounded,
                              size: 14,
                              color: widget.color.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // ── Tiêu đề
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 5),

                      // ── Subtitle với dấu chấm màu
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: widget.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.subtitle ?? 'Theo dõi',
                            style: TextStyle(
                              color: widget.color.withOpacity(0.85),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
