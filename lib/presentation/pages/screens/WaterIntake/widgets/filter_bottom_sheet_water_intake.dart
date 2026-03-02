import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/pages/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterBottomSheetWaterIntake {
  static void show({
    required BuildContext context,
    required DateTime initialDate,
    String? initialAmountFilter,
    required Function(DateTime, String?) onApply,
    required Function() onReset,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheetContent(
        initialDate: initialDate,
        initialAmountFilter: initialAmountFilter,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }
}

class _FilterBottomSheetContent extends StatefulWidget {
  final DateTime initialDate;
  final String? initialAmountFilter;
  final Function(DateTime, String?) onApply;
  final Function() onReset;

  const _FilterBottomSheetContent({
    required this.initialDate,
    required this.initialAmountFilter,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheetContent> createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late DateTime _selectedDate;
  String? _selectedAmountFilter;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedAmountFilter = widget.initialAmountFilter;
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  void _pickDate(BuildContext context) {
    CustomDateRangePickerDialog.show(
      context: context,
      initialStartDate: _selectedDate,
      initialEndDate: _selectedDate,
      onConfirm: (start, end) {
        setState(() => _selectedDate = start);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
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
                          fontSize: 16, fontWeight: FontWeight.bold),
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

          // ========== NGÀY ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text("Ngày theo dõi",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Gap(4),
                Icon(Icons.grade, color: Colors.red, size: 12),
              ],
            ),
          ),
          const Gap(8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Icon(Icons.chevron_left, color: Colors.blue.shade700, size: 20),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const Gap(8),
                          Text(
                            _isToday(_selectedDate)
                                ? "Hôm nay - ${formatDate(_selectedDate)}"
                                : formatDate(_selectedDate),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                GestureDetector(
                  onTap: () {
                    final tomorrow = _selectedDate.add(const Duration(days: 1));
                    if (!tomorrow.isAfter(DateTime.now())) {
                      setState(() => _selectedDate = tomorrow);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Icon(Icons.chevron_right, color: Colors.blue.shade700, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const Gap(4),
          // Nút "Hôm nay" nhanh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() => _selectedDate = DateTime.now());
                },
                child: Text(
                  "Về hôm nay",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // ========== LƯỢNG NƯỚC ==========
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 4),
            child: Text("Lượng nước mỗi lần",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const Gap(8),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedAmountFilter = null),
                    child: _buildChip("Tất cả", _selectedAmountFilter == null),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedAmountFilter = "Nhỏ"),
                    child: _buildChip("≤ 200ml", _selectedAmountFilter == "Nhỏ"),
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
                    onTap: () => setState(() => _selectedAmountFilter = "Vừa"),
                    child: _buildChip("201-500ml", _selectedAmountFilter == "Vừa"),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedAmountFilter = "Lớn"),
                    child: _buildChip("501-1000ml", _selectedAmountFilter == "Lớn"),
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
                    onTap: () => setState(() => _selectedAmountFilter = "Rất lớn"),
                    child: _buildChip("> 1000ml", _selectedAmountFilter == "Rất lớn"),
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
                    text: "Bỏ lọc",
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime.now();
                        _selectedAmountFilter = null;
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
                      widget.onApply(_selectedDate, _selectedAmountFilter);
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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
