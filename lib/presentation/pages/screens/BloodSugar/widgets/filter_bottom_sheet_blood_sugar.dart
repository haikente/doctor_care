import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/pages/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterBottomSheetBloodSugar {
  static void show({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    String? initialStatus,
    String? initialMealStatus,
    required Function(DateTime?, DateTime?, String?, String?) onApply,
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
        initialMealStatus: initialMealStatus,
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
  final String? initialMealStatus;
  final Function(DateTime?, DateTime?, String?, String?) onApply;
  final Function() onReset;

  const _FilterBottomSheetContent({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.initialStatus,
    required this.initialMealStatus,
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
  String? _selectedMealStatus;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedStatus = widget.initialStatus;
    _selectedMealStatus = widget.initialMealStatus;
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 580,
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
                          : "${formatDate(DateTime.now().subtract(const Duration(days: 30)))} - ${formatDate(DateTime.now())}",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
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

          // ========== TRẠNG THÁI ĐƯỜNG HUYẾT ==========
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Text(
              "Trạng thái",
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
                    onTap: () =>
                        setState(() => _selectedStatus = "Hạ đường huyết"),
                    child: _buildChip(
                      "Hạ đường huyết",
                      _selectedStatus == "Hạ đường huyết",
                    ),
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
                    onTap: () =>
                        setState(() => _selectedStatus = "Bình thường"),
                    child: _buildChip(
                      "Bình thường",
                      _selectedStatus == "Bình thường",
                    ),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedStatus = "Tiền đái tháo đường"),
                    child: _buildChip(
                      "Tiền ĐTĐ",
                      _selectedStatus == "Tiền đái tháo đường",
                    ),
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
                    onTap: () =>
                        setState(() => _selectedStatus = "Đái tháo đường"),
                    child: _buildChip(
                      "Đái tháo đường",
                      _selectedStatus == "Đái tháo đường",
                    ),
                  ),
                ),
                const Gap(8),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),

          // ========== THỜI ĐIỂM ĐO ==========
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Text(
              "Thời điểm đo",
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
                    onTap: () => setState(() => _selectedMealStatus = null),
                    child: _buildChip("Tất cả", _selectedMealStatus == null),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedMealStatus = "fasting"),
                    child: _buildChip(
                      "Lúc đói",
                      _selectedMealStatus == "fasting",
                    ),
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
                    onTap: () =>
                        setState(() => _selectedMealStatus = "before_meal"),
                    child: _buildChip(
                      "Trước ăn",
                      _selectedMealStatus == "before_meal",
                    ),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedMealStatus = "after_meal"),
                    child: _buildChip(
                      "Sau ăn 2h",
                      _selectedMealStatus == "after_meal",
                    ),
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
                    onTap: () => setState(() => _selectedMealStatus = "random"),
                    child: _buildChip(
                      "Ngẫu nhiên",
                      _selectedMealStatus == "random",
                    ),
                  ),
                ),
                const Gap(8),
                const Expanded(child: SizedBox()),
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
                        _selectedMealStatus = null;
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
                      widget.onApply(
                        _startDate,
                        _endDate,
                        _selectedStatus,
                        _selectedMealStatus,
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
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
