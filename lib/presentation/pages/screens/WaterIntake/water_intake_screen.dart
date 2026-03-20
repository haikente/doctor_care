import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/domain/entities/water_intake.dart';
import 'package:doctor_care/presentation/bloc/water_intake/water_intake_bloc.dart';
import 'package:doctor_care/presentation/pages/screens/WaterIntake/insert_water_intake.dart';
import 'package:doctor_care/presentation/bloc/water_reminder/water_reminder_cubit.dart';
import 'package:doctor_care/presentation/bloc/water_reminder/water_reminder_state.dart';
import 'package:doctor_care/presentation/pages/screens/WaterIntake/widgets/filter_bottom_sheet_water_intake.dart';
import 'package:doctor_care/presentation/pages/screens/WaterIntake/widgets/water_reminder_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedAmountFilter;

  @override
  void initState() {
    super.initState();
    context.read<WaterIntakeBloc>().add(LoadWaterIntakeRecords());
  }

  List<WaterIntake> _filterByDate(List<WaterIntake> records) {
    return records.where((record) {
      return record.timestamp.year == _selectedDate.year &&
          record.timestamp.month == _selectedDate.month &&
          record.timestamp.day == _selectedDate.day;
    }).toList();
  }

  int _getTotalAmount(List<WaterIntake> records) {
    return records.fold(0, (sum, record) => sum + record.amount);
  }

  List<WaterIntake> _filterByAmount(List<WaterIntake> records) {
    if (_selectedAmountFilter == null) return records;
    return records.where((record) {
      switch (_selectedAmountFilter) {
        case 'Nhỏ':
          return record.amount <= 200;
        case 'Vừa':
          return record.amount > 200 && record.amount <= 500;
        case 'Lớn':
          return record.amount > 500 && record.amount <= 1000;
        case 'Rất lớn':
          return record.amount > 1000;
        default:
          return true;
      }
    }).toList();
  }

  String _getAmountFilterLabel(String filter) {
    switch (filter) {
      case 'Nhỏ':
        return '≤ 200ml';
      case 'Vừa':
        return '201-500ml';
      case 'Lớn':
        return '501-1000ml';
      case 'Rất lớn':
        return '> 1000ml';
      default:
        return filter;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "Lượng nước uống",
        centerTitle: true,
        actions: [
          // Nút nhắc nhở - hiển thị badge nếu đang bật
          BlocBuilder<WaterReminderCubit, WaterReminderState>(
            builder: (context, reminderState) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      reminderState.isEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () => WaterReminderBottomSheet.show(context),
                  ),
                  if (reminderState.isEnabled)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Nút thêm bản ghi
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InsertWaterIntake()),
            ),
          ),
        ],
      ),
      body: BlocConsumer<WaterIntakeBloc, WaterIntakeState>(
        listener: (context, state) {
          if (state is WaterIntakeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is WaterIntakeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WaterIntakeLoaded) {
            final dailyRecords = _filterByDate(state.records);
            final filteredRecords = _filterByAmount(dailyRecords);
            final totalAmount = _getTotalAmount(dailyRecords);
            final progress = WaterIntake.getProgressPercent(totalAmount);
            final status = WaterIntake.getDailyStatus(totalAmount);
            final statusColor = WaterIntake.getStatusColor(totalAmount);

            return Column(
              children: [
                // ========== BẢN GHI + ICON BỘ LỌC ==========
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          FilterBottomSheetWaterIntake.show(
                            context: context,
                            initialDate: _selectedDate,
                            initialAmountFilter: _selectedAmountFilter,
                            onApply: (date, amountFilter) {
                              setState(() {
                                _selectedDate = date;
                                _selectedAmountFilter = amountFilter;
                              });
                            },
                            onReset: () {
                              setState(() {
                                _selectedDate = DateTime.now();
                                _selectedAmountFilter = null;
                              });
                            },
                          );
                        },
                        child: const Icon(Icons.science_outlined, color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                // Filter chips
                if (!_isToday(_selectedDate) || _selectedAmountFilter != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (!_isToday(_selectedDate))
                            Chip(
                              label: Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                              ),
                              deleteIcon: Icon(Icons.close, size: 16, color: Colors.blue.shade800),
                              onDeleted: () {
                                setState(() => _selectedDate = DateTime.now());
                              },
                              backgroundColor: Colors.blue.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.blue.shade800),
                              ),
                            ),
                          if (_selectedAmountFilter != null)
                            Chip(
                              label: Text(
                                _getAmountFilterLabel(_selectedAmountFilter!),
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                              ),
                              deleteIcon: Icon(Icons.close, size: 16, color: Colors.blue.shade800),
                              onDeleted: () {
                                setState(() => _selectedAmountFilter = null);
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
                  ),

                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.lightBlue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.lightBlue.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$totalAmount ml',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Mục tiêu: 2000 ml',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 12,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      const Gap(8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${progress.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${dailyRecords.length} lần',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
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
                              Icon(Icons.water_drop_outlined, size: 80, color: Colors.grey.shade400),
                              const Gap(16),
                              Text(
                                "Chưa có dữ liệu trong ngày",
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                        final bloc = context.read<WaterIntakeBloc>();
                                        AppDialog.showDeleteConfirm(
                                          context: context,
                                          onConfirm: () {
                                            if (!mounted) return;
                                            if (record.id != null) {
                                              bloc.add(
                                                    DeleteWaterIntakeRecord(record.id!.toString()),
                                                  );
                                            }
                                          },
                                        );
                                      },
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete_forever_outlined,
                                      borderRadius: BorderRadius.circular(16),
                                      padding: EdgeInsets.zero,
                                      label: context.tr('delete'),
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InsertWaterIntake(record: record),
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
    );
  }

  Widget _buildRecordCard(WaterIntake record) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                record.sizeIcon,
                size: 32,
                color: Colors.lightBlue.shade700,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.amount} ml',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue.shade900,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    DateFormat('HH:mm').format(record.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (record.note != null && record.note!.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      record.note!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
