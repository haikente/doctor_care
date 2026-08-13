import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/domain/entities/bmi_weight.dart';
import 'package:doctor_care/presentation/bloc/BMIWeight/bmi_weight_bloc.dart';
import 'package:doctor_care/presentation/pages/screens/BMIWeight/insert_bmi_weight.dart';
import 'package:doctor_care/presentation/pages/screens/BMIWeight/widgets/bmi_chart_widget.dart';
import 'package:doctor_care/presentation/pages/screens/BMIWeight/widgets/filter_bottom_sheet_bmi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BmiWeightScreen extends StatefulWidget {
  const BmiWeightScreen({super.key});

  @override
  State<BmiWeightScreen> createState() => _BmiWeightScreenState();
}

class _BmiWeightScreenState extends State<BmiWeightScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<BMIWeightBloc>().add(LoadBMIWeightRecords());
  }

  List<BMIWeight> filterByStatus(List<BMIWeight> records) {
    var filteredRecords = records;

    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filteredRecords = filteredRecords.where((record) {
        return record.timestamp.isAfter(
              _startDate!.subtract(const Duration(days: 1)),
            ) &&
            record.timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != null && _selectedStatus != "Tất cả") {
      filteredRecords = filteredRecords.where((record) {
        return record.bmiStatus == _selectedStatus;
      }).toList();
    }

    return filteredRecords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "Chỉ số BMI & Cân nặng",
        centerTitle: true,
        icon: const Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.white,
          size: 20,
        ),
        onInfo: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => InsertBmiWeight()),
          );
        },
      ),
      body: BlocConsumer<BMIWeightBloc, BMIWeightState>(
        listener: (context, state) {
          if (state is BMIWeightError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is BMIWeightLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BMIWeightLoaded) {
            final filteredRecords = filterByStatus(state.records);

            if (filteredRecords.isNotEmpty &&
                (_startDate == null || _endDate == null)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _startDate = filteredRecords.first.timestamp;
                  _endDate = DateTime.now();
                });
              });
            }

            return Column(
              children: [
                // Biểu đồ BMI/Cân nặng
                BmiChartWidget(records: state.records),

                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr(
                          'record_count',
                          params: {'count': '${filteredRecords.length}'},
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FilterBottomSheetBMI.show(
                            context: context,
                            initialStartDate: _startDate,
                            initialEndDate: _endDate,
                            initialStatus: _selectedStatus,
                            onApply: (startDate, endDate, status) {
                              setState(() {
                                _startDate = startDate;
                                _endDate = endDate;
                                _selectedStatus = status;
                              });
                            },
                            onReset: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                                _selectedStatus = null;
                              });
                            },
                          );
                        },
                        child: Icon(
                          Icons.science_outlined,
                          color: AppColor.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter chips
                if (_startDate != null ||
                    _endDate != null ||
                    _selectedStatus != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_startDate != null && _endDate != null)
                          Chip(
                            label: Text(
                              "${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade900,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.blue.shade900,
                            ),
                            onDeleted: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                            },
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide(color: Colors.blue.shade900),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                        if (_selectedStatus != null &&
                            _selectedStatus != "Tất cả")
                          Chip(
                            label: Text(
                              _selectedStatus!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade900,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.blue.shade900,
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedStatus = null;
                              });
                            },
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide(color: Colors.blue.shade900),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                      ],
                    ),
                  ),

                // Records list
                Expanded(
                  child: filteredRecords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.monitor_weight_outlined,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const Gap(16),
                              Text(
                                _startDate != null || _selectedStatus != null
                                    ? context.tr('no_data_matching_filter')
                                    : context.tr('no_data'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredRecords.length,
                          itemBuilder: (context, index) {
                            final record = filteredRecords[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Slidable(
                                key: ValueKey(record.id),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) {
                                        AppDialog.showDeleteConfirm(
                                          context: context,
                                          content:
                                              "Bạn có chắc chắn muốn xoá bản ghi này không?",
                                          onConfirm: () {
                                            if (record.id != null) {
                                              context.read<BMIWeightBloc>().add(
                                                DeleteBMIWeightRecord(
                                                  record.id!.toString(),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      },
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Xóa',
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            right: Radius.circular(16),
                                          ),
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            InsertBmiWeight(record: record),
                                      ),
                                    );
                                  },
                                  child: _buildRecordCard(record),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return Center(child: Text(context.tr('no_data')));
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const InsertBmiWeight()),
      //     );
      //   },
      //   backgroundColor: Colors.blue,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  Widget _buildRecordCard(BMIWeight record) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const Gap(8),
                Text(
                  DateFormat('HH:mm dd/MM/yyyy').format(record.timestamp),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: record.bmiBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: record.bmiColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(record.bmiIcon, size: 14, color: record.bmiColor),
                      const Gap(6),
                      Text(
                        record.bmiStatus,
                        style: TextStyle(
                          fontSize: 11,
                          color: record.bmiColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
            child: Row(
              children: [
                // BMI
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: record.bmiBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: record.bmiColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 20,
                          color: record.bmiColor,
                        ),
                        const Gap(8),
                        Text(
                          record.bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: record.bmiColor,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "BMI",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(12),

                // Weight
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.monitor_weight,
                          size: 20,
                          color: Colors.purple.shade700,
                        ),
                        const Gap(8),
                        Text(
                          record.weight.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "kg",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(12),

                // Height
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.height,
                          size: 20,
                          color: Colors.teal.shade700,
                        ),
                        const Gap(8),
                        Text(
                          record.height.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "cm",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
