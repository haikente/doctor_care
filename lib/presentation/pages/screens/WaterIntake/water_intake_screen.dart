import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/domain/entities/water_intake.dart';
import 'package:doctor_care/presentation/bloc/water_intake/water_intake_bloc.dart';
import 'package:doctor_care/presentation/pages/screens/WaterIntake/insert_water_intake.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "Lượng nước uống",
        centerTitle: true,
        icon: const Icon(Icons.calendar_today, color: Colors.white, size: 22),
        onInfo: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.lightBlue,
                    onPrimary: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null && picked != _selectedDate) {
            setState(() {
              _selectedDate = picked;
            });
          }
        },
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
            final totalAmount = _getTotalAmount(dailyRecords);
            final progress = WaterIntake.getProgressPercent(totalAmount);
            final status = WaterIntake.getDailyStatus(totalAmount);
            final statusColor = WaterIntake.getStatusColor(totalAmount);

            return Column(
              children: [
                // Date selector
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: Colors.lightBlue.shade700),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                          });
                        },
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue.shade900,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: Colors.lightBlue.shade700),
                        onPressed: _selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                            ? () {
                                setState(() {
                                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),

                // Progress card
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
                  child: dailyRecords.isEmpty
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
                          itemCount: dailyRecords.length,
                          itemBuilder: (context, index) {
                            final record = dailyRecords[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Slidable(
                                key: ValueKey(record.id),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => InsertWaterIntake(record: record),
                                          ),
                                        );
                                      },
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      icon: Icons.edit,
                                      label: 'Sửa',
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                    ),
                                    SlidableAction(
                                      onPressed: (context) {
                                        AppDialog.showDeleteConfirm(
                                          context: context,
                                          content: "Bạn có chắc chắn muốn xoá bản ghi này không?",
                                          onConfirm: () {
                                            if (record.id != null) {
                                              context.read<WaterIntakeBloc>().add(
                                                    DeleteWaterIntakeRecord(record.id!.toString()),
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

          return const Center(child: Text("Không có dữ liệu"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InsertWaterIntake()),
          );
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add, color: Colors.white),
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
