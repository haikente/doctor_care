import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/pages/custom_date_range_picker.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterBottomSheetMenstrualCycle extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String initialStatus;
  final DateTime firstAvailableDate;
  final DateTime lastAvailableDate;
  final Function(DateTime?, DateTime?, String) onApply;
  final VoidCallback onReset;

  const FilterBottomSheetMenstrualCycle({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.initialStatus,
    required this.firstAvailableDate,
    required this.lastAvailableDate,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterBottomSheetMenstrualCycle> createState() =>
      _FilterBottomSheetMenstrualCycleState();
}

class _FilterBottomSheetMenstrualCycleState
    extends State<FilterBottomSheetMenstrualCycle> {
  late DateTime? tempStartDate;
  late DateTime? tempEndDate;
  late String tempStatus;

  @override
  void initState() {
    super.initState();
    tempStartDate = widget.initialStartDate;
    tempEndDate = widget.initialEndDate;
    tempStatus = widget.initialStatus;
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== HEADER ==========
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 16, left: 16),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      context.tr('filter_results'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.clear, size: 24),
                ),
              ],
            ),
          ),
          Divider(),

          // ========== THỜI GIAN ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  context.tr('time'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Gap(4),
                Icon(Icons.grade, color: Colors.red, size: 12),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _openCustomDatePicker(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tempStartDate != null && tempEndDate != null
                          ? "${formatDate(tempStartDate!)} - ${formatDate(tempEndDate!)}"
                          : "${formatDate(widget.firstAvailableDate)} - ${formatDate(widget.lastAvailableDate)}",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          // ========== TRẠNG THÁI ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.tr('status'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Tất cả";
                      });
                    },
                    child: _buildStatusChip(
                      "Tất cả",
                      tempStatus == "Tất cả" || tempStatus == "",
                    ),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Đang diễn ra";
                      });
                    },
                    child: _buildStatusChip(
                      "Đang diễn ra",
                      tempStatus == "Đang diễn ra",
                    ),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Đã kết thúc";
                      });
                    },
                    child: _buildStatusChip(
                      "Đã kết thúc",
                      tempStatus == "Đã kết thúc",
                    ),
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: context.tr('filter'),
                    onPressed: () {
                      setState(() {
                        tempStartDate = widget.firstAvailableDate;
                        tempEndDate = widget.lastAvailableDate;
                        tempStatus = "Tất cả";
                      });

                      widget.onReset();
                    },
                    gradient: [Colors.blue.shade50, Colors.blue.shade50],
                    textColor: Colors.blue,
                  ),
                ),
                Gap(10),
                Expanded(
                  child: CustomButton(
                    text: context.tr('apply'),
                    onPressed: () {
                      if (tempStartDate != null && tempEndDate != null) {
                        if (tempStartDate!.isAfter(tempEndDate!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('date_range_invalid')),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      widget.onApply(
                        tempStartDate ?? widget.firstAvailableDate,
                        tempEndDate ?? widget.lastAvailableDate,
                        tempStatus,
                      );
                      Navigator.pop(context);
                    },
                    gradient: [Colors.blue.shade600, Colors.blue.shade900],
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCustomDatePicker(BuildContext context) {
    CustomDateRangePickerDialog.show(
      context: context,
      initialStartDate: tempStartDate,
      initialEndDate: tempEndDate,
      onConfirm: (start, end) {
        setState(() {
          tempStartDate = start;
          tempEndDate = end;
        });
      },
    );
  }

  Widget _buildStatusChip(String label, bool isSelected) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.blue : Colors.black87,
          ),
        ),
      ),
    );
  }
}
