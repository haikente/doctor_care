import 'package:flutter/material.dart';

class DailyHealthTip extends StatelessWidget {
  const DailyHealthTip({super.key});

  // Health tips rotate daily
  static final List<_TipData> _tips = [
    _TipData(
      icon: Icons.water_drop_outlined,
      title: 'Uống đủ nước',
      content:
          'Hãy uống ít nhất 2 lít nước mỗi ngày để duy trì sức khoẻ và giúp cơ thể vận hành tốt nhất.',
      gradient: [Color(0xFF039BE5), Color(0xFF0277BD)],
    ),
    _TipData(
      icon: Icons.directions_walk_rounded,
      title: 'Đi bộ mỗi ngày',
      content:
          'Đi bộ 30 phút mỗi ngày giúp giảm nguy cơ bệnh tim mạch và cải thiện tâm trạng.',
      gradient: [Color(0xFF43A047), Color(0xFF2E7D32)],
    ),
    _TipData(
      icon: Icons.bedtime_outlined,
      title: 'Ngủ đủ giấc',
      content:
          'Ngủ 7-8 tiếng mỗi đêm giúp cơ thể phục hồi và tăng cường hệ miễn dịch.',
      gradient: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
    ),
    _TipData(
      icon: Icons.restaurant_outlined,
      title: 'Ăn uống lành mạnh',
      content:
          'Bổ sung rau xanh và trái cây vào bữa ăn hàng ngày để cung cấp vitamin thiết yếu.',
      gradient: [Color(0xFFF57C00), Color(0xFFE65100)],
    ),
    _TipData(
      icon: Icons.self_improvement_outlined,
      title: 'Thư giãn tinh thần',
      content:
          'Dành 10 phút mỗi ngày để thiền hoặc hít thở sâu giúp giảm stress hiệu quả.',
      gradient: [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
    ),
    _TipData(
      icon: Icons.monitor_heart_outlined,
      title: 'Theo dõi huyết áp',
      content:
          'Đo huyết áp định kỳ để phát hiện sớm các vấn đề tim mạch và điều chỉnh lối sống.',
      gradient: [Color(0xFFE53935), Color(0xFFC62828)],
    ),
    _TipData(
      icon: Icons.fitness_center_outlined,
      title: 'Tập thể dục',
      content:
          'Tập thể dục ít nhất 150 phút/tuần để tăng cường sức khoẻ tim mạch và xương khớp.',
      gradient: [Color(0xFF00897B), Color(0xFF00695C)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Choose tip based on day of year
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    final tip = _tips[dayOfYear % _tips.length];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tip.gradient,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: tip.gradient.first.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(tip.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Lời khuyên hôm nay',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tip.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  tip.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
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

class _TipData {
  final IconData icon;
  final String title;
  final String content;
  final List<Color> gradient;

  const _TipData({
    required this.icon,
    required this.title,
    required this.content,
    required this.gradient,
  });
}
