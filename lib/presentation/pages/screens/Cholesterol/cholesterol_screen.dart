import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/domain/entities/cholesterol.dart';
import 'package:doctor_care/presentation/bloc/cholesterol/cholesterol_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/Cholesterol/insert_cholesterol.dart';
import 'package:doctor_care/presentation/pages/screens/Cholesterol/widgets/filter_bottom_sheet_cholesterol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class CholesterolScreen extends StatefulWidget {
  const CholesterolScreen({super.key});

  @override
  State<CholesterolScreen> createState() => _CholesterolScreenState();
}

class _CholesterolScreenState extends State<CholesterolScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;

  List<Cholesterol> _filterRecords(List<Cholesterol> records) {
    return records.where((record) {
      // Lọc theo thời gian
      if (_startDate != null && _endDate != null) {
        final date = DateTime(
            record.timestamp.year, record.timestamp.month, record.timestamp.day);
        final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
        if (date.isBefore(start) || date.isAfter(end)) return false;
      }
      // Lọc theo đánh giá tổng thể
      if (_selectedStatus != null && record.overallStatus != _selectedStatus) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    context.read<CholesterolCubit>().loadCholesterolRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "Theo dõi Cholesterol",
        centerTitle: true,
        onInfo: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InsertCholesterol()),
        ),
        icon: const Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
      body: BlocBuilder<CholesterolCubit, CholesterolState>(
        builder: (context, state) {
          if (state is CholesterolLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CholesterolLoaded) {
            final records = state.records;
            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bloodtype, size: 80, color: Colors.grey),
                    const Gap(20),
                    const Text(
                      'Chưa có dữ liệu cholesterol',
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
                            FilterBottomSheetCholesterol.show(
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
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                                ),
                                deleteIcon: Icon(Icons.close, size: 16, color: Colors.blue.shade900,),
                                onDeleted: () {
                                  setState(() {
                                    _startDate = null;
                                    _endDate = null;
                                  });
                                },
                                backgroundColor: Colors.blue.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.blue.shade900),
                                ),
                              ),
                            if (_selectedStatus != null)
                              Chip(
                                label: Text(
                                  _selectedStatus!,
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                                ),
                                deleteIcon: Icon(Icons.close, size: 16, color: Colors.blue.shade900,),
                                onDeleted: () {
                                  setState(() => _selectedStatus = null);
                                },
                                backgroundColor: Colors.blue.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.blue.shade900),
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
                                              .read<CholesterolCubit>()
                                              .deleteCholesterolRecord(
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
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InsertCholesterol(cholesterol: data),
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
            );
          }
          if (state is CholesterolError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text(context.tr('no_cholesterol_data')));
        },
      ),
    );
  }

  Widget _buildDataCard(Cholesterol data) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Toàn phần: ${data.totalCholesterol.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: AppColor.textSecondary(context),
                  ),
                ),
                const Gap(5),
                const Text(
                  'mg/dL',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: data.overallBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: data.overallColor),
                  ),
                  child: Text(
                    data.overallStatus,
                    style: TextStyle(
                      fontSize: 11,
                      color: data.overallColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(6),
            Row(
              children: [
                _buildMiniChip(
                  'HDL',
                  data.hdl.toStringAsFixed(0),
                  data.hdlColor,
                ),
                const Gap(8),
                _buildMiniChip(
                  'LDL',
                  data.ldl.toStringAsFixed(0),
                  data.ldlColor,
                ),
                const Gap(8),
                _buildMiniChip(
                  'TG',
                  data.triglycerides.toStringAsFixed(0),
                  data.triglyceridesColor,
                ),
                const Spacer(),
                Text(
                  '${data.timestamp.day.toString().padLeft(2, "0")}/${data.timestamp.month}/${data.timestamp.year}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
