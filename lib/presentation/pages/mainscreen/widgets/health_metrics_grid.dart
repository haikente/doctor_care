import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/presentation/bloc/hba1c/hba1c_cubit.dart';
import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class HealthMetricsGrid extends StatelessWidget {
  const HealthMetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Chỉ số sức khỏe",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary(context),
                ),
              ),
            ],
          ),
          const Gap(10),
          BlocBuilder<BloodPressureCubit, BloodPressureState>(
            builder: (context, bpState) {
              String bpValue = "--/--";

              if (bpState is BloodPressureLoaded &&
                  bpState.records.isNotEmpty) {
                final sortedRecords = List.of(bpState.records)
                  ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
                final latest = sortedRecords.first;
                bpValue = "${latest.systolic}/${latest.diastolic}";
              }

              return BlocBuilder<Hba1cCubit, Hba1cState>(
                builder: (context, hba1cState) {
                  String hba1cValue = "--%";

                  if (hba1cState is Hba1cLoaded &&
                      hba1cState.hba1cRecords.isNotEmpty) {
                    final sortedRecords = List.of(hba1cState.hba1cRecords)
                      ..sort((a, b) => b.date.compareTo(a.date));
                    hba1cValue =
                        "${sortedRecords.first.value.toStringAsFixed(1)}%";
                  }

                  return BlocBuilder<TemperatureCubit, TemperatureState>(
                    builder: (context, tempState) {
                      String tempValue = "--°C";
                      if (tempState is TemperatureLoaded &&
                          tempState.temperatures.isNotEmpty) {
                        final sortedRecords = List.of(tempState.temperatures)
                          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
                        tempValue =
                            "${sortedRecords.first.value.toStringAsFixed(1)}°C";
                      }

                      return BlocBuilder<Spo2heartrateBloc, Spo2heartrateState>(
                        builder: (context, spo2State) {
                          String spo2Value = "--";
                          String spo2Unit = "%";
                          if (spo2State is Spo2heartrateLoaded &&
                              spo2State.records.isNotEmpty) {
                            final sortedRecords = List.of(spo2State.records)
                              ..sort(
                                (a, b) => b.timestamp.compareTo(a.timestamp),
                              );
                            final latest = sortedRecords.first;
                            spo2Value = "${latest.spo2}";
                            spo2Unit = "%";
                          }

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1, // Taller cards
                            padding: EdgeInsets.zero,
                            children: [
                              _buildMetricCard(
                                context,
                                title: "Huyết áp",
                                value: bpValue,
                                unit: "mmHg",
                                icon: Icons.favorite,
                                iconColor: Colors.red.shade400,
                                bgColor: Colors.red.shade50,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/bloodpressure',
                                ),
                              ),
                              _buildMetricCard(
                                context,
                                title: "Chỉ số HbA1c",
                                value: hba1cValue,
                                unit: "%",
                                icon: Icons.water_drop,
                                iconColor: Colors.orange.shade400,
                                bgColor: Colors.orange.shade50,
                                onTap: () =>
                                    Navigator.pushNamed(context, '/hba1c'),
                              ),
                              _buildMetricCard(
                                context,
                                title: "SpO2 & Nhịp tim",
                                value: spo2Value,
                                unit: spo2Unit,
                                icon: Icons.monitor_heart,
                                iconColor: Colors.pink.shade400,
                                bgColor: Colors.pink.shade50,
                                onTap: () =>
                                    Navigator.pushNamed(context, '/spo2heart'),
                              ),
                              _buildMetricCard(
                                context,
                                title: "Nhiệt độ",
                                value: tempValue,
                                unit: "",
                                icon: Icons.thermostat,
                                iconColor: Colors.blue.shade400,
                                bgColor: Colors.blue.shade50,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/temperature',
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? bgColor.withOpacity(0.15)
                        : bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: AppColor.onSurface(context),
                  size: 20,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: AppColor.textSecondary(context),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Gap(4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.textSecondary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
