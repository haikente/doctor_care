import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/domain/entities/step_count.dart';
import 'package:doctor_care/presentation/bloc/step_count/step_count_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/StepCount/insert_step_count.dart';
import 'package:doctor_care/presentation/pages/screens/StepCount/widgets/filter_bottom_sheet_step_count.dart';
import 'package:doctor_care/presentation/pages/screens/StepCount/widgets/step_count_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class StepCountScreen extends StatefulWidget {
  const StepCountScreen({super.key});

  @override
  State<StepCountScreen> createState() => _StepCountScreenState();
}

class _StepCountScreenState extends State<StepCountScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<StepCountCubit>().loadStepCounts();
  }

  List<StepCount> _filterRecords(List<StepCount> records) {
    var filtered = records;

    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((r) {
        return r.timestamp.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            r.timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered.where((r) => r.status == _selectedStatus).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "Theo dõi bước chân",
        centerTitle: true,
        onInfo: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InsertStepCount()),
        ),
        icon: const Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
      body: BlocBuilder<StepCountCubit, StepCountState>(
        builder: (context, state) {
          if (state is StepCountLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          if (state is StepCountLoaded) {
            final records = state.records;
            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_walk, size: 80, color: Colors.grey),
                    const Gap(20),
                    const Text(
                      'Chưa có dữ liệu bước chân',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(10),
                    const Text(
                      'Nhấn nút + để thêm bản ghi mới',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            final filteredRecords = _filterRecords(records);
            return Column(
              children: [
                // Biểu đồ tròn phân bố mức vận động
                StepCountPieChart(records: records),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${filteredRecords.length} bản ghi",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  FilterBottomSheetStepCount.show(
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
                                child: const Icon(Icons.science_outlined, color: Colors.black54),
                              ),
                            ],
                          ),

                          // Filter chips
                          if (_startDate != null || _endDate != null || _selectedStatus != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (_startDate != null && _endDate != null)
                                    Chip(
                                      label: Text(
                                        "${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}",
                                        style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                                      ),
                                      deleteIcon: Icon(Icons.close, size: 16, color: Colors.blue.shade800),
                                      onDeleted: () {
                                        setState(() {
                                          _startDate = null;
                                          _endDate = null;
                                        });
                                      },
                                      backgroundColor: Colors.blue.shade50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: Colors.blue.shade800),
                                      ),
                                    ),
                                  if (_selectedStatus != null)
                                    Chip(
                                      label: Text(
                                        _selectedStatus!,
                                        style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                                      ),
                                      deleteIcon: Icon(Icons.close, size: 16, color: Colors.blue.shade800),
                                      onDeleted: () {
                                        setState(() => _selectedStatus = null);
                                      },
                                      backgroundColor: Colors.blue.shade50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: Colors.blue.shade800),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          const Gap(15),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredRecords.length,
                            itemBuilder: (context, index) {
                              final data = filteredRecords[filteredRecords.length - 1 - index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 13),
                          child: Slidable(
                            key: ValueKey(data.id),
                            endActionPane: ActionPane(
                              motion: const StretchMotion(),
                              extentRatio: 0.25,
                              children: [
                                CustomSlidableAction(
                                  onPressed: (_) {
                                    AppDialog.showDeleteConfirm(
                                      context: context,
                                      onConfirm: () {
                                        if (data.id != null) {
                                          context
                                              .read<StepCountCubit>()
                                              .deleteStepCountRecord(
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
                                      const Icon(
                                        Icons.delete_forever_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const Gap(2),
                                      Text(
                                        context.tr('delete'),
                                        style: const TextStyle(
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
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InsertStepCount(stepCount: data),
                                ),
                              ),
                              child: _buildDataCard(data),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
          }
          if (state is StepCountError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text(context.tr('no_step_data')));
        },
      ),
    );
  }

  Widget _buildDataCard(StepCount data) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.blue.shade100,
            Colors.blue.shade50,
            Colors.white,
            Colors.white,
          ],
          stops: const [0.0, 0.2, 0.3, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(data.statusIcon, size: 20, color: data.statusColor),
                    const Gap(6),
                    Text(
                      '${data.steps}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                      ),
                    ),
                    const Gap(5),
                    Text(
                      context.tr('steps_unit'),
                      style: const TextStyle(color: Colors.black, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (data.distance != null) ...[
                      Text(
                        '${data.distance!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      const Gap(8),
                    ],
                    if (data.caloriesBurned != null) ...[
                      Text(
                        '${data.caloriesBurned!.toStringAsFixed(0)} kcal',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      const Gap(8),
                    ],
                    Text(
                      '${data.timestamp.day.toString().padLeft(2, "0")}/${data.timestamp.month}/${data.timestamp.year}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: data.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: data.statusColor),
              ),
              child: Text(
                data.status,
                style: TextStyle(
                  fontSize: 11,
                  color: data.statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
