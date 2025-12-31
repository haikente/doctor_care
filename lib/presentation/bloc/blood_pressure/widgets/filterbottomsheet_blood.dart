import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterbottomsheetBlood extends StatefulWidget {
  final DateTime? initialStartDate; 
  final DateTime? initialEndDate;
  final String initialStatus; 
  final DateTime firstAvailableDate;
  final DateTime lastAvailableDate; 
  final Function(DateTime?, DateTime?, String) onApply; 
  final VoidCallback onReset;

  const FilterbottomsheetBlood({
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
  State<FilterbottomsheetBlood> createState() => _FilterbottomsheetBloodState();
}

class _FilterbottomsheetBloodState extends State<FilterbottomsheetBlood> {
  late DateTime? tempStartDate;
  late DateTime? tempEndDate;
  late String tempStatus; 
  late String tempClassify; 

  @override
  void initState() {
    super.initState();
    tempStartDate = widget.initialStartDate;
    tempEndDate = widget.initialEndDate;
    tempStatus = widget.initialStatus;
    tempClassify = ""; 
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

          // ========== PHÂN LOẠI (dùng tempClassify) ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text("Phân loại", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempClassify = "";
                      });
                    },
                    child: _buildClassifyChip("Tất cả", tempClassify == ""),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempClassify = "Nhập tay";
                      });
                    },
                    child: _buildClassifyChip("Nhập tay", tempClassify == "Nhập tay"),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempClassify = "Thiết bị";
                      });
                    },
                    child: _buildClassifyChip("Thiết bị", tempClassify == "Thiết bị"),
                  ),
                ),
              ],
            ),
          ),

          // ========== TRẠNG THÁI (dùng tempStatus) ==========
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
                        tempStatus = ""; 
                      });
                    },
                    child: _buildStatusChip("Tất cả", tempStatus == ""),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Huyết áp thấp";
                      });
                    },
                    child: _buildStatusChip("Huyết áp thấp", tempStatus == "Huyết áp thấp"),
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
                        tempStatus = "Bình thường";
                      });
                    },
                    child: _buildStatusChip("Bình thường", tempStatus == "Bình thường"),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Bình thường cao";
                      });
                    },
                    child: _buildStatusChip("Bình thường cao", tempStatus == "Bình thường cao"),
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
                        tempStatus = "Tăng huyết áp độ 1";
                      });
                    },
                    child: _buildStatusChip("Tăng huyết áp độ 1", tempStatus == "Tăng huyết áp độ 1"),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Tăng huyết áp độ 2";
                      });
                    },
                    child: _buildStatusChip("Tăng huyết áp độ 2", tempStatus == "Tăng huyết áp độ 2"),
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
                  tempStatus = "Tăng huyết áp độ 3";
                });
              },
              child: _buildStatusChip("Tăng huyết áp độ 3", tempStatus == "Tăng huyết áp độ 3"),
            ),
          ),

          Spacer(),

          // ========== BUTTONS ==========
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                
                Expanded(
                  child: CustomButton(
                    text: "Bộ lọc",
                    onPressed: () {
                      setState(() {
                        tempStartDate = widget.firstAvailableDate;
                        tempEndDate = widget.lastAvailableDate;
                        tempStatus = "";
                        tempClassify = "";
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
                      if (tempStartDate != null && tempEndDate != null) {
                        if (tempStartDate!.isAfter(tempEndDate!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ngày bắt đầu phải trước ngày kết thúc'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      // ✅ Apply filter
                      widget.onApply(
                        tempStartDate ?? widget.firstAvailableDate,
                        tempEndDate ?? widget.lastAvailableDate,
                        tempStatus,
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
    DateTime? selectedStartDate = tempStartDate;
    DateTime? selectedEndDate = tempEndDate;
    DateTime displayMonth = tempStartDate ?? DateTime.now();

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
                                    tempStartDate = selectedStartDate;
                                    tempEndDate = selectedEndDate;
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
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

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

  // ========== BUILD CHIPS ==========
  Widget _buildClassifyChip(String label, bool isSelected) {
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