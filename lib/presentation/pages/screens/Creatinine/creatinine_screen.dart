import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/domain/entities/creatinine.dart';
import 'package:doctor_care/presentation/bloc/creatinine/creatinine_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/Creatinine/insert_creatinine.dart';
import 'package:doctor_care/presentation/pages/screens/Creatinine/widgets/filter_bottom_sheet_creatinin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';

class CreatinineScreen extends StatefulWidget {
  const CreatinineScreen({super.key});

  @override
  State<CreatinineScreen> createState() => _CreatinineScreenState();
}

class _CreatinineScreenState extends State<CreatinineScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<CreatinineCubit>().loadCreatinineRecords();
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  List<Creatinine> _filterRecords(List<Creatinine> records) {
    var filtered = records;

    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((record) {
        return record.timestamp.isAfter(
              _startDate!.subtract(const Duration(days: 1)),
            ) &&
            record.timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered.where((record) {
        return record.status == _selectedStatus;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: 'Creatinine / eGFR',
        centerTitle: true,
        onInfo: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InsertCreatinine()),
        ),
        icon: const Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
      body: BlocBuilder<CreatinineCubit, CreatinineState>(
        builder: (context, state) {
          if (state is CreatinineLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CreatinineLoaded) {
            final records = state.records;

            if (records.isNotEmpty &&
                (_startDate == null || _endDate == null)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _startDate = records.first.timestamp;
                  _endDate = DateTime.now();
                });
              });
            }

            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.science_outlined, size: 80, color: Colors.grey),
                    const Gap(20),
                    const Text(
                      'Chưa có dữ liệu Creatinine',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(10),
                    const Text(
                      'Nhấn + để thêm bản ghi mới',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final filteredRecords = _filterRecords(records);

            return Column(
              children: [
                _buildInfoCard(records),
                const Gap(10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredRecords.length} bản ghi',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FilterBottomSheetCreatinine.show(
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
                    _selectedStatus != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 2,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_startDate != null && _endDate != null)
                          Chip(
                            backgroundColor: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(color: Colors.blue.shade900),
                            ),
                            label: Text(
                              "${formatDate(_startDate!)} - ${formatDate(_endDate!)}",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade900,
                                letterSpacing: 0.5,
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
                          ),
                        if (_selectedStatus != null)
                          Chip(
                            backgroundColor: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(color: Colors.blue.shade900),
                            ),
                            label: Text(
                              _selectedStatus!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.blue.shade900,
                            ),
                            onDeleted: () {
                              setState(() => _selectedStatus = null);
                            },
                          ),
                      ],
                    ),
                  ),

                const Gap(5),
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
                                            .read<CreatinineCubit>()
                                            .deleteCreatinineRecord(
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
                                  children: const [
                                    Icon(
                                      Icons.delete_forever_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    Gap(2),
                                    Text(
                                      'Xóa',
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
                                  builder: (_) =>
                                      InsertCreatinine(creatinine: data),
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
          } else if (state is CreatinineError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Chưa có dữ liệu Creatinine'));
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(List<Creatinine> records) {
    final latest = records.last;
    final eGFR = latest.eGFR;

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.science, color: Colors.white, size: 24),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creatinine gần nhất',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    const Gap(4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          latest.value.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(6),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'mg/dL',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  latest.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (eGFR != null) ...[
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'eGFR (ước tính)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '${eGFR.toStringAsFixed(1)} mL/min/1.73m²',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getEGFRColor(eGFR).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      latest.ckdStage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    'Khoảng tham chiếu: ${latest.referenceRange}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
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

  Color _getEGFRColor(double eGFR) {
    if (eGFR >= 90) return Colors.green;
    if (eGFR >= 60) return Colors.lightGreen;
    if (eGFR >= 30) return Colors.orange;
    if (eGFR >= 15) return Colors.deepOrange;
    return Colors.red;
  }

  Widget _buildDataCard(Creatinine data) {
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.value.toStringAsFixed(2),
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
                    if (data.eGFR != null)
                      Text(
                        'eGFR: ${data.eGFR!.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (data.eGFR != null) const Gap(8),
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
