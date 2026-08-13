import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/presentation/bloc/hba1c/hba1c_cubit.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Chi tiết sức khỏe tổng quan
class HealthOverviewScreen extends StatefulWidget {
  const HealthOverviewScreen({super.key});

  @override
  State<HealthOverviewScreen> createState() => _HealthOverviewScreenState();
}

class _HealthOverviewScreenState extends State<HealthOverviewScreen> {
  String _selectedPeriod = 'week';
  
  get primary => Theme.of(context).colorScheme.primary;

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'today':
        return DateTime(now.year, now.month, now.day);
      case 'week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      case 'month':
        return DateTime(now.year, now.month, 1);
      case 'year':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(1970);
    }
  }

  bool _isRecordInPeriod(DateTime date) {
    var startDate = _getStartDate();
    return date.isAfter(startDate) || date.isAtSameMomentAs(startDate);
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    return date.isAfter(startDate) || date.isAtSameMomentAs(startDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: context.tr('health_overview_title'),
        centerTitle: true,
      ),
      body: BlocBuilder<BloodPressureCubit, BloodPressureState>(
        builder: (context, bpState) {
          return BlocBuilder<Hba1cCubit, Hba1cState>(
            builder: (context, hba1cState) {
              return BlocBuilder<TemperatureCubit, TemperatureState>(
                builder: (context, tempState) {
                  return BlocBuilder<Spo2heartrateBloc, Spo2heartrateState>(
                    builder: (context, spo2State) {
                      return _buildBodyContent(
                        bpState,
                        hba1cState,
                        tempState,
                        spo2State,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(
    BloodPressureState bpState,
    Hba1cState hba1cState,
    TemperatureState tempState,
    Spo2heartrateState spo2State,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallStatusCard(bpState, hba1cState, tempState, spo2State),
          const Gap(20),
          _buildPeriodSelector(),
          const Gap(20),
          _buildHealthMetricsSummary(bpState, hba1cState, tempState, spo2State),
          const Gap(20),
          _buildDetailedMetrics(bpState, hba1cState, tempState, spo2State),
          const Gap(20),
          _buildHealthRecommendations(
            bpState,
            hba1cState,
            tempState,
            spo2State,
          ),
          const Gap(60),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredBp(BloodPressureState state) {
    if (state is BloodPressureLoaded) {
      return state.records
          .where((e) => _isRecordInPeriod(e.timestamp))
          .toList();
    }
    return [];
  }

  List<dynamic> _getFilteredHba1c(Hba1cState state) {
    if (state is Hba1cLoaded) {
      return state.hba1cRecords
          .where((e) => _isRecordInPeriod(e.date))
          .toList();
    }
    return [];
  }

  List<dynamic> _getFilteredTemp(TemperatureState state) {
    if (state is TemperatureLoaded) {
      return state.temperatures
          .where((e) => _isRecordInPeriod(e.timestamp))
          .toList();
    }
    return [];
  }

  List<dynamic> _getFilteredSpo2(Spo2heartrateState state) {
    if (state is Spo2heartrateLoaded) {
      return state.records
          .where((e) => _isRecordInPeriod(e.timestamp))
          .toList();
    }
    return [];
  }

  int _getTotalMeasurements(
    BloodPressureState bp,
    Hba1cState hba1c,
    TemperatureState temp,
    Spo2heartrateState spo2,
  ) {
    int total = 0;
    if (bp is BloodPressureLoaded) {
      total += bp.records.length;
    }
    if (hba1c is Hba1cLoaded) {
      total += hba1c.hba1cRecords.length;
    }
    if (temp is TemperatureLoaded) {
      total += temp.temperatures.length;
    }
    if (spo2 is Spo2heartrateLoaded) {
      total += spo2.records.length;
    }
    return total;
  }

  int _getThisWeekMeasurements(
    BloodPressureState bp,
    Hba1cState hba1c,
    TemperatureState temp,
    Spo2heartrateState spo2,
  ) {
    int total = 0;
    if (bp is BloodPressureLoaded) {
      total += bp.records.where((e) => _isThisWeek(e.timestamp)).length;
    }
    if (hba1c is Hba1cLoaded) {
      total += hba1c.hba1cRecords.where((e) => _isThisWeek(e.date)).length;
    }
    if (temp is TemperatureLoaded) {
      total += temp.temperatures.where((e) => _isThisWeek(e.timestamp)).length;
    }
    if (spo2 is Spo2heartrateLoaded) {
      total += spo2.records.where((e) => _isThisWeek(e.timestamp)).length;
    }
    return total;
  }

  int _getFilteredWarnings(
    BloodPressureState bp,
    Hba1cState hba1c,
    TemperatureState temp,
    Spo2heartrateState spo2,
  ) {
    int w = 0;
    var bpList = _getFilteredBp(bp);
    for (var r in bpList) {
      if (r.systolic >= 140 || r.systolic < 90) w++;
    }
    var hbList = _getFilteredHba1c(hba1c);
    for (var r in hbList) {
      if (r.value >= 5.7) w++;
    }
    var tempList = _getFilteredTemp(temp);
    for (var r in tempList) {
      if (r.value < 36.1 || r.value > 37.2) w++;
    }
    var spo2List = _getFilteredSpo2(spo2);
    for (var r in spo2List) {
      if (r.spo2 < 95) w++;
    }
    return w;
  }

  Widget _buildOverallStatusCard(
    BloodPressureState bp,
    Hba1cState hba1c,
    TemperatureState temp,
    Spo2heartrateState spo2,
  ) {
    int total = _getTotalMeasurements(bp, hba1c, temp, spo2);
    int week = _getThisWeekMeasurements(bp, hba1c, temp, spo2);
    int warnings = _getFilteredWarnings(bp, hba1c, temp, spo2);
    String statusText = warnings == 0
        ? context.tr('good')
        : context.tr('status_attention');

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  warnings == 0 ? Icons.favorite : Icons.warning,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('health_status_title'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  warnings == 0 ? Icons.check_circle : Icons.error_outline,
                  color: warnings == 0
                      ? Colors.green.shade400
                      : Colors.red.shade400,
                  size: 20,
                ),
              ),
            ],
          ),
          const Gap(20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusItem(
                  context.tr('health_overview_measurements'),
                  '$total',
                  Icons.assessment,
                ),
                _buildDivider(),
                _buildStatusItem(
                  context.tr('this_week'),
                  '$week',
                  Icons.calendar_today,
                ),
                _buildDivider(),
                _buildStatusItem(
                  context.tr('health_overview_warnings'),
                  '$warnings',
                  Icons.warning_amber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        const Gap(6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 45,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['today', 'week', 'month', 'year'];
    final labels = {
      'today': context.tr('today'),
      'week': context.tr('this_week'),
      'month': context.tr('month'),
      'year': context.tr('health_overview_this_year'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: periods.map((period) {
            final isSelected = period == _selectedPeriod;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[period] ?? period,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHealthMetricsSummary(
    BloodPressureState bp,
    Hba1cState hba1c,
    TemperatureState temp,
    Spo2heartrateState spo2,
  ) {
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
              Gap(10),
              Text(
                context.tr('health_metrics_title'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Gap(16),
          Column(
            children: [
              _buildMetricCard(
                context.tr('blood_pressure'),
                _getBPValue(bp),
                'mmHg',
                Icons.favorite,
                Colors.red,
                _getBPStatus(bp),
              ),
              const Gap(12),
              _buildMetricCard(
                context.tr('hba1c_index'),
                _getHbA1cValue(hba1c),
                '%',
                Icons.water_drop,
                Colors.orange,
                _getHbA1cStatus(hba1c),
              ),
              const Gap(12),
              _buildMetricCard(
                'SpO2',
                _getSpO2Value(spo2),
                '%',
                Icons.air,
                Colors.pink,
                _getSpO2Status(spo2),
              ),
              const Gap(12),
              _buildMetricCard(
                context.tr('temperature'),
                _getTempValue(temp),
                '°C',
                Icons.thermostat,
                Colors.blue,
                _getTempStatus(temp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Gap(4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              context.tr(status),
              style: TextStyle(
                color: _getStatusColor(status),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics(
    BloodPressureState bp,
    Hba1cState hba1c,
    TemperatureState temp,
    Spo2heartrateState spo2,
  ) {
    int filteredTotal =
        _getFilteredBp(bp).length +
        _getFilteredHba1c(hba1c).length +
        _getFilteredTemp(temp).length +
        _getFilteredSpo2(spo2).length;
    int warnings = _getFilteredWarnings(bp, hba1c, temp, spo2);

    // Attempt to calculate average. Just a rough estimate per day:
    DateTime start = _getStartDate();
    DateTime now = DateTime.now();
    int days = now.difference(start).inDays.abs() + 1;
    if (days <= 0) days = 1;
    double avg = filteredTotal / days;

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
                context.tr('health_overview_detailed_stats'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildStatRow(
                  context.tr('health_overview_total_measurements'),
                  context.tr(
                    'health_overview_times_count',
                    params: {'count': '$filteredTotal'},
                  ),
                ),
                const Divider(height: 26, color: Colors.grey),
                _buildStatRow(
                  context.tr('health_overview_daily_average'),
                  context.tr(
                    'health_overview_times_count',
                    params: {'count': avg.toStringAsFixed(1)},
                  ),
                ),
                const Divider(height: 26, color: Colors.grey),
                _buildStatRow(
                  context.tr('health_overview_abnormal_data'),
                  '$warnings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthRecommendations(
    BloodPressureState bp,
    Hba1cState hba1c,
    TemperatureState temp,
    Spo2heartrateState spo2,
  ) {
    String bpStat = _getBPStatus(bp);
    String hba1cStat = _getHbA1cStatus(hba1c);
    String tempStat = _getTempStatus(temp);

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
                context.tr('health_recommendations'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Gap(16),
          if (bpStat == 'health_status_high' ||
              bpStat == 'health_status_slightly_high')
            _buildRecommendationCard(
              context.tr('health_overview_bp_warning_title'),
              context.tr('health_overview_bp_warning_desc'),
              Icons.warning,
              Colors.red,
            )
          else
            _buildRecommendationCard(
              context.tr('health_overview_bp_stable_title'),
              context.tr('health_overview_bp_stable_desc'),
              Icons.check_circle,
              Colors.green,
            ),

          const Gap(12),

          if (hba1cStat == 'blood_sugar_prediabetes' ||
              hba1cStat == 'blood_sugar_diabetes')
            _buildRecommendationCard(
              context.tr('health_overview_glucose_control_title'),
              context.tr('health_overview_glucose_control_desc'),
              Icons.warning,
              Colors.orange,
            )
          else
            _buildRecommendationCard(
              context.tr('health_overview_glucose_stable_title'),
              context.tr('health_overview_glucose_stable_desc'),
              Icons.info,
              Colors.blue,
            ),

          const Gap(12),

          if (tempStat == 'health_status_high')
            _buildRecommendationCard(
              context.tr('health_overview_fever_title'),
              context.tr('health_overview_fever_desc'),
              Icons.warning,
              Colors.red,
            )
          else
            _buildRecommendationCard(
              context.tr('health_overview_temperature_normal_title'),
              context.tr('health_overview_temperature_normal_desc'),
              Icons.thermostat,
              Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Gap(4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getBPValue(BloodPressureState state) {
    var recs = _getFilteredBp(state);
    if (recs.isNotEmpty) {
      final sorted = List.of(recs)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return '${sorted.first.systolic}/${sorted.first.diastolic}';
    }
    return '--/--';
  }

  String _getBPStatus(BloodPressureState state) {
    var recs = _getFilteredBp(state);
    if (recs.isNotEmpty) {
      final sorted = List.of(recs)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final systolic = sorted.first.systolic;
      if (systolic < 120 && systolic >= 90) return 'status_normal';
      if (systolic < 90) return 'health_status_low';
      if (systolic < 140) return 'health_status_slightly_high';
      return 'health_status_high';
    }
    return 'not_available';
  }

  String _getHbA1cValue(Hba1cState state) {
    var recs = _getFilteredHba1c(state);
    if (recs.isNotEmpty) {
      final sorted = List.of(recs)..sort((a, b) => b.date.compareTo(a.date));
      return sorted.first.value.toStringAsFixed(1);
    }
    return '--';
  }

  String _getHbA1cStatus(Hba1cState state) {
    var recs = _getFilteredHba1c(state);
    if (recs.isNotEmpty) {
      final sorted = List.of(recs)..sort((a, b) => b.date.compareTo(a.date));
      final value = sorted.first.value;
      if (value < 5.7) return 'status_normal';
      if (value < 6.5) return 'blood_sugar_prediabetes';
      return 'blood_sugar_diabetes';
    }
    return 'not_available';
  }

  String _getSpO2Value(Spo2heartrateState state) {
    var recs = _getFilteredSpo2(state);
    if (recs.isNotEmpty) {
      final sorted = List.of(recs)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sorted.first.spo2.toString();
    }
    return '--';
  }

  String _getSpO2Status(Spo2heartrateState state) {
    var recs = _getFilteredSpo2(state);
    if (recs.isNotEmpty) {
      final sorted = List.of(recs)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final spo2 = sorted.first.spo2;
      if (spo2 >= 95) return 'status_normal';
      if (spo2 >= 90) return 'health_status_slightly_low';
      return 'health_status_low';
    }
    return 'not_available';
  }

  String _getTempValue(TemperatureState state) {
    var recs = _getFilteredTemp(state);
    if (recs.isNotEmpty) {
      final sorted = List.of(recs)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sorted.first.value.toStringAsFixed(1);
    }
    return '--';
  }

  String _getTempStatus(TemperatureState state) {
    var recs = _getFilteredTemp(state);
    if (recs.isNotEmpty) {
      final sorted = List.of(recs)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final temp = sorted.first.value;
      if (temp >= 36.1 && temp <= 37.2) return 'status_normal';
      if (temp < 36.1) return 'health_status_low';
      return 'health_status_high';
    }
    return 'not_available';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'status_normal':
        return Colors.green;
      case 'health_status_slightly_high':
      case 'health_status_slightly_low':
      case 'blood_sugar_prediabetes':
        return Colors.orange;
      case 'health_status_high':
      case 'health_status_low':
      case 'blood_sugar_diabetes':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
