import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:doctor_care/presentation/bloc/family_profile/family_profile_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/FamilyProfile/family_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class Healthpage extends StatelessWidget {
  const Healthpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Gap(25),
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
                            if (fpState is FamilyProfileLoaded && fpState.activeProfile != null) {
                              initials = fpState.activeProfile!.initials;
                            } else {
                              // Fallback to auth user
                              final authState = context.watch<AuthBloc>().state;
                              if (authState is Authenticated) {
                                final name = authState.user.fullName ?? authState.user.email;
                                final parts = name.trim().split(RegExp(r'\s+'));
                                if (parts.length >= 2) {
                                  initials = "${parts[parts.length - 2][0]}${parts.last[0]}".toUpperCase();
                                } else if (parts.isNotEmpty) {
                                  initials = parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
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
                          "Đối tượng theo dõi",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(2),
                        BlocBuilder<FamilyProfileCubit, FamilyProfileState>(
                          builder: (context, fpState) {
                            String displayName = "Người dùng";
                            String subLabel = "Theo dõi sức khoẻ tổng quát";
                            if (fpState is FamilyProfileLoaded && fpState.activeProfile != null) {
                              displayName = fpState.activeProfile!.name;
                              subLabel = fpState.activeProfile!.relationshipLabel;
                            } else {
                              final authState = context.watch<AuthBloc>().state;
                              if (authState is Authenticated) {
                                displayName = authState.user.fullName ?? "Người dùng";
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
                                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
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
                        MaterialPageRoute(builder: (_) => const FamilyProfileScreen()),
                      );
                    },
                    child: Icon(Icons.repeat_outlined, color: Colors.white.withOpacity(0.9), size: 20,)),
                  ],
                ),
              ),
              Gap(20),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Các chỉ số sức khoẻ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Gap(20),
              SizedBox(
                width: double.infinity,
                height: 120,
                child: HealthFeatureCard(
                  title: 'Huyết áp',
                  icon: Icons.bloodtype_outlined,
                  color: Colors.red,
                  route: '/bloodpressure',
                ),
              ),
              Gap(15),
              SizedBox(
                width: double.infinity,
                height: 120,
                child: HealthFeatureCard(
                  title: 'Chỉ số HbA1c',
                  icon: Icons.medical_information_outlined,
                  color: Colors.orange,
                  route: '/hba1c',
                ),
              ),
              Gap(15),
              SizedBox(
                width: double.infinity,
                height: 120,
                child: HealthFeatureCard(
                  title: 'Nhiệt độ',
                  icon: Icons.thermostat_outlined,
                  color: Colors.green,
                  route: '/temperature',
                ),
              ),
              Gap(15),
              SizedBox(
                width: double.infinity,
                height: 120,
                child: HealthFeatureCard(
                  title: 'SPO2 & Nhịp tim',
                  icon: Icons.water_drop_outlined,
                  color: Colors.purple,
                  route: '/spo2heart',
                ),
              ),
              Gap(15),
              SizedBox(
                width: double.infinity,
                height: 120,
                child: HealthFeatureCard(
                  title: 'BMI & Cân nặng',
                  icon: Icons.monitor_weight_outlined,
                  color: Colors.blue,
                  route: '/bmiweight',
                ),
              ),
              Gap(15),
              SizedBox(
                width: double.infinity,
                height: 120,
                child: HealthFeatureCard(
                  title: 'Lượng nước uống',
                  icon: Icons.local_drink,
                  color: Colors.lightBlue,
                  route: '/waterintake',
                ),
              ),
              Gap(15),
              SizedBox(
                width: double.infinity,
                height: 120,
                child: HealthFeatureCard(
                  title: 'Đường huyết',
                  icon: Icons.water_drop_outlined,
                  color: Colors.teal,
                  route: '/bloodsugar',
                ),
              ),
              Gap(15),
              SizedBox(
                width: double.infinity,
                height: 120,
                child: HealthFeatureCard(
                  title: 'Giấc ngủ',
                  icon: Icons.bedtime_outlined,
                  color: Colors.indigo,
                  route: '/sleep',
                ),
              ),
              Gap(15),
              SizedBox(
                width: double.infinity,
                height: 120,
                child: HealthFeatureCard(
                  title: 'Bước chân',
                  icon: Icons.directions_walk,
                  color: Colors.green,
                  route: '/stepcounter',
                ),
              ),
              Gap(15),
              SizedBox(
                width: double.infinity,
                height: 120,
                child: HealthFeatureCard(
                  title: 'Cholesterol',
                  icon: Icons.bloodtype,
                  color: Colors.deepPurple,
                  route: '/cholesterol',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthFeatureCard extends StatelessWidget {
  final String title;
  //final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final VoidCallback? onTap;

  const HealthFeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
            color,
            color.withOpacity(.5),
            color.withOpacity(.3),
            
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),

                  Gap(16),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Spacer(),
                  Row(
                    children: [
                      Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                      Gap(4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
