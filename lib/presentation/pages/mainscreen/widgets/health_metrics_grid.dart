import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/presentation/bloc/hba1c/hba1c_cubit.dart';
import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

enum _MetricStatus { normal, caution, danger, noData }

extension _MetricStatusExt on _MetricStatus {
  Color get valueColor {
    switch (this) {
      case _MetricStatus.normal:
        return Colors.green.shade500;
      case _MetricStatus.caution:
        return Colors.orange.shade500;
      case _MetricStatus.danger:
        return Colors.red.shade500;
      case _MetricStatus.noData:
        return Colors.grey;
    }
  }

  Color get badgeColor {
    switch (this) {
      case _MetricStatus.normal:
        return Colors.green.shade400;
      case _MetricStatus.caution:
        return Colors.orange.shade400;
      case _MetricStatus.danger:
        return Colors.red.shade400;
      case _MetricStatus.noData:
        return Colors.grey.shade400;
    }
  }

  IconData get badgeIcon {
    switch (this) {
      case _MetricStatus.normal:
        return Icons.check_circle_rounded;
      case _MetricStatus.caution:
        return Icons.warning_amber_rounded;
      case _MetricStatus.danger:
        return Icons.error_rounded;
      case _MetricStatus.noData:
        return Icons.remove_circle_outline_rounded;
    }
  }

  String get label {
    switch (this) {
      case _MetricStatus.normal:
        return 'Bình thường';
      case _MetricStatus.caution:
        return 'Chú ý';
      case _MetricStatus.danger:
        return 'Nguy hiểm';
      case _MetricStatus.noData:
        return 'Chưa có';
    }
  }
}

_MetricStatus _bpStatus(int systolic, int diastolic) {
  if (systolic > 140 || diastolic > 90) return _MetricStatus.danger;
  if (systolic >= 120 || diastolic >= 80) return _MetricStatus.caution;
  return _MetricStatus.normal;
}

_MetricStatus _hba1cStatus(double value) {
  if (value >= 6.5) return _MetricStatus.danger;
  if (value >= 5.7) return _MetricStatus.caution;
  return _MetricStatus.normal;
}

_MetricStatus _spo2Status(int spo2) {
  if (spo2 < 90) return _MetricStatus.danger;
  if (spo2 < 95) return _MetricStatus.caution;
  return _MetricStatus.normal;
}

_MetricStatus _tempStatus(double temp) {
  if (temp > 38.5 || temp < 35.0) return _MetricStatus.danger;
  if (temp > 37.5 || temp < 36.0) return _MetricStatus.caution;
  return _MetricStatus.normal;
}

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
                context.tr('health_metrics_title'),
                style: TextStyle(
                  fontSize: 16,
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
              _MetricStatus bpStatus = _MetricStatus.noData;

              if (bpState is BloodPressureLoaded &&
                  bpState.records.isNotEmpty) {
                final sorted = List.of(bpState.records)
                  ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
                final latest = sorted.first;
                bpValue = "${latest.systolic}/${latest.diastolic}";
                bpStatus = _bpStatus(latest.systolic, latest.diastolic);
              }

              return BlocBuilder<Hba1cCubit, Hba1cState>(
                builder: (context, hba1cState) {
                  String hba1cValue = "--";
                  _MetricStatus hba1cStatus = _MetricStatus.noData;

                  if (hba1cState is Hba1cLoaded &&
                      hba1cState.hba1cRecords.isNotEmpty) {
                    final sorted = List.of(hba1cState.hba1cRecords)
                      ..sort((a, b) => b.date.compareTo(a.date));
                    final val = sorted.first.value;
                    hba1cValue = val.toStringAsFixed(1);
                    hba1cStatus = _hba1cStatus(val);
                  }

                  return BlocBuilder<TemperatureCubit, TemperatureState>(
                    builder: (context, tempState) {
                      String tempValue = "--";
                      _MetricStatus tempStatus = _MetricStatus.noData;

                      if (tempState is TemperatureLoaded &&
                          tempState.temperatures.isNotEmpty) {
                        final sorted = List.of(tempState.temperatures)
                          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
                        final val = sorted.first.value;
                        tempValue = val.toStringAsFixed(1);
                        tempStatus = _tempStatus(val);
                      }

                      return BlocBuilder<Spo2heartrateBloc, Spo2heartrateState>(
                        builder: (context, spo2State) {
                          String spo2Value = "--";
                          _MetricStatus spo2Status = _MetricStatus.noData;

                          if (spo2State is Spo2heartrateLoaded &&
                              spo2State.records.isNotEmpty) {
                            final sorted = List.of(spo2State.records)
                              ..sort(
                                (a, b) => b.timestamp.compareTo(a.timestamp),
                              );
                            final latest = sorted.first;
                            spo2Value = "${latest.spo2}";
                            spo2Status = _spo2Status(latest.spo2);
                          }

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1,
                            padding: EdgeInsets.zero,
                            children: [
                              _buildMetricCard(
                                context,
                                title: context.tr('blood_pressure'),
                                value: bpValue,
                                unit: context.tr('unit_mmhg'),
                                icon: Icons.favorite_rounded,
                                iconColor: Colors.red.shade400,
                                bgColor: Colors.red.shade50,
                                status: bpStatus,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/bloodpressure',
                                ),
                              ),
                              _buildMetricCard(
                                context,
                                title: context.tr('hba1c_index'),
                                value: hba1cValue,
                                unit: context.tr('unit_percent'),
                                icon: Icons.water_drop_rounded,
                                iconColor: Colors.orange.shade400,
                                bgColor: Colors.orange.shade50,
                                status: hba1cStatus,
                                onTap: () =>
                                    Navigator.pushNamed(context, '/hba1c'),
                              ),
                              _buildMetricCard(
                                context,
                                title: context.tr('spo2_heart_rate'),
                                value: spo2Value,
                                unit: '%',
                                icon: Icons.monitor_heart_rounded,
                                iconColor: Colors.pink.shade400,
                                bgColor: Colors.pink.shade50,
                                status: spo2Status,
                                onTap: () =>
                                    Navigator.pushNamed(context, '/spo2heart'),
                              ),
                              _buildMetricCard(
                                context,
                                title: context.tr('temperature'),
                                value: tempValue,
                                unit: '°C',
                                icon: Icons.thermostat_rounded,
                                iconColor: Colors.blue.shade400,
                                bgColor: Colors.blue.shade50,
                                status: tempStatus,
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
    required _MetricStatus status,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Border đổi màu theo trạng thái (trừ noData)
    final borderColor = status == _MetricStatus.noData
        ? Theme.of(context).dividerColor.withOpacity(0.2)
        : status.badgeColor.withOpacity(0.35);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: borderColor, width: 1.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row trên: icon + badge trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withOpacity(0.15) : bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                // Badge trạng thái
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: status.badgeColor.withOpacity(isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        status.badgeIcon,
                        size: 11,
                        color: status.badgeColor,
                      ),
                      const Gap(3),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: status.badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ── Tên chỉ số
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: AppColor.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(4),

            // ── Giá trị + đơn vị (màu theo trạng thái)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: status.valueColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const Gap(4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.textSecondary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
