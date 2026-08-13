import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/domain/entities/blood_pressure.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/widgets/filterbottomsheet_blood.dart';
import 'package:doctor_care/presentation/pages/healthmonitoring/bloodp_chart.dart';
import 'package:doctor_care/presentation/pages/screens/bloodpressure/insert_blood_pressure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  String selectedStatus = "";
  String selectedClassify = "";
  DateTime? startDate;
  DateTime? endDate;

  String chartSelectedStatus = "";
  String chartSelectedClassify = "";
  DateTime? chartStartDate;
  DateTime? chartEndDate;

  @override
  void initState() {
    super.initState();
    context.read<BloodPressureCubit>().loadBloodPressureRecords();
  }

  List<BloodPressure> filterChartData(List<BloodPressure> records) {
    List<BloodPressure> filtered = records;

    // Lọc theo thời gian
    if (chartStartDate != null && chartEndDate != null) {
      filtered = filtered.where((record) {
        final recordDate = DateTime(
          record.timestamp.year,
          record.timestamp.month,
          record.timestamp.day,
        );
        final start = DateTime(
          chartStartDate!.year,
          chartStartDate!.month,
          chartStartDate!.day,
        );
        final end = DateTime(
          chartEndDate!.year,
          chartEndDate!.month,
          chartEndDate!.day,
        );
        return (recordDate.isAtSameMomentAs(start) ||
                recordDate.isAfter(start)) &&
            (recordDate.isAtSameMomentAs(end) || recordDate.isBefore(end));
      }).toList();
    }

    if (chartSelectedClassify.isNotEmpty) {
      filtered = filtered
          .where((record) => record.sourceLabel == chartSelectedClassify)
          .toList();
    }

    if (chartSelectedStatus.isNotEmpty) {
      filtered = filtered.where((record) {
        String status;
        if (record.systolic < 90 && record.diastolic < 60) {
          status = "Huyết áp thấp";
        } else if (record.systolic < 120 && record.diastolic < 80) {
          status = "Bình thường";
        } else if (record.systolic < 130 && record.diastolic < 80) {
          status = "Bình thường cao";
        } else if (record.systolic < 140 || record.diastolic < 90) {
          status = "Tăng huyết áp độ 1";
        } else if (record.systolic < 180 || record.diastolic < 120) {
          status = "Tăng huyết áp độ 2";
        } else {
          status = "Tăng huyết áp độ 3";
        }
        return status == chartSelectedStatus;
      }).toList();
    }

    return filtered;
  }

  List<BloodPressure> filterByStatus(List<BloodPressure> records) {
    List<BloodPressure> filtered = records;

    // Lọc theo thời gian
    if (startDate != null && endDate != null) {
      filtered = filtered.where((record) {
        final recordDate = DateTime(
          record.timestamp.year,
          record.timestamp.month,
          record.timestamp.day,
        );
        final start = DateTime(
          startDate!.year,
          startDate!.month,
          startDate!.day,
        );
        final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
        return (recordDate.isAtSameMomentAs(start) ||
                recordDate.isAfter(start)) &&
            (recordDate.isAtSameMomentAs(end) || recordDate.isBefore(end));
      }).toList();
    }

    if (selectedClassify.isNotEmpty) {
      filtered = filtered
          .where((record) => record.sourceLabel == selectedClassify)
          .toList();
    }

    if (selectedStatus.isNotEmpty) {
      if (selectedStatus == "Huyết áp thấp") {
        filtered = filtered
            .where((record) => record.systolic < 90 && record.diastolic < 60)
            .toList();
      } else if (selectedStatus == "Bình thường") {
        filtered = filtered
            .where(
              (record) =>
                  record.systolic >= 90 &&
                  record.systolic < 120 &&
                  record.diastolic >= 60 &&
                  record.diastolic < 80,
            )
            .toList();
      } else if (selectedStatus == "Bình thường cao") {
        filtered = filtered
            .where(
              (record) =>
                  record.systolic >= 120 &&
                  record.systolic < 130 &&
                  record.diastolic < 80,
            )
            .toList();
      } else if (selectedStatus == "Tăng huyết áp độ 1") {
        filtered = filtered
            .where(
              (record) =>
                  (record.systolic >= 130 && record.systolic < 140) ||
                  (record.diastolic >= 80 && record.diastolic < 90),
            )
            .toList();
      } else if (selectedStatus == "Tăng huyết áp độ 2") {
        filtered = filtered
            .where(
              (record) =>
                  (record.systolic >= 140 && record.systolic < 180) ||
                  (record.diastolic >= 90 && record.diastolic < 120),
            )
            .toList();
      } else if (selectedStatus == "Tăng huyết áp độ 3") {
        filtered = filtered
            .where(
              (record) => record.systolic >= 180 || record.diastolic >= 120,
            )
            .toList();
      }
    }
    return filtered;
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: context.tr('track_blood_pressure'),
        centerTitle: true,
        onInfo: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InsertBloodPressure()),
        ),
        icon: Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
      body: BlocBuilder<BloodPressureCubit, BloodPressureState>(
        builder: (context, state) {
          if (state is BloodPressureLoading) {
            return Center(
              child: CircularProgressIndicator(color: Colors.blue[600]),
            );
          } else if (state is BloodPressureLoaded) {
            final bloodRecords = state.records;

            if (bloodRecords.isNotEmpty &&
                (startDate == null || endDate == null)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  // Set cho card filter
                  startDate = bloodRecords.first.timestamp;
                  endDate = bloodRecords.last.timestamp;
                  // Set cho chart filter
                  chartStartDate = bloodRecords.first.timestamp;
                  chartEndDate = bloodRecords.last.timestamp;
                });
              });
            }

            final filteredRecords = filterByStatus(bloodRecords);
            final chartFilteredData = filterChartData(bloodRecords);

            if (bloodRecords.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bloodtype_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    Gap(20),
                    Text(
                      context.tr('no_blood_pressure_data'),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Gap(10),
                    Text(
                      context.tr('add_new_record_hint'),
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    // ========== CHART ==========
                    SizedBox(
                      height: 415,
                      child: BloodpChart(
                        data: chartFilteredData,
                        onFilterTap: () {
                          AppDialog.showCustomBottomSheet(
                            context: context,
                            child: FilterbottomsheetBlood(
                              initialStartDate: chartStartDate,
                              initialEndDate: chartEndDate,
                              initialStatus: chartSelectedStatus,
                              initialClassify: chartSelectedClassify,
                              firstAvailableDate: bloodRecords.first.timestamp,
                              lastAvailableDate: bloodRecords.last.timestamp,
                              onApply:
                                  (
                                    newStartDate,
                                    newEndDate,
                                    newClassify,
                                    newStatus,
                                  ) {
                                    setState(() {
                                      chartStartDate = newStartDate;
                                      chartEndDate = newEndDate;
                                      chartSelectedClassify = newClassify;
                                      chartSelectedStatus = newStatus;
                                    });
                                  },
                              onReset: () {
                                setState(() {
                                  chartStartDate = bloodRecords.first.timestamp;
                                  chartEndDate = bloodRecords.last.timestamp;
                                  chartSelectedClassify = "";
                                  chartSelectedStatus = "";
                                });
                              },
                            ),
                            isScrollControlled: true,
                            isDismissible: true,
                            enableDrag: true,
                          );
                        },
                      ),
                    ),

                    Gap(50),

                    // ========== HEADER & FILTER ICON ==========
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr(
                            'record_count',
                            params: {'count': '${filteredRecords.length}'},
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColor.textPrimary(context),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            AppDialog.showCustomBottomSheet(
                              context: context,
                              child: FilterbottomsheetBlood(
                                initialStartDate: startDate,
                                initialEndDate: endDate,
                                initialStatus: selectedStatus,
                                initialClassify: selectedClassify,
                                firstAvailableDate:
                                    bloodRecords.first.timestamp,
                                lastAvailableDate: bloodRecords.last.timestamp,
                                onApply:
                                    (
                                      newStartDate,
                                      newEndDate,
                                      newClassify,
                                      newStatus,
                                    ) {
                                      setState(() {
                                        startDate = newStartDate;
                                        endDate = newEndDate;
                                        selectedClassify = newClassify;
                                        selectedStatus = newStatus;
                                      });
                                    },
                                onReset: () {
                                  setState(() {
                                    startDate = bloodRecords.first.timestamp;
                                    endDate = bloodRecords.last.timestamp;
                                    selectedClassify = "";
                                    selectedStatus = "";
                                  });
                                },
                              ),
                              isScrollControlled: true,
                              isDismissible: true,
                              enableDrag: true,
                            );
                          },
                          child: Icon(
                            Icons.science_outlined,
                            color: AppColor.textSecondary(context),
                          ),
                        ),
                      ],
                    ),

                    Gap(20),

                    // ========== FILTER CHIPS ==========
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Chip thời gian
                          if (startDate != null && endDate != null)
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.blue.shade900,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${formatDate(startDate!)} - ${formatDate(endDate!)}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                  Gap(6),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        startDate =
                                            bloodRecords.first.timestamp;
                                        endDate = bloodRecords.last.timestamp;
                                      });
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      size: 14,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Chip trạng thái
                          if (selectedClassify.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.blue.shade900,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _sourceLabel(context, selectedClassify),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                  Gap(6),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedClassify = "";
                                      });
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      size: 14,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (selectedStatus.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.blue.shade900,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _bloodPressureStatusLabel(
                                      context,
                                      selectedStatus,
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                  Gap(6),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedStatus = "";
                                      });
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      size: 14,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    Gap(20),

                    // ========== LIST VIEW ==========
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final data =
                            filteredRecords[filteredRecords.length - 1 - index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 13),
                          child: Slidable(
                            key: ValueKey(data.id),
                            endActionPane: ActionPane(
                              motion: StretchMotion(),
                              extentRatio: 0.25,
                              children: [
                                CustomSlidableAction(
                                  onPressed: (_) {
                                    AppDialog.showDeleteConfirm(
                                      context: context,
                                      onConfirm: () {
                                        if (data.id != null) {
                                          context
                                              .read<BloodPressureCubit>()
                                              .deleteBloodPressureRecord(
                                                data.id.toString(),
                                              );
                                        }
                                      },
                                    );
                                  },
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: EdgeInsets.zero,
                                  autoClose: true,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete_forever_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      Gap(2),
                                      Text(
                                        context.tr('delete'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InsertBloodPressure(
                                      bloodPressure: data,
                                    ),
                                  ),
                                );
                              },
                              child: _buildDataCard(data),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is BloodPressureError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text(context.tr('no_blood_pressure_data')));
          }
        },
      ),
    );
  }

  Widget _buildDataCard(BloodPressure bloodPressure) {
    return Container(
      constraints: BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.blue.shade500, // đoạn màu xanh
            Colors.blue.shade300, // giữ nguyên xanh đến điểm stops
            Colors.white, // phần còn lại màu trắng
            Colors.white,
          ],
          stops: [
            0.0, // bắt đầu
            0.2, // xanh hết 0%
            0.3, // từ đây chuyển sang trắng
            1.0, // hết container
          ],
        ),
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${bloodPressure.systolic}/${bloodPressure.diastolic}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                      ),
                    ),
                    Gap(5),
                    Text(
                      context.tr('unit_mmhg'),
                      style: TextStyle(
                        color: AppColor.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${bloodPressure.timestamp.day.toString().padLeft(2, "0")}/${bloodPressure.timestamp.month}/${bloodPressure.timestamp.year}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Gap(5),
                    Text(
                      '${bloodPressure.timestamp.hour}:${bloodPressure.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: bloodPressure.bloodbkColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: bloodPressure.bloodPressureColor),
              ),
              child: Text(
                _bloodPressureStatusLabel(
                  context,
                  bloodPressure.bloodPressureLevel,
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: bloodPressure.bloodPressureColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sourceLabel(BuildContext context, String sourceLabel) {
    switch (sourceLabel) {
      case 'Nhập tay':
        return context.tr('manual_entry');
      case 'Thiết bị':
        return context.tr('device');
      default:
        return sourceLabel;
    }
  }

  String _bloodPressureStatusLabel(BuildContext context, String status) {
    switch (status) {
      case 'Huyết áp thấp':
        return context.tr('blood_pressure_low');
      case 'Bình thường':
        return context.tr('status_normal');
      case 'Bình thường cao':
        return context.tr('blood_pressure_elevated');
      case 'Tăng huyết áp độ 1':
        return context.tr('blood_pressure_stage_1');
      case 'Tăng huyết áp độ 2':
        return context.tr('blood_pressure_stage_2');
      case 'Tăng huyết áp độ 3':
        return context.tr('blood_pressure_stage_3');
      default:
        return status;
    }
  }
}
