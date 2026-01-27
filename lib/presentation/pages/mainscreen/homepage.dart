import 'package:doctor_care/presentation/pages/mainscreen/widgets/health_metrics_grid.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/health_status_card.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/home_header.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/quick_actions_section.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero, // Padding handled inside widgets
        child: Column(
          children: [
            const HomeHeader(),
            const Gap(24),
            const HealthStatusCard(),
            const Gap(30),
            const HealthMetricsGrid(),
            const Gap(30),
            const QuickActionsSection(),
            const Gap(100), // Bottom padding for scrolling
          ],
        ),
      ),
    );
  }
}
