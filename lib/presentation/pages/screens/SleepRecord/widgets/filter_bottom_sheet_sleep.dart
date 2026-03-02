import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/pages/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterBottomSheetSleep {
  static void show({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    String? initialDurationStatus,
    int? initialQuality,
    required Function(DateTime?, DateTime?, String?, int?) onApply,
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
        initialDurationStatus: initialDurationStatus,
        initialQuality: initialQuality,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }
}

class _FilterBottomSheetContent extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialDurationStatus;
  final int? initialQuality;
  final Function(DateTime?, DateTime?, String?, int?) onApply;
  final Function() onReset;

  const _FilterBottomSheetContent({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.initialDurationStatus,
    required this.initialQuality,
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
  String? _selectedDurationStatus;
  int? _selectedQuality;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedDurationStatus = widget.initialDurationStatus;
    _selectedQuality = widget.initialQuality;
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
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

          // ========== THỜI GIAN ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text("Thời gian",
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
            child: GestureDetector(
              onTap: () => _openCustomDatePicker(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          // ========== PHÂN LOẠI GIẤC NGỦ ==========
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Text("Thời lượng ngủ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const Gap(8),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedDurationStatus = null),
                    child: _buildChip(
                        "Tất cả", _selectedDurationStatus == null),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _selectedDurationStatus = "Thiếu ngủ nghiêm trọng"),
                    child: _buildChip("Thiếu ngủ N.trọng",
                        _selectedDurationStatus == "Thiếu ngủ nghiêm trọng"),
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
                        setState(() => _selectedDurationStatus = "Thiếu ngủ"),
                    child: _buildChip(
                        "Thiếu ngủ", _selectedDurationStatus == "Thiếu ngủ"),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedDurationStatus = "Tạm đủ"),
                    child: _buildChip(
                        "Tạm đủ", _selectedDurationStatus == "Tạm đủ"),
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
                        setState(() => _selectedDurationStatus = "Tốt"),
                    child: _buildChip(
                        "Tốt", _selectedDurationStatus == "Tốt"),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _selectedDurationStatus = "Ngủ quá nhiều"),
                    child: _buildChip("Ngủ quá nhiều",
                        _selectedDurationStatus == "Ngủ quá nhiều"),
                  ),
                ),
              ],
            ),
          ),

          // ========== CHẤT LƯỢNG GIẤC NGỦ ==========
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Text("Chất lượng",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const Gap(8),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedQuality = null),
                    child:
                        _buildChip("Tất cả", _selectedQuality == null),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedQuality = 1),
                    child: _buildChip("Rất tệ", _selectedQuality == 1),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedQuality = 2),
                    child: _buildChip("Tệ", _selectedQuality == 2),
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
                    onTap: () => setState(() => _selectedQuality = 3),
                    child:
                        _buildChip("Bình thường", _selectedQuality == 3),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedQuality = 4),
                    child: _buildChip("Tốt", _selectedQuality == 4),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedQuality = 5),
                    child: _buildChip("Rất tốt", _selectedQuality == 5),
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
                    text: "Bỏ lọc",
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _selectedDurationStatus = null;
                        _selectedQuality = null;
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
                                  'Ngày bắt đầu phải trước ngày kết thúc'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }
                      widget.onApply(_startDate, _endDate,
                          _selectedDurationStatus, _selectedQuality);
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.blue.shade800 : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
