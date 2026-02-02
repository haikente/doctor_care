import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
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
  String _selectedPeriod = 'Tuần này';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: 'Sức khoẻ tổng quan',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Overall Status
            _buildOverallStatusCard(),

            const Gap(24),

            // Period Selector
            _buildPeriodSelector(),

            const Gap(24),

            // Health Metrics Summary
            _buildHealthMetricsSummary(),

            const Gap(24),

            // Detailed Metrics
            _buildDetailedMetrics(),

            const Gap(24),

            // Health Recommendations
            _buildHealthRecommendations(),

            const Gap(100),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatusCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tình trạng sức khỏe',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const Gap(4),
                    const Text(
                      'Tốt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 26,
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
                _buildStatusItem('Đo lường', '24', Icons.assessment),
                _buildDivider(),
                _buildStatusItem('Tuần này', '7', Icons.calendar_today),
                _buildDivider(),
                _buildStatusItem('Cảnh báo', '0', Icons.warning_amber),
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
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const Gap(8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Hôm nay', 'Tuần này', 'Tháng này', 'Năm nay'];
    
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
                    period,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  Widget _buildHealthMetricsSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chỉ số sức khỏe',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Gap(16),
          BlocBuilder<BloodPressureCubit, BloodPressureState>(
            builder: (context, bpState) {
              return BlocBuilder<Hba1cCubit, Hba1cState>(
                builder: (context, hba1cState) {
                  return BlocBuilder<TemperatureCubit, TemperatureState>(
                    builder: (context, tempState) {
                      return BlocBuilder<Spo2heartrateBloc, Spo2heartrateState>(
                        builder: (context, spo2State) {
                          return Column(
                            children: [
                              _buildMetricCard(
                                'Huyết áp',
                                _getBPValue(bpState),
                                'mmHg',
                                Icons.favorite,
                                Colors.red,
                                _getBPStatus(bpState),
                              ),
                              const Gap(12),
                              _buildMetricCard(
                                'Chỉ số HbA1c',
                                _getHbA1cValue(hba1cState),
                                '%',
                                Icons.water_drop,
                                Colors.orange,
                                _getHbA1cStatus(hba1cState),
                              ),
                              const Gap(12),
                              _buildMetricCard(
                                'SpO2',
                                _getSpO2Value(spo2State),
                                '%',
                                Icons.air,
                                Colors.pink,
                                _getSpO2Status(spo2State),
                              ),
                              const Gap(12),
                              _buildMetricCard(
                                'Nhiệt độ',
                                _getTempValue(tempState),
                                '°C',
                                Icons.thermostat,
                                Colors.blue,
                                _getTempStatus(tempState),
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
            child: Icon(icon, color: color, size: 28),
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
                        fontSize: 20,
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
                          fontSize: 14,
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
              status,
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

  Widget _buildDetailedMetrics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê chi tiết',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
                _buildStatRow('Tổng số đo lường', '24 lần'),
                const Divider(height: 24),
                _buildStatRow('Trung bình mỗi ngày', '3.4 lần'),
                const Divider(height: 24),
                _buildStatRow('Đo lường gần nhất', 'Hôm nay, 10:30'),
                const Divider(height: 24),
                _buildStatRow('Dữ liệu bất thường', '0'),
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthRecommendations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khuyến nghị sức khỏe',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Gap(16),
          _buildRecommendationCard(
            'Huyết áp ổn định',
            'Tiếp tục duy trì chế độ ăn uống lành mạnh và tập thể dục đều đặn.',
            Icons.check_circle,
            Colors.green,
          ),
          const Gap(12),
          _buildRecommendationCard(
            'Theo dõi đường huyết',
            'Đo chỉ số HbA1c định kỳ mỗi 3 tháng để theo dõi đường huyết.',
            Icons.info,
            Colors.blue,
          ),
          const Gap(12),
          _buildRecommendationCard(
            'Giữ ấm cơ thể',
            'Nhiệt độ cơ thể bình thường. Duy trì nhiệt độ môi trường phù hợp.',
            Icons.thermostat,
            Colors.orange,
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

  // Helper methods to get values from states
  String _getBPValue(BloodPressureState state) {
    if (state is BloodPressureLoaded && state.records.isNotEmpty) {
      final sorted = List.of(state.records)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return '${sorted.first.systolic}/${sorted.first.diastolic}';
    }
    return '--/--';
  }

  String _getBPStatus(BloodPressureState state) {
    if (state is BloodPressureLoaded && state.records.isNotEmpty) {
      final sorted = List.of(state.records)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final systolic = sorted.first.systolic;
      if (systolic < 120) return 'Bình thường';
      if (systolic < 140) return 'Cao nhẹ';
      return 'Cao';
    }
    return 'N/A';
  }

  String _getHbA1cValue(Hba1cState state) {
    if (state is Hba1cLoaded && state.hba1cRecords.isNotEmpty) {
      final sorted = List.of(state.hba1cRecords)
        ..sort((a, b) => b.date.compareTo(a.date));
      return sorted.first.value.toStringAsFixed(1);
    }
    return '--';
  }

  String _getHbA1cStatus(Hba1cState state) {
    if (state is Hba1cLoaded && state.hba1cRecords.isNotEmpty) {
      final sorted = List.of(state.hba1cRecords)
        ..sort((a, b) => b.date.compareTo(a.date));
      final value = sorted.first.value;
      if (value < 5.7) return 'Bình thường';
      if (value < 6.5) return 'Tiền đái tháo đường';
      return 'Đái tháo đường';
    }
    return 'N/A';
  }

  String _getSpO2Value(Spo2heartrateState state) {
    if (state is Spo2heartrateLoaded && state.records.isNotEmpty) {
      final sorted = List.of(state.records)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sorted.first.spo2.toString();
    }
    return '--';
  }

  String _getSpO2Status(Spo2heartrateState state) {
    if (state is Spo2heartrateLoaded && state.records.isNotEmpty) {
      final sorted = List.of(state.records)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final spo2 = sorted.first.spo2;
      if (spo2 >= 95) return 'Bình thường';
      if (spo2 >= 90) return 'Thấp nhẹ';
      return 'Thấp';
    }
    return 'N/A';
  }

  String _getTempValue(TemperatureState state) {
    if (state is TemperatureLoaded && state.temperatures.isNotEmpty) {
      final sorted = List.of(state.temperatures)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sorted.first.value.toStringAsFixed(1);
    }
    return '--';
  }

  String _getTempStatus(TemperatureState state) {
    if (state is TemperatureLoaded && state.temperatures.isNotEmpty) {
      final sorted = List.of(state.temperatures)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final temp = sorted.first.value;
      if (temp >= 36.1 && temp <= 37.2) return 'Bình thường';
      if (temp < 36.1) return 'Thấp';
      return 'Cao';
    }
    return 'N/A';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Bình thường':
        return Colors.green;
      case 'Cao nhẹ':
      case 'Thấp nhẹ':
      case 'Tiền đái tháo đường':
        return Colors.orange;
      case 'Cao':
      case 'Thấp':
      case 'Đái tháo đường':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
