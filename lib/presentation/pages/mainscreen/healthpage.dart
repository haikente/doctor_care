import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:doctor_care/presentation/bloc/family_profile/family_profile_cubit.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/daily_health_tip.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/health_feature_card.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/quick_health_stats.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/weekly_activity_chart.dart';
import 'package:doctor_care/presentation/pages/screens/FamilyProfile/family_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class Healthpage extends StatelessWidget {
  const Healthpage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade400,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 49,
                      height: 49,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: BlocBuilder<FamilyProfileCubit, FamilyProfileState>(
                          builder: (context, fpState) {
                            String initials = "ND";
                            if (fpState is FamilyProfileLoaded &&
                                fpState.activeProfile != null) {
                              initials = fpState.activeProfile!.initials;
                            } else {
                              // Fallback to auth user
                              final authState = context.watch<AuthBloc>().state;
                              if (authState is Authenticated) {
                                final name =
                                    authState.user.fullName ??
                                    authState.user.email;
                                final parts = name.trim().split(RegExp(r'\s+'));
                                if (parts.length >= 2) {
                                  initials =
                                      "${parts[parts.length - 2][0]}${parts.last[0]}"
                                          .toUpperCase();
                                } else if (parts.isNotEmpty) {
                                  initials = parts.first
                                      .substring(
                                        0,
                                        parts.first.length >= 2 ? 2 : 1,
                                      )
                                      .toUpperCase();
                                }
                              }
                            }
                            return Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr('tracking_target'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Gap(2),
                          BlocBuilder<FamilyProfileCubit, FamilyProfileState>(
                            builder: (context, fpState) {
                              String displayName = context.tr('user');
                              String subLabel = context.tr('health_tracking');
                              if (fpState is FamilyProfileLoaded &&
                                  fpState.activeProfile != null) {
                                displayName = fpState.activeProfile!.name;
                                subLabel =
                                    fpState.activeProfile!.relationshipLabel;
                              } else {
                                final authState = context
                                    .watch<AuthBloc>()
                                    .state;
                                if (authState is Authenticated) {
                                  displayName =
                                      authState.user.fullName ??
                                      context.tr('user');
                                }
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Gap(2),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        right: 8,
                                        top: 2,
                                        bottom: 2,
                                      ),
                                      child: Text(
                                        subLabel,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.white.withOpacity(0.85),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FamilyProfileScreen(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.repeat_outlined,
                        color: Colors.white.withOpacity(0.9),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Tổng quan hôm nay ---
              const Gap(20),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(10),
                  Text(
                    context.tr('today_overview'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textSecondary(context),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const Gap(14),
              const QuickHealthStats(),

              // --- Biểu đồ tuần ---
              const Gap(24),
              const WeeklyActivityChart(),

              // --- Lời khuyên sức khoẻ ---
              const Gap(24),
              const DailyHealthTip(),

              // --- Các chỉ số sức khoẻ ---
              const Gap(24),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(10),
                  Text(
                    context.tr('health_metrics'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textSecondary(context),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const Gap(24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  HealthFeatureCard(
                    title: context.tr('blood_pressure'),
                    subtitle: 'mmHg',
                    icon: Icons.bloodtype_outlined,
                    color: const Color(0xFFE53935),
                    route: '/bloodpressure',
                  ),
                  HealthFeatureCard(
                    title: context.tr('hba1c_index'),
                    subtitle: '%',
                    icon: Icons.medical_information_outlined,
                    color: const Color(0xFFF57C00),
                    route: '/hba1c',
                  ),
                  HealthFeatureCard(
                    title: context.tr('temperature'),
                    subtitle: '°C',
                    icon: Icons.thermostat_outlined,
                    color: const Color(0xFF43A047),
                    route: '/temperature',
                  ),
                  HealthFeatureCard(
                    title: context.tr('spo2_heart_rate'),
                    subtitle: '% / ${context.tr('unit_bpm')}',
                    icon: Icons.favorite_border_rounded,
                    color: const Color(0xFF8E24AA),
                    route: '/spo2heart',
                  ),
                  HealthFeatureCard(
                    title: context.tr('bmi_weight'),
                    subtitle: 'kg/m²',
                    icon: Icons.monitor_weight_outlined,
                    color: const Color(0xFF1E88E5),
                    route: '/bmiweight',
                  ),
                  HealthFeatureCard(
                    title: context.tr('water_intake'),
                    subtitle: context.tr('unit_ml'),
                    icon: Icons.local_drink_outlined,
                    color: const Color(0xFF039BE5),
                    route: '/waterintake',
                  ),
                  HealthFeatureCard(
                    title: context.tr('blood_sugar'),
                    subtitle: 'mg/dL',
                    icon: Icons.water_drop_outlined,
                    color: const Color(0xFF00897B),
                    route: '/bloodsugar',
                  ),
                  HealthFeatureCard(
                    title: context.tr('sleep'),
                    subtitle: context.tr('unit_hour'),
                    icon: Icons.bedtime_outlined,
                    color: const Color(0xFF3949AB),
                    route: '/sleep',
                  ),
                  HealthFeatureCard(
                    title: context.tr('steps'),
                    subtitle: context.tr('steps_unit'),
                    icon: Icons.directions_walk_rounded,
                    color: const Color(0xFF2E7D32),
                    route: '/stepcounter',
                  ),
                  HealthFeatureCard(
                    title: context.tr('cholesterol_label'),
                    subtitle: 'mg/dL',
                    icon: Icons.bloodtype_rounded,
                    color: const Color(0xFF5E35B1),
                    route: '/cholesterol',
                  ),
                ],
              ),
              Gap(100),
            ],
          ),
        ),
      ),
    );
  }
}
