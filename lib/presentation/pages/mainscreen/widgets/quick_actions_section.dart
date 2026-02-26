import 'package:doctor_care/core/pages/app_color.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tiện ích nhanh",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary(context),
            ),
          ),
          const Gap(16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _buildActionItem(
                  context,
                  title: "Đo ngay",
                  icon: Icons.add_circle_outline,
                  color: Colors.blue,
                  onTap: () {
                    // TODO: Show bottom sheet
                  },
                ),
                const Gap(16),
                _buildActionItem(
                  context,
                  title: "Lịch sử",
                  icon: Icons.history_rounded,
                  color: Colors.orange,
                  onTap: () {},
                ),
                const Gap(16),
                _buildActionItem(
                  context,
                  title: "Đặt lịch",
                  icon: Icons.calendar_today_rounded,
                  color: Colors.purple,
                  onTap: () {},
                ),
                const Gap(16),
                _buildActionItem(
                  context,
                  title: "Báo cáo",
                  icon: Icons.bar_chart_rounded,
                  color: Colors.green,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Gap(8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
