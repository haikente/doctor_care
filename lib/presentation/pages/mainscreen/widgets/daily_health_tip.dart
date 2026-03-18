import 'package:flutter/material.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';

class DailyHealthTip extends StatelessWidget {
  const DailyHealthTip({super.key});

  // Health tips rotate daily
  static final List<_TipData> _tips = [
    _TipData(
      icon: Icons.water_drop_outlined,
      titleKey: 'tip_water_title',
      contentKey: 'tip_water_desc',
      gradient: [Color(0xFF039BE5), Color(0xFF0277BD)],
    ),
    _TipData(
      icon: Icons.directions_walk_rounded,
      titleKey: 'tip_walk_title',
      contentKey: 'tip_walk_desc',
      gradient: [Color(0xFF43A047), Color(0xFF2E7D32)],
    ),
    _TipData(
      icon: Icons.bedtime_outlined,
      titleKey: 'tip_sleep_title',
      contentKey: 'tip_sleep_desc',
      gradient: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
    ),
    _TipData(
      icon: Icons.restaurant_outlined,
      titleKey: 'tip_eat_title',
      contentKey: 'tip_eat_desc',
      gradient: [Color(0xFFF57C00), Color(0xFFE65100)],
    ),
    _TipData(
      icon: Icons.self_improvement_outlined,
      titleKey: 'tip_relax_title',
      contentKey: 'tip_relax_desc',
      gradient: [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
    ),
    _TipData(
      icon: Icons.monitor_heart_outlined,
      titleKey: 'tip_bp_title',
      contentKey: 'tip_bp_desc',
      gradient: [Color(0xFFE53935), Color(0xFFC62828)],
    ),
    _TipData(
      icon: Icons.fitness_center_outlined,
      titleKey: 'tip_exercise_title',
      contentKey: 'tip_exercise_desc',
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
                          context.tr('tip_today'),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr(tip.titleKey),
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
                  context.tr(tip.contentKey),
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
  final String titleKey;
  final String contentKey;
  final List<Color> gradient;

  const _TipData({
    required this.icon,
    required this.titleKey,
    required this.contentKey,
    required this.gradient,
  });
}
