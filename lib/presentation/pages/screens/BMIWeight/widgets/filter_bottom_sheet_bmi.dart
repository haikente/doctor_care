import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/pages/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterBottomSheetBMI {
  static void show({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    String? initialStatus,
    required Function(DateTime?, DateTime?, String?) onApply,
    required Function() onReset,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheetContent(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        initialStatus: initialStatus,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }
}

class _FilterBottomSheetContent extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialStatus;
  final Function(DateTime?, DateTime?, String?) onApply;
  final Function() onReset;

  const _FilterBottomSheetContent({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.initialStatus,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheetContent> createState() => _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedStatus = widget.initialStatus;
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.textSecondary(context)),
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
                Text("Thời gian", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColor.textSecondary(context))),
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
                      _startDate != null && _endDate != null
                          ? "${formatDate(_startDate!)} - ${formatDate(_endDate!)}"
                          : "${formatDate(widget.initialStartDate ?? DateTime.now())} - ${formatDate(widget.initialEndDate ?? DateTime.now())}",
                      style: TextStyle(
                        fontSize: 13,
                        color: _startDate != null ? Colors.black : Colors.black87,
                      ),
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
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = null;
                      });
                    },
                    child: _buildStatusChip("Tất cả", _selectedStatus == null),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = "Thiếu cân";
                      });
                    },
                    child: _buildStatusChip("Thiếu cân", _selectedStatus == "Thiếu cân"),
                  ),
                ),
              ],
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
                        _selectedStatus = "Bình thường";
                      });
                    },
                    child: _buildStatusChip("Bình thường", _selectedStatus == "Bình thường"),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = "Thừa cân";
                      });
                    },
                    child: _buildStatusChip("Thừa cân", _selectedStatus == "Thừa cân"),
                  ),
                ),
              ],
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
                        _selectedStatus = "Béo phì độ I";
                      });
                    },
                    child: _buildStatusChip("Béo phì I", _selectedStatus == "Béo phì độ I"),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = "Béo phì độ II";
                      });
                    },
                    child: _buildStatusChip("Béo phì II", _selectedStatus == "Béo phì độ II"),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStatus = "Béo phì độ III";
                });
              },
              child: _buildStatusChip("Béo phì III", _selectedStatus == "Béo phì độ III"),
            ),
          ),

          Spacer(),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Bộ lọc",
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _selectedStatus = null;
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
                    text: "Áp dụng",
                    onPressed: () {
                      if (_startDate != null && _endDate != null) {
                        if (_startDate!.isAfter(_endDate!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ngày bắt đầu phải trước ngày kết thúc'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      widget.onApply(_startDate, _endDate, _selectedStatus);
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

  // ========== CUSTOM DATE PICKER ==========
  void _openCustomDatePicker(BuildContext context) {
    CustomDateRangePickerDialog.show(
      context: context,
      initialStartDate: _startDate,
      initialEndDate: _endDate,
      onConfirm: (start, end) {
        setState(() {
          _startDate = start;
          _endDate = end;
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
            color: isSelected ? Colors.blue.shade800 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
