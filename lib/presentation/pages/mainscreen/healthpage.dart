import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Healthpage extends StatelessWidget {
  const Healthpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        title: "Sức khoẻ" , centerTitle: true,),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: HealthFeatureCard(
                    title: 'Huyết áp',
                    icon: Icons.bloodtype_outlined,
                    color: Colors.red.shade400,
                    route: '/bloodpressure',
                  ),
                ),
                    Gap(15),
                    SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: HealthFeatureCard(
                      title: 'Chỉ số HbA1c',
                      icon: Icons.medical_information_outlined,
                      color: Colors.orange.shade400,
                      route: '/hba1c',
                    ),
                  ),
                  Gap(15),
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: HealthFeatureCard(
                      title: 'Nhiệt độ',
                      icon: Icons.thermostat_outlined,
                      color: Colors.green.shade400,
                      route: '/temperature',
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
              color.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
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
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
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