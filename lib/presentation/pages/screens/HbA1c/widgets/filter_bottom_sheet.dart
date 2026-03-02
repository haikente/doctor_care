import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/pages/custom_date_range_picker.dart';

class FilterBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate; 
  final DateTime? initialEndDate;
  final String initialStatus; 
  final DateTime firstAvailableDate;
  final DateTime lastAvailableDate; 
  final Function(DateTime?, DateTime?, String) onApply; 
  final VoidCallback onReset; // HÃ m gá»i khi nháº¥n nÃºt "Bá»™ lá»c" 

  const FilterBottomSheet({
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
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late DateTime? tempStartDate;
  late DateTime? tempEndDate;
  late String tempStatus; // Tráº¡ng thÃ¡i táº¡m thá»i

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 370,
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
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Lọc kết quả",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.clear, size: 24),
                )
              ],
            ),
          ),
          Divider(),

          // Thá»i gian
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text("Thời gian", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Gap(4),
                Icon(Icons.grade, color: Colors.red, size: 15),
              ],
            ),
          ),

        // Date range picker  
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

          Gap(10),

          // Trạng thái
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text("Trạng thái", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),

          // Status Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "";
                    });
                  },
                  child: _buildStatusChip("Tất cả", tempStatus == "" || tempStatus == "Tất cả"),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "Bình thường";
                    });
                  },
                  child: _buildStatusChip("Bình thường", tempStatus == "Bình thường"),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "Cao";
                    });
                  },
                  child: _buildStatusChip("Cao", tempStatus == "Cao"),
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Bộ lọc",
                    onPressed: () {
                      widget.onReset();
                      Navigator.pop(context);
                    },
                    gradient: [Colors.blue.shade50, Colors.blue.shade50],
                    textColor: Colors.blue,
                  ),
                ),
                Gap(10),
                Expanded(
                  child: CustomButton(
                    text: "Áp dụng",
                    onPressed: () {
                      String finalStatus = tempStatus;
                      if (tempStatus == "Cao") {
                        finalStatus = "Cao";
                      }
                      widget.onApply(tempStartDate, tempEndDate, finalStatus);
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
}