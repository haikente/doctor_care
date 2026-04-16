import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/menstrual_cycle.dart';
import 'package:doctor_care/presentation/bloc/menstrual_cycle/menstrual_cycle_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/MenstrualCycle/widgets/add_edit_cycle_bottom_sheet.dart';
import 'package:doctor_care/presentation/pages/screens/MenstrualCycle/widgets/filter_bottom_sheet_menstrual_cycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';

class MenstrualCycleScreen extends StatefulWidget {
  const MenstrualCycleScreen({super.key});

  @override
  State<MenstrualCycleScreen> createState() => _MenstrualCycleScreenState();
}

class _MenstrualCycleScreenState extends State<MenstrualCycleScreen> {
  String selectedStatus = "";
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    context.read<MenstrualCycleCubit>().loadCycles();
  }

  List<MenstrualCycle> filterByStatus(List<MenstrualCycle> records) {
    List<MenstrualCycle> filtered = records;

    // Lọc theo thời gian
    if (startDate != null && endDate != null) {
      filtered = filtered.where((record) {
        final recordDate = DateTime(
          record.startDate.year,
          record.startDate.month,
          record.startDate.day,
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

    if (selectedStatus.isNotEmpty && selectedStatus != "Tất cả") {
      filtered = filtered.where((record) {
        final status = record.isOngoing ? "Đang diễn ra" : "Đã kết thúc";
        return status == selectedStatus;
      }).toList();
    }

    return filtered;
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  void _openAddSheet({MenstrualCycle? cycle}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<MenstrualCycleCubit>(),
        child: AddEditCycleBottomSheet(existing: cycle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "Chu kỳ kinh nguyệt",
        centerTitle: true,
        icon: const Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.white,
          size: 20,
        ),
        onInfo: () {
          _openAddSheet();
        },
      ),
      body: BlocConsumer<MenstrualCycleCubit, MenstrualCycleState>(
        listener: (context, state) {
          if (state is MenstrualCycleFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MenstrualCycleLoading ||
              state is MenstrualCycleInitial) {
            return Center(child: CircularProgressIndicator(color: Colors.blue));
          } else if (state is MenstrualCycleLoaded) {
            final cycles = state.cycles;

            if (cycles.isNotEmpty && (startDate == null || endDate == null)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  startDate = cycles.last.startDate;
                  endDate = DateTime.now();
                });
              });
            }

            if (cycles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bắt đầu theo dõi\nchu kỳ của bạn',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ghi lại chu kỳ để dự đoán ngày\nhành kinh tiếp theo.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }

            final filteredRecords = filterByStatus(cycles);

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
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
                            AppDialog.showCustomBottomSheet(
                              context: context,
                              child: FilterBottomSheetMenstrualCycle(
                                initialStartDate: startDate,
                                initialEndDate: endDate,
                                initialStatus: selectedStatus,
                                firstAvailableDate: cycles.last.startDate,
                                lastAvailableDate: DateTime.now(),
                                onApply: (newStartDate, newEndDate, newStatus) {
                                  setState(() {
                                    startDate = newStartDate;
                                    endDate = newEndDate;
                                    selectedStatus = newStatus;
                                  });
                                },
                                onReset: () {
                                  setState(() {
                                    startDate = cycles.last.startDate;
                                    endDate = DateTime.now();
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
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter chips
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (startDate != null && endDate != null)
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
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
                                        startDate = cycles.last.startDate;
                                        endDate = DateTime.now();
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

                          if (selectedStatus.isNotEmpty &&
                              selectedStatus != "Tất cả")
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
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
                                    selectedStatus,
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
                  ),

                  // Empty state filter
                  if (filteredRecords.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            Gap(16),
                            Text(
                              'Không tìm thấy kết quả',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Gap(8),
                            Text(
                              'Thử thay đổi bộ lọc của bạn',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Gap(20),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  startDate = cycles.last.startDate;
                                  endDate = DateTime.now();
                                  selectedStatus = "";
                                });
                              },
                              icon: Icon(Icons.refresh),
                              label: Text('Xóa bộ lọc'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // List view
                  if (filteredRecords.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final data = filteredRecords[index];
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
                                              .read<MenstrualCycleCubit>()
                                              .removeCycle(data.id!);
                                        }
                                        AppSnackBar.showMenstrualCycle(
                                          context: context,
                                          type: SnackBarType.delete,
                                        );
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
                                _openAddSheet(cycle: data);
                              },
                              child: _buildDataCard(data, theme),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          } else if (state is MenstrualCycleError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  CustomButton(
                    onPressed: () =>
                        context.read<MenstrualCycleCubit>().loadCycles(),
                    text: 'Thử lại',
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('Chưa có dữ liệu'));
          }
        },
      ),
    );
  }

  Widget _buildDataCard(MenstrualCycle cycle, ThemeData theme) {
    bool isOngoing = cycle.isOngoing;
    Color statusColor = isOngoing ? Colors.red : Colors.grey.shade600;
    String statusText = isOngoing ? "Đang diễn ra" : "Đã kết thúc";

    return Container(
      constraints: BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade400,
            Colors.white,
            Colors.white,
          ],
          stops: [0.0, 0.2, 0.3, 1.0],
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
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                    Gap(6),
                    Text(
                      formatDate(cycle.startDate),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (cycle.endDate != null) ...[
                      Gap(4),
                      Text("-", style: TextStyle(color: Colors.grey[600])),
                      Gap(4),
                      Text(
                        formatDate(cycle.endDate!),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ],
                ),
                Gap(8),
                Row(
                  children: [
                    Text(
                      'Ngày hành kinh: ${cycle.actualPeriodLength} ngày',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
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
