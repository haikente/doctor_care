import 'package:doctor_care/core/pages/custom_button.dart';
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
                      _startDate != null && _endDate != null
                          ? "${formatDate(_startDate!)} - ${formatDate(_endDate!)}"
                          : "Chọn khoảng thời gian",
                      style: TextStyle(
                        fontSize: 13,
                        color: _startDate != null ? Colors.black87 : Colors.grey.shade500,
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
                    text: "Đặt lại",
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
    DateTime? selectedStartDate = _startDate;
    DateTime? selectedEndDate = _endDate;
    DateTime displayMonth = _startDate ?? DateTime.now();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 480,
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // ========== MONTH NAVIGATION ==========
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.keyboard_double_arrow_left, color: Colors.blue.shade800),
                            onPressed: () {
                              setDialogState(() {
                                displayMonth = DateTime(displayMonth.year - 1, displayMonth.month);
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_left, color: Colors.blue.shade800),
                            onPressed: () {
                              setDialogState(() {
                                displayMonth = DateTime(displayMonth.year, displayMonth.month - 1);
                              });
                            },
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Tháng ${displayMonth.month}, ${displayMonth.year}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, color: Colors.blue.shade800),
                            onPressed: () {
                              setDialogState(() {
                                displayMonth = DateTime(displayMonth.year, displayMonth.month + 1);
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_double_arrow_right, color: Colors.blue.shade800),
                            onPressed: () {
                              setDialogState(() {
                                displayMonth = DateTime(displayMonth.year + 1, displayMonth.month);
                              });
                            },
                          ),
                        ],
                      ),
                      
                      Divider(color: Colors.grey.shade300),
                      
                      // ========== WEEKDAY HEADERS ==========
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                            .map((day) => SizedBox(
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      
                      Gap(8),
                      
                      // ========== CALENDAR GRID ==========
                      Expanded(
                        child: _buildCalendarGrid(
                          displayMonth,
                          selectedStartDate,
                          selectedEndDate,
                          (date) {
                            setDialogState(() {
                              if (selectedStartDate == null || (selectedStartDate != null && selectedEndDate != null)) {
                                selectedStartDate = date;
                                selectedEndDate = null;
                              } else if (date.isBefore(selectedStartDate!)) {
                                selectedStartDate = date;
                              } else {
                                selectedEndDate = date;
                              }
                            });
                          },
                        ),
                      ),
                      
                      Divider(color: Colors.grey.shade300),
                      Gap(8),
                      
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Hủy",
                              onPressed: () => Navigator.pop(context),
                              gradient: [Colors.blue.shade50, Colors.blue.shade50],
                              textColor: Colors.blue,
                            ),
                          ),
                          Gap(10),
                          Expanded(
                            child: CustomButton(
                              text: "Đồng ý",
                              onPressed: () {
                                if (selectedStartDate != null && selectedEndDate != null) {
                                  if (selectedStartDate!.isAfter(selectedEndDate!)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Ngày bắt đầu phải trước ngày kết thúc'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  setState(() {
                                    _startDate = selectedStartDate;
                                    _endDate = selectedEndDate;
                                  });
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Vui lòng chọn khoảng thời gian'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                              gradient: [Colors.blue.shade600, Colors.blue.shade900],
                              textColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid(
    DateTime displayMonth,
    DateTime? startDate,
    DateTime? endDate,
    Function(DateTime) onDateSelected,
  ) {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(SizedBox(width: 40, height: 40));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final isStartDate = startDate != null && _isSameDay(date, startDate);
      final isEndDate = endDate != null && _isSameDay(date, endDate);
      final isInRange = startDate != null &&
          endDate != null &&
          date.isAfter(startDate) &&
          date.isBefore(endDate);
      final isToday = _isSameDay(date, DateTime.now());

      dayWidgets.add(
        GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: (isStartDate || isEndDate)
                  ? Colors.blue.shade800
                  : isInRange
                      ? Colors.blue.shade100
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isStartDate && !isEndDate
                  ? Border.all(color: Colors.blue.shade800, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: (isStartDate || isEndDate)
                      ? Colors.white
                      : isInRange
                          ? Colors.blue.shade800
                          : Colors.black87,
                  fontWeight: (isStartDate || isEndDate || isToday)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: dayWidgets,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
