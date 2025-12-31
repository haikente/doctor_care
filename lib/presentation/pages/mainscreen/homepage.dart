import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/presentation/bloc/hba1c/hba1c_cubit.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade500, Colors.blue.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                  Gap(12),

                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Xin chào 👋",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                          "Người dùng",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade600),
                        ),
                      ],
                    ),
                  ),
                  // Notification button
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.notifications_outlined, color: Colors.blue.shade600),
                              onPressed: () {},
                          ),
                        ),
                        // Badge
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.background.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Sức khỏe của bạn",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "Tốt",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                          Gap(20),
                          Divider(color: Colors.white.withOpacity(0.3)),
                          Gap(15),

                          BlocBuilder<BloodPressureCubit, BloodPressureState>(
                            builder: (context, state) {
                               String bloodPressureSubtitle = "_/_";
                                  if (state is BloodPressureLoaded &&
                                    state.records.isNotEmpty) {
                                  final today = DateTime.now();
                                  final todayRecords = state.records.where((record) {
                                    return record.timestamp.year == today.year &&
                                        record.timestamp.month == today.month &&
                                        record.timestamp.day == today.day;
                                  }).toList();
                                  if (todayRecords.isNotEmpty) {
                                    // Lấy bản ghi mới nhất trong ngày
                                    todayRecords.sort(
                                      (a, b) => b.timestamp.compareTo(a.timestamp),
                                    );
                                    final latest = todayRecords.first;
                                    bloodPressureSubtitle =
                                        "${latest.systolic}/${latest.diastolic}";
                                  }
                                }
                                return BlocBuilder<TemperatureCubit, TemperatureState>(
                                  builder: (context, temperatureState) {
                                    String temperatureSubtitle = "__°C";
                                    
                                    if (temperatureState is TemperatureLoaded &&
                                        temperatureState.temperatures.isNotEmpty) {
                                      final today = DateTime.now();
                                      final todayRecords = temperatureState.temperatures.where((record) {
                                        return record.timestamp.year == today.year &&
                                            record.timestamp.month == today.month &&
                                            record.timestamp.day == today.day;
                                      }).toList();
                                      
                                      if (todayRecords.isNotEmpty) {
                                        todayRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                                        final latest = todayRecords.first;
                                        temperatureSubtitle = "${latest.value.toStringAsFixed(1)}°C";
                                      }
                                    }
                                                           
                              if (state is BloodPressureLoaded) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    CustomWidgets.buildQuickStat(
                                      bloodPressureSubtitle,
                                      "Huyết áp",
                                      Icons.bloodtype_outlined,
                                    ),
                                    CustomWidgets.buildQuickStat(
                                      "5.6%",
                                      "SpO2",
                                      Icons.heart_broken_outlined,
                                    ),
                                    CustomWidgets.buildQuickStat(
                                      temperatureSubtitle,
                                      "Nhiệt độ",
                                      Icons.thermostat_outlined,
                                    ),
                                  ],
                                );
                              }
                              return SizedBox(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    CustomWidgets.buildQuickStat(
                                      "_/_",
                                      "Huyết áp",
                                      Icons.bloodtype_outlined,
                                    ),
                                    CustomWidgets.buildQuickStat(
                                      "__%",
                                      "SpO2",
                                      Icons.heart_broken_outlined,
                                    ),
                                    CustomWidgets.buildQuickStat(
                                      "__°C",
                                      "Nhiệt độ",
                                      Icons.thermostat_outlined,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                    Gap(30),

                    Text(
                      "Theo dõi sức khỏe",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Gap(15),

                    BlocBuilder<BloodPressureCubit, BloodPressureState>(
                      builder: (context, bloodPressureState) {
                        String bloodPressureSubtitle = "_/_ mmHg";

                        if (bloodPressureState is BloodPressureLoaded &&
                            bloodPressureState.records.isNotEmpty) {
                          final today = DateTime.now();
                          final todayRecords = bloodPressureState.records.where((record) {
                            return record.timestamp.year == today.year &&
                                record.timestamp.month == today.month &&
                                record.timestamp.day == today.day;
                          }).toList();
                          
                          if (todayRecords.isNotEmpty) {
                            todayRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                            final latest = todayRecords.first;
                            bloodPressureSubtitle = "${latest.systolic}/${latest.diastolic} mmHg";
                          }
                        }

                        return BlocBuilder<Hba1cCubit, Hba1cState>(
                          builder: (context, hba1cState) {
                            String hba1cSubtitle = "__%";

                            if (hba1cState is Hba1cLoaded &&
                                hba1cState.hba1cRecords.isNotEmpty) {
                              final today = DateTime.now();
                              final todayRecords = hba1cState.hba1cRecords.where((record) {
                                return record.date.year == today.year &&
                                    record.date.month == today.month &&
                                    record.date.day == today.day;
                              }).toList();

                              if (todayRecords.isNotEmpty) {
                                todayRecords.sort((a, b) => b.date.compareTo(a.date));
                                final latest = todayRecords.first;
                                hba1cSubtitle = "${latest.value.toStringAsFixed(1)}%";
                              }
                            }

                            // ✅ Thêm nested BlocBuilder cho Temperature
                            return BlocBuilder<TemperatureCubit, TemperatureState>(
                              builder: (context, temperatureState) {
                                String temperatureSubtitle = "__°C";

                                if (temperatureState is TemperatureLoaded &&
                                    temperatureState.temperatures.isNotEmpty) {
                                  final today = DateTime.now();
                                  final todayRecords = temperatureState.temperatures.where((record) {
                                    return record.timestamp.year == today.year &&
                                        record.timestamp.month == today.month &&
                                        record.timestamp.day == today.day;
                                  }).toList();

                                  if (todayRecords.isNotEmpty) {
                                    todayRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                                    final latest = todayRecords.first;
                                    temperatureSubtitle = "${latest.value.toStringAsFixed(1)}°C";
                                  }
                                }

                                // ✅ GridView với temperature subtitle
                                return GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 15,
                                  childAspectRatio: 1.1,
                                  children: [
                                    CustomWidgets.buildHealthCard(
                                      context,
                                      title: "Huyết áp",
                                      subtitle: bloodPressureSubtitle,
                                      icon: Icons.bloodtype_outlined,
                                      color: Colors.red.shade400,
                                      onTap: () => Navigator.pushNamed(context, '/bloodpressure'),
                                    ),
                                    CustomWidgets.buildHealthCard(
                                      context,
                                      title: "Chỉ số HbA1c",
                                      subtitle: hba1cSubtitle,
                                      icon: Icons.medical_information_outlined,
                                      color: Colors.orange.shade400,
                                      onTap: () => Navigator.pushNamed(context, '/hba1c'),
                                    ),
                                    CustomWidgets.buildHealthCard(
                                      context,
                                      title: "SpO2 & Nhịp tim",
                                      subtitle: "__%",
                                      icon: Icons.favorite_outline,
                                      color: Colors.pink.shade400,
                                      onTap: () {},
                                    ),
                                    CustomWidgets.buildHealthCard(
                                      context,
                                      title: "Nhiệt độ",
                                      subtitle: temperatureSubtitle, // ✅ Dùng real data
                                      icon: Icons.thermostat_outlined,
                                      color: Colors.green.shade400,
                                      onTap: () => Navigator.pushNamed(context, '/temperature'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),

                    Gap(30),
                    Text(
                      "Hành động nhanh",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    Gap(15),
                    CustomWidgets.buildQuickActionButton(
                      context,
                      title: "Thêm dữ liệu mới",
                      subtitle: "Cập nhật chỉ số sức khỏe",
                      icon: Icons.add_circle_outline,
                      color: AppColor.background,
                      onTap: () {
                        // Show bottom sheet để chọn loại dữ liệu
                      },
                    ),

                    Gap(12),
                    CustomWidgets.buildQuickActionButton(
                      context,
                      title: "Xem lịch sử",
                      subtitle: "Theo dõi xu hướng sức khỏe",
                      icon: Icons.history,
                      color: Colors.blue.shade700,
                      onTap: () {},
                    ),

                    Gap(12),

                    CustomWidgets.buildQuickActionButton(
                      context,
                      title: "Đặt lịch nhắc",
                      subtitle: "Nhắc nhở đo chỉ số định kỳ",
                      icon: Icons.alarm,
                      color: Colors.purple.shade400,
                      onTap: () {},
                    ),
                    Gap(20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
