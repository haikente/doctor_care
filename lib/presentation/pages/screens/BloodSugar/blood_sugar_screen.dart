import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/domain/entities/blood_sugar.dart';
import 'package:doctor_care/presentation/bloc/blood_sugar/blood_sugar_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/BloodSugar/insert_blood_sugar.dart';
import 'package:doctor_care/presentation/pages/screens/BloodSugar/widgets/blood_sugar_chart_widget.dart';
import 'package:doctor_care/presentation/pages/screens/BloodSugar/widgets/filter_bottom_sheet_blood_sugar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BloodSugarScreen extends StatefulWidget {
  const BloodSugarScreen({super.key});

  @override
  State<BloodSugarScreen> createState() => _BloodSugarScreenState();
}

class _BloodSugarScreenState extends State<BloodSugarScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;
  String? _selectedMealStatus;

  @override
  void initState() {
    super.initState();
    context.read<BloodSugarCubit>().loadBloodSugarRecords();
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  List<BloodSugar> _filterRecords(List<BloodSugar> records) {
    var filtered = records;

    // Lọc theo khoảng thời gian
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((record) {
        return record.timestamp.isAfter(
              _startDate!.subtract(const Duration(days: 1)),
            ) &&
            record.timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Lọc theo trạng thái đường huyết
    if (_selectedStatus != null) {
      filtered = filtered.where((record) {
        return record.status == _selectedStatus;
      }).toList();
    }

    // Lọc theo thời điểm đo
    if (_selectedMealStatus != null) {
      filtered = filtered.where((record) {
        return record.mealStatus == _selectedMealStatus;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: context.tr('track_blood_sugar'),
        centerTitle: true,
        onInfo: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InsertBloodSugar()),
        ),
        icon: const Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
      body: BlocBuilder<BloodSugarCubit, BloodSugarState>(
        builder: (context, state) {
          if (state is BloodSugarLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BloodSugarLoaded) {
            final records = state.records;

            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const Gap(20),
                    Text(
                      context.tr('no_blood_sugar_records'),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      context.tr('add_new_record_hint'),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final filteredRecords = _filterRecords(records);

            return Column(
              children: [
                // Biểu đồ đường huyết
                BloodSugarChartWidget(records: records),
                Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${filteredRecords.length} ${context.tr('record_count').replaceAll('{count}', '').trim()}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FilterBottomSheetBloodSugar.show(
                            context: context,
                            initialStartDate: _startDate,
                            initialEndDate: _endDate,
                            initialStatus: _selectedStatus,
                            initialMealStatus: _selectedMealStatus,
                            onApply: (startDate, endDate, status, mealStatus) {
                              setState(() {
                                _startDate = startDate;
                                _endDate = endDate;
                                _selectedStatus = status;
                                _selectedMealStatus = mealStatus;
                              });
                            },
                            onReset: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                                _selectedStatus = null;
                                _selectedMealStatus = null;
                              });
                            },
                          );
                        },
                        child: const Icon(
                          Icons.science_outlined,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter chips
                if (_startDate != null ||
                    _endDate != null ||
                    _selectedStatus != null ||
                    _selectedMealStatus != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_startDate != null && _endDate != null)
                          Chip(
                            label: Text(
                              "${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.blue.shade800,
                            ),
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.blue.shade800,
                            ),
                            onDeleted: () {
                              setState(() => _selectedStatus = null);
                            },
                            backgroundColor: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.blue.shade800),
                            ),
                          ),
                        if (_selectedMealStatus != null)
                          Chip(
                            label: Text(
                              _getMealStatusLabel(_selectedMealStatus!),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.blue.shade800,
                            ),
                            onDeleted: () {
                              setState(() => _selectedMealStatus = null);
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

                Gap(10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final data =
                          filteredRecords[filteredRecords.length - 1 - index];
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
                                            .read<BloodSugarCubit>()
                                            .deleteBloodSugarRecord(
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      InsertBloodSugar(bloodSugar: data),
                                ),
                              );
                            },
                            child: _buildDataCard(data),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is BloodSugarError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text(context.tr('no_blood_sugar_data')));
          }
        },
      ),
    );
  }

  String _getMealStatusLabel(String mealStatus) {
    switch (mealStatus) {
      case 'fasting':
        return context.tr('meal_status_fasting');
      case 'before_meal':
        return context.tr('meal_status_before_meal');
      case 'after_meal':
        return context.tr('meal_status_after_meal');
      case 'random':
        return context.tr('meal_status_random');
      default:
        return mealStatus;
    }
  }

  Widget _buildDataCard(BloodSugar data) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.blue.shade500,
            Colors.blue.shade300,
            Colors.white,
            Colors.white,
          ],
          stops: const [0.0, 0.2, 0.3, 1.0],
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
                      data.value.toStringAsFixed(0),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                      ),
                    ),
                    const Gap(5),
                    const Text(
                      'mg/dL',
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      data.mealStatusLabel,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      '${data.timestamp.day.toString().padLeft(2, "0")}/${data.timestamp.month}/${data.timestamp.year}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const Gap(5),
                    Text(
                      '${data.timestamp.hour}:${data.timestamp.minute.toString().padLeft(2, '0')}',
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
