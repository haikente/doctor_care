import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterBottomSheetSpo2 extends StatefulWidget {
  final DateTime? initialStartDate; 
  final DateTime? initialEndDate;
  final String initialStatus; 
  final DateTime firstAvailableDate;
  final DateTime lastAvailableDate; 
  final Function(DateTime?, DateTime?, String) onApply; 
  final VoidCallback onReset;

  const FilterBottomSheetSpo2({
    super.key, 
    this.initialStartDate, 
    this.initialEndDate, 
    required this.initialStatus, 
    required this.firstAvailableDate, 
    required this.lastAvailableDate, 
    required this.onApply, 
    required this.onReset
  });

  @override
  State<FilterBottomSheetSpo2> createState() => _FilterBottomSheetSpo2State();
}

class _FilterBottomSheetSpo2State extends State<FilterBottomSheetSpo2> {
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
                      "Lọc kết quả",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

          // ========== THỜI GIAN ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text("Thời gian", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
            child: Text("Trạng thái", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
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
                  child: _buildStatusChip("Bình thường", tempStatus == "Bình thường", Colors.green),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "Theo dõi";
                    });
                  },
                  child: _buildStatusChip("Theo dõi", tempStatus == "Theo dõi", Colors.orange),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "Cần chú ý";
                    });
                  },
                  child: _buildStatusChip("Cần chú ý", tempStatus == "Cần chú ý", Colors.deepOrange),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tempStatus = "Nguy hiểm";
                    });
                  },
                  child: _buildStatusChip("Nguy hiểm", tempStatus == "Nguy hiểm", Colors.red),
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
                    text: "Đặt lại",
                    onPressed: () {
                      setState(() {
                        tempStartDate = null;
                        tempEndDate = null;
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
                    text: "Áp dụng",
                    onPressed: () {
                      widget.onApply(tempStartDate, tempEndDate, tempStatus);
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

  Widget _buildStatusChip(String label, bool isSelected, [Color? color]) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected 
          ? (color?.withOpacity(0.15) ?? Colors.purple.shade50)
          : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected 
            ? (color ?? Colors.purple.shade900)
            : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected 
            ? (color ?? Colors.purple.shade900)
            : Colors.grey.shade700,
        ),
      ),
    );
  }

  void _openCustomDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CustomDateRangePicker(
        firstDate: widget.firstAvailableDate,
        lastDate: widget.lastAvailableDate,
        initialStartDate: tempStartDate ?? widget.firstAvailableDate,
        initialEndDate: tempEndDate ?? widget.lastAvailableDate,
        onConfirm: (startDate, endDate) {
          setState(() {
            tempStartDate = startDate;
            tempEndDate = endDate;
          });
        },
      ),
    );
  }
}

// Custom Date Range Picker
class _CustomDateRangePicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime, DateTime) onConfirm;

  const _CustomDateRangePicker({
    required this.firstDate,
    required this.lastDate,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onConfirm,
  });

  @override
  State<_CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<_CustomDateRangePicker> {
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;
  bool isSelectingStart = true;

  @override
  void initState() {
    super.initState();
    selectedStartDate = widget.initialStartDate;
    selectedEndDate = widget.initialEndDate;
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chọn khoảng thời gian",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.clear),
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelectingStart = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelectingStart ? Colors.purple.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelectingStart ? Colors.blue.shade900 : Colors.grey.shade300,
                          width: isSelectingStart ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text("Từ ngày", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          Gap(4),
                          Text(
                            formatDate(selectedStartDate),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelectingStart ? Colors.blue.shade900 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Gap(12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelectingStart = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: !isSelectingStart ? Colors.purple.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !isSelectingStart ? Colors.blue.shade900 : Colors.blue.shade300,
                          width: !isSelectingStart ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text("Đến ngày", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          Gap(4),
                          Text(
                            formatDate(selectedEndDate),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: !isSelectingStart ? Colors.blue.shade900 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CalendarDatePicker(
              initialDate: isSelectingStart ? selectedStartDate : selectedEndDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (date) {
                setState(() {
                  if (isSelectingStart) {
                    selectedStartDate = date;
                    if (selectedEndDate.isBefore(date)) {
                      selectedEndDate = date;
                    }
                  } else {
                    selectedEndDate = date;
                    if (selectedStartDate.isAfter(date)) {
                      selectedStartDate = date;
                    }
                  }
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                widget.onConfirm(selectedStartDate, selectedEndDate);
                Navigator.pop(context);
              }, child: Text("Xác nhận"),
            )
          ),
        ],
      ),
    );
  }
}
