import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class HealthStatusCard extends StatelessWidget {
  const HealthStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.95), const Color(0xFF20A386)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        context.tr('health_status_title'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/health-overview');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                context.tr('details'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Gap(4),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),

                  // Quick Stats Row
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

                      return BlocBuilder<TemperatureCubit, TemperatureState>(
                        builder: (context, tempState) {
                          String tempValue = "--°C";
                          if (tempState is TemperatureLoaded &&
                              tempState.temperatures.isNotEmpty) {
                            final sortedRecords =
                                List.of(tempState.temperatures)..sort(
                                  (a, b) => b.timestamp.compareTo(a.timestamp),
                                );
                            tempValue =
                                "${sortedRecords.first.value.toStringAsFixed(1)}°C";
                          }

                          return BlocBuilder<
                            Spo2heartrateBloc,
                            Spo2heartrateState
                          >(
                            builder: (context, spo2State) {
                              String spo2Value = "--%";
                              if (spo2State is Spo2heartrateLoaded &&
                                  spo2State.records.isNotEmpty) {
                                final sortedRecords = List.of(spo2State.records)
                                  ..sort(
                                    (a, b) =>
                                        b.timestamp.compareTo(a.timestamp),
                                  );
                                spo2Value = "${sortedRecords.first.spo2}%";
                              }

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildMiniStat(
                                      context.tr('blood_pressure'),
                                      bpValue,
                                      Icons.bloodtype,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 30,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    _buildMiniStat(
                                      "SpO2",
                                      spo2Value,
                                      Icons.air,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 30,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    _buildMiniStat(
                                      context.tr('temperature'),
                                      tempValue,
                                      Icons.thermostat,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8), size: 14),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Gap(6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
