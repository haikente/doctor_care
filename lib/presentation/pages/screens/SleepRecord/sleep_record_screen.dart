import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/domain/entities/sleep_record.dart';
import 'package:doctor_care/presentation/bloc/sleep_record/sleep_record_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/SleepRecord/insert_sleep_record.dart';
import 'package:doctor_care/presentation/pages/screens/SleepRecord/widgets/filter_bottom_sheet_sleep.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class SleepRecordScreen extends StatefulWidget {
  const SleepRecordScreen({super.key});

  @override
  State<SleepRecordScreen> createState() => _SleepRecordScreenState();
}

class _SleepRecordScreenState extends State<SleepRecordScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedDurationStatus;
  int? _selectedQuality;

  @override
  void initState() {
    super.initState();
    context.read<SleepRecordCubit>().loadSleepRecords();
  }

  List<SleepRecord> _filterRecords(List<SleepRecord> records) {
    var filtered = records;

    // Lọc theo khoảng thời gian
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((r) {
        return r.timestamp.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            r.timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Lọc theo phân loại thời lượng ngủ
    if (_selectedDurationStatus != null) {
      filtered = filtered.where((r) {
        return r.durationStatus == _selectedDurationStatus;
      }).toList();
    }

    // Lọc theo chất lượng
    if (_selectedQuality != null) {
      filtered = filtered.where((r) {
        return r.quality == _selectedQuality;
      }).toList();
    }

    return filtered;
  }

  String _getQualityLabel(int quality) {
    switch (quality) {
      case 1: return 'Rất tệ';
      case 2: return 'Tệ';
      case 3: return 'Bình thường';
      case 4: return 'Tốt';
      case 5: return 'Rất tốt';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "Theo dõi giấc ngủ",
        centerTitle: true,
        onInfo: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const InsertSleepRecordScreen(),
          ),
        ),
        icon: const Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
      body: BlocBuilder<SleepRecordCubit, SleepRecordState>(
        builder: (context, state) {
          if (state is SleepRecordLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SleepRecordLoaded) {
            final records = state.records;

            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bedtime_outlined, size: 80, color: Colors.grey),
                    const Gap(20),
                    const Text(
                      'Chưa có dữ liệu giấc ngủ',
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

            return SingleChildScrollView(
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
                            FilterBottomSheetSleep.show(
                              context: context,
                              initialStartDate: _startDate,
                              initialEndDate: _endDate,
                              initialDurationStatus: _selectedDurationStatus,
                              initialQuality: _selectedQuality,
                              onApply: (startDate, endDate, durationStatus, quality) {
                                setState(() {
                                  _startDate = startDate;
                                  _endDate = endDate;
                                  _selectedDurationStatus = durationStatus;
                                  _selectedQuality = quality;
                                });
                              },
                              onReset: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                  _selectedDurationStatus = null;
                                  _selectedQuality = null;
                                });
                              },
                            );
                          },
                          child: const Icon(Icons.science_outlined, color: Colors.black54),
                        ),
                      ],
                    ),

                    // Filter chips
                    if (_startDate != null || _endDate != null || _selectedDurationStatus != null || _selectedQuality != null)
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
                            if (_selectedDurationStatus != null)
                              Chip(
                                label: Text(
                                  _selectedDurationStatus!,
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                                ),
                                deleteIcon: Icon(Icons.close, size: 16, color: Colors.blue.shade800),
                                onDeleted: () {
                                  setState(() => _selectedDurationStatus = null);
                                },
                                backgroundColor: Colors.blue.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.blue.shade800),
                                ),
                              ),
                            if (_selectedQuality != null)
                              Chip(
                                label: Text(
                                  _getQualityLabel(_selectedQuality!),
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                                ),
                                deleteIcon: Icon(Icons.close, size: 16, color: Colors.blue.shade800),
                                onDeleted: () {
                                  setState(() => _selectedQuality = null);
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
                                              .read<SleepRecordCubit>()
                                              .deleteSleepRecordData(
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
                                        InsertSleepRecordScreen(
                                          sleepRecord: data,
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
          } else if (state is SleepRecordError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text(context.tr('no_sleep_data')));
        },
      ),
    );
  }

  Widget _buildDataCard(SleepRecord data) {
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
                      data.durationText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                      ),
                    ),
                    const Gap(8),
                    Icon(data.qualityIcon, color: data.qualityColor, size: 20),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${data.bedTime.hour.toString().padLeft(2, '0')}:${data.bedTime.minute.toString().padLeft(2, '0')} - '
                      '${data.wakeTime.hour.toString().padLeft(2, '0')}:${data.wakeTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
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
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: data.durationBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: data.durationColor),
              ),
              child: Text(
                data.durationStatus,
                style: TextStyle(
                  fontSize: 11,
                  color: data.durationColor,
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
