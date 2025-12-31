import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:doctor_care/core/pages/custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate; 
  final DateTime? initialEndDate;
  final String initialStatus; 
  final DateTime firstAvailableDate;
  final DateTime lastAvailableDate; 
  final Function(DateTime?, DateTime?, String) onApply; 
  final VoidCallback onReset; // Hàm gọi khi nhấn nút "Bộ lọc" 

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
  late String tempStatus; // Trạng thái tạm thời

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
    DateTime? selectedStartDate = tempStartDate;
    DateTime? selectedEndDate = tempEndDate;
    DateTime displayMonth = tempStartDate ?? DateTime.now();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    height: 470,
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                                icon: Icon(Icons.keyboard_double_arrow_left, color: Colors.blue.shade800),
                                onPressed: () {
                                  setDialogState(() {
                                    displayMonth = DateTime(
                                      displayMonth.year - 1,
                                      displayMonth.month,
                                    );
                                  });
                                },
                              ),
                        
                              IconButton(
                                icon: Icon(Icons.chevron_left, color: Colors.blue.shade800),
                                onPressed: () {
                                  setDialogState(() {
                                    displayMonth = DateTime(
                                      displayMonth.year,
                                      displayMonth.month - 1,
                                    );
                                  });
                                },
                              ),
                              Text(
                                  "Tháng ${displayMonth.month} ${displayMonth.year}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Icon(Icons.arrow_drop_down, color: Colors.grey,), 

                              IconButton(
                                icon: Icon(Icons.chevron_right, color: Colors.blue.shade800,),
                                onPressed: () {
                                  setDialogState(() {
                                    displayMonth = DateTime(
                                      displayMonth.year,
                                      displayMonth.month + 1,
                                    );
                                  });
                                },
                              ),
                            
                             Expanded(
                               child: IconButton(
                                  icon: Icon(Icons.keyboard_double_arrow_right_outlined, color: Colors.blue.shade800),
                                  onPressed: () {
                                    setDialogState(() {
                                      displayMonth = DateTime(
                                        displayMonth.year + 1,
                                        displayMonth.month,
                                      );
                                    });
                                  },
                                ),
                             ),
                          ],
                        ),
                        Divider(color: Colors.grey.shade300),
                        // Các thứ trong tuần
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                              .map((day) => SizedBox(
                                    width: 40,
                                    child: Center(
                                      child: Text(
                                        day,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                    
                        // Lịch các ngày
                        _buildCalendarGrid(displayMonth, selectedStartDate, selectedEndDate, (date) {
                          setDialogState(() {
                            if (selectedStartDate == null || (selectedStartDate != null && selectedEndDate != null)) {
                              // Bắt đầu chọn range mới
                              selectedStartDate = date;
                              selectedEndDate = null;
                            } else if (date.isBefore(selectedStartDate!)) {
                              // Nếu chọn ngày trước startDate, đặt làm startDate mới
                              selectedStartDate = date;
                            } else {
                              // Chọn endDate
                              selectedEndDate = date;
                            }
                          });
                        }),
                        
                        // Nút Hủy và Đồng ý
                        Divider(color: Colors.grey.shade300),
                        Gap(5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Huỷ",
                                    style: TextStyle(color: Colors.blue.shade900),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade400, Colors.blue.shade900],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (selectedStartDate != null && selectedEndDate != null) {
                                      setState(() {
                                        tempStartDate = selectedStartDate;
                                        tempEndDate = selectedEndDate;
                                      });
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text(
                                    "Đồng ý",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid(DateTime displayMonth, DateTime? startDate, DateTime? endDate, Function(DateTime) onDateSelected) {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    List<Widget> dayWidgets = [];

    // Thêm các ô trống cho các ngày của tháng trước
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(SizedBox(width: 40, height: 40));
    }

    // Thêm các ngày trong tháng
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final isSelected = (startDate != null && _isSameDay(date, startDate)) ||
                         (endDate != null && _isSameDay(date, endDate));
      final isInRange = startDate != null && endDate != null &&
                        date.isAfter(startDate) && date.isBefore(endDate);
      final isToday = _isSameDay(date, DateTime.now());

      dayWidgets.add(
        GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.shade800
                  : isInRange
                      ? Colors.blue.shade800
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isToday && !isSelected
                  ? Border.all(color: Colors.blue.shade800, width: 1)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isInRange
                          ? Colors.white
                          : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }
    // Đảm bảo luôn có đủ 6 tuần (42 ô) để hiển thị đầy đủ tất cả các ngày
    final maxCells = 42; // 6 tuần x 7 ngày
    
    while (dayWidgets.length < maxCells) {
      dayWidgets.add(SizedBox(width: 40, height: 40));
    }

    final rowCount = 6;
    final cellSize = 40.0;
    final cellMargin = 8.0; // EdgeInsets.all(4)
    final mainSpacing = 2.0;
    final height =
      rowCount * (cellSize + cellMargin) +
      (rowCount - 1) * mainSpacing;

    return SizedBox(
      height: height,
      child: GridView.count(
        crossAxisCount: 7,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        children: dayWidgets,
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

          // Thời gian
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
