import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/pages/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterBottomSheetCholesterol {
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
  State<_FilterBottomSheetContent> createState() =>
      _FilterBottomSheetContentState();
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
      decoration: const BoxDecoration(
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.clear, size: 24),
                ),
              ],
            ),
          ),
          const Divider(),

          // ========== THỜI GIAN ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  "Thời gian",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Gap(4),
                Icon(Icons.grade, color: Colors.red, size: 12),
              ],
            ),
          ),
          const Gap(8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _openCustomDatePicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
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
                        color: _startDate != null
                            ? Colors.black
                            : Colors.black87,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ========== ĐÁNH GIÁ TỔNG THỂ ==========
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Text(
              "Đánh giá tổng thể",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const Gap(8),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatus = null),
                    child: _buildChip("Tất cả", _selectedStatus == null),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatus = "Tốt"),
                    child: _buildChip("Tốt", _selectedStatus == "Tốt"),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatus = "Cần chú ý"),
                    child: _buildChip(
                      "Cần chú ý",
                      _selectedStatus == "Cần chú ý",
                    ),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedStatus = "Nguy cơ cao"),
                    child: _buildChip(
                      "Nguy cơ cao",
                      _selectedStatus == "Nguy cơ cao",
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ========== BUTTONS ==========
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: context.tr('clear_filter'),
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
                const Gap(10),
                Expanded(
                  child: CustomButton(
                    text: "Áp dụng",
                    onPressed: () {
                      if (_startDate != null && _endDate != null) {
                        if (_startDate!.isAfter(_endDate!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ngày bắt đầu phải trước ngày kết thúc',
                              ),
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

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.blue.shade800 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
