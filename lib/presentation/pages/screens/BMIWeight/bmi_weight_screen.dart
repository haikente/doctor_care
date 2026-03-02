import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
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
        return record.timestamp.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
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
        icon: const Icon(Icons.add_circle_outline_outlined, color: Colors.white, size: 20),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BMIWeightLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BMIWeightLoaded) {
            final filteredRecords = filterByStatus(state.records);

            return Column(
              children: [
                // Biểu đồ BMI/Cân nặng
                BmiChartWidget(records: state.records),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${filteredRecords.length} bản ghi", 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                            child: Icon(Icons.science_outlined, color: Colors.black54),
                          )
                        ],
                      ),
                ),
                
                // Filter chips
                if (_startDate != null || _endDate != null || _selectedStatus != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_startDate != null && _endDate != null)
                          Chip(
                            label: Text(
                              "${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}",
                              style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                            ),
                            deleteIcon: Icon(Icons.close, size: 16, color: Colors.blue.shade900),
                            onDeleted: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                            },
                            backgroundColor: Colors.blue.shade100,
                            side: BorderSide(color: Colors.blue.shade900),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        if (_selectedStatus != null && _selectedStatus != "Tất cả")
                          Chip(
                            label: Text(
                              _selectedStatus!,
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _selectedStatus = null;
                              });
                            },
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.blue.shade200),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                              Icon(Icons.monitor_weight_outlined, size: 80, color: Colors.grey.shade400),
                              const Gap(16),
                              Text(
                                _startDate != null || _selectedStatus != null
                                    ? "Không có dữ liệu phù hợp với bộ lọc"
                                    : "Chưa có dữ liệu",
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
                                          content: "Bạn có chắc chắn muốn xoá bản ghi này không?",
                                          onConfirm: () {
                                            if (record.id != null) {
                                              context.read<BMIWeightBloc>().add(
                                                    DeleteBMIWeightRecord(record.id!.toString()),
                                                  );
                                            }
                                          },
                                        );
                                      },
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Xóa',
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => InsertBmiWeight(record: record),
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

          return const Center(child: Text("Không có dữ liệu"));
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Date and Status Badge
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
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const Gap(8),
                Text(
                  DateFormat('HH:mm dd/MM/yyyy').format(record.timestamp),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: record.bmiBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: record.bmiColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(record.bmiIcon, size: 16, color: record.bmiColor),
                      const Gap(6),
                      Text(
                        record.bmiStatus,
                        style: TextStyle(fontSize: 12, color: record.bmiColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body: BMI, Weight, Height
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // BMI
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: record.bmiBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: record.bmiColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.analytics_outlined, size: 24, color: record.bmiColor),
                        const Gap(8),
                        Text(
                          record.bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: record.bmiColor,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "BMI",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                        Icon(Icons.monitor_weight, size: 24, color: Colors.purple.shade700),
                        const Gap(8),
                        Text(
                          record.weight.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "kg",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                        Icon(Icons.height, size: 24, color: Colors.teal.shade700),
                        const Gap(8),
                        Text(
                          record.height.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "cm",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
