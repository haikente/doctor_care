import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/pages/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterBottomSheetSpo2 extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String initialStatus;
  final String initialClassify;
  final DateTime firstAvailableDate;
  final DateTime lastAvailableDate;
  final Function(DateTime?, DateTime?, String, String) onApply;
  final VoidCallback onReset;

  const FilterBottomSheetSpo2({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.initialStatus,
    this.initialClassify = "",
    required this.firstAvailableDate,
    required this.lastAvailableDate,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterBottomSheetSpo2> createState() => _FilterBottomSheetSpo2State();
}

class _FilterBottomSheetSpo2State extends State<FilterBottomSheetSpo2> {
  late DateTime? tempStartDate;
  late DateTime? tempEndDate;
  late String tempClassify;
  late String tempStatus;

  @override
  void initState() {
    super.initState();
    tempStartDate = widget.initialStartDate;
    tempEndDate = widget.initialEndDate;
    tempClassify = widget.initialClassify;
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
      height: 500,
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

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.tr('classification'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Wrap(
              spacing: 5,
              runSpacing: 8,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempClassify = "";
                    });
                  },
                  child: _buildStatusChip(
                    context.tr('all'),
                    tempClassify == "",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempClassify = "device";
                    });
                  },
                  child: _buildStatusChip(
                    context.tr('device'),
                    tempClassify == "device",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempClassify = "manual";
                    });
                  },
                  child: _buildStatusChip(
                    context.tr('manual_entry'),
                    tempClassify == "manual",
                  ),
                ),
              ],
            ),
          ),

          // ========== Trạng thái ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.tr('status'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Wrap(
              spacing: 5,
              runSpacing: 8,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "";
                    });
                  },
                  child: _buildStatusChip(context.tr('all'), tempStatus == ""),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "normal";
                    });
                  },
                  child: _buildStatusChip(
                    context.tr('status_normal'),
                    tempStatus == "normal",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "monitoring";
                    });
                  },
                  child: _buildStatusChip(
                    context.tr('status_monitoring'),
                    tempStatus == "monitoring",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "attention";
                    });
                  },
                  child: _buildStatusChip(
                    context.tr('status_attention'),
                    tempStatus == "attention",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "danger";
                    });
                  },
                  child: _buildStatusChip(
                    context.tr('status_danger'),
                    tempStatus == "danger",
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          // ========== BUTTONS ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: context.tr('clear_filter'),
                    onPressed: () {
                      setState(() {
                        tempStartDate = null;
                        tempEndDate = null;
                        tempClassify = "";
                        tempStatus = "";
                      });
                      widget.onReset();
                      Navigator.pop(context);
                    },
                    gradient: [Colors.grey.shade200, Colors.grey.shade300],
                    textColor: Colors.blue,
                  ),
                ),
                Gap(12),
                Expanded(
                  child: CustomButton(
                    text: context.tr('apply'),
                    onPressed: () {
                      widget.onApply(
                        tempStartDate,
                        tempEndDate,
                        tempClassify,
                        tempStatus,
                      );
                      Navigator.pop(context);
                    },
                    gradient: [Colors.blue.shade700, Colors.blue.shade900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isSelected) {
    return SizedBox(
      height: 40,
      width: 115,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.blue : Colors.black87,
            ),
          ),
        ),
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
}
