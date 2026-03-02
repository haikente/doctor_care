import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Widget tái sử dụng để chọn khoảng ngày (date range).
/// Hiển thị dưới dạng dialog với lịch tháng, hỗ trợ chọn startDate & endDate.
///
/// Sử dụng:
/// ```dart
/// CustomDateRangePickerDialog.show(
///   context: context,
///   initialStartDate: startDate,
///   initialEndDate: endDate,
///   onConfirm: (start, end) {
///     setState(() {
///       startDate = start;
///       endDate = end;
///     });
///   },
/// );
/// ```
class CustomDateRangePickerDialog {
  /// Hiển thị dialog chọn khoảng ngày
  static void show({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    required Function(DateTime start, DateTime end) onConfirm,
  }) async {
    DateTime? selectedStartDate = initialStartDate;
    DateTime? selectedEndDate = initialEndDate;
    DateTime displayMonth = initialStartDate ?? DateTime.now();

    final result = await showGeneralDialog<List<DateTime>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 480,
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // ========== MONTH NAVIGATION ==========
                      _buildMonthNavigation(displayMonth, (newMonth) {
                        setDialogState(() {
                          displayMonth = newMonth;
                        });
                      }),

                      Divider(color: Colors.grey.shade300),

                      // ========== WEEKDAY HEADERS ==========
                      _buildWeekdayHeaders(),

                      const Gap(8),

                      // ========== CALENDAR GRID ==========
                      Expanded(
                        child: _buildCalendarGrid(
                          displayMonth,
                          selectedStartDate,
                          selectedEndDate,
                          (date) {
                            setDialogState(() {
                              if (selectedStartDate == null ||
                                  (selectedStartDate != null && selectedEndDate != null)) {
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

                      // ========== BUTTONS ==========
                      Divider(color: Colors.grey.shade300),
                      const Gap(5),
                      _buildActionButtons(
                        context,
                        selectedStartDate,
                        selectedEndDate,
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
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
    );

    // Sau khi dialog đóng, nếu có kết quả thì gọi callback
    if (result != null && result.length == 2) {
      onConfirm(result[0], result[1]);
    }
  }

  /// Navigation tháng/năm
  static Widget _buildMonthNavigation(
    DateTime displayMonth,
    Function(DateTime) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.keyboard_double_arrow_left, color: Colors.blue.shade800),
          onPressed: () {
            onChanged(DateTime(displayMonth.year - 1, displayMonth.month));
          },
        ),
        IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.blue.shade800),
          onPressed: () {
            onChanged(DateTime(displayMonth.year, displayMonth.month - 1));
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              "Tháng ${displayMonth.month}, ${displayMonth.year}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: Colors.blue.shade800),
          onPressed: () {
            onChanged(DateTime(displayMonth.year, displayMonth.month + 1));
          },
        ),
        IconButton(
          icon: Icon(Icons.keyboard_double_arrow_right, color: Colors.blue.shade800),
          onPressed: () {
            onChanged(DateTime(displayMonth.year + 1, displayMonth.month));
          },
        ),
      ],
    );
  }

  /// Header các ngày trong tuần
  static Widget _buildWeekdayHeaders() {
    return Row(
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
    );
  }

  /// Lưới lịch tháng
  static Widget _buildCalendarGrid(
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

    // Ô trống cho các ngày trước ngày 1
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Các ngày trong tháng
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final isStartDate = startDate != null && _isSameDay(date, startDate);
      final isEndDate = endDate != null && _isSameDay(date, endDate);
      final isSelected = isStartDate || isEndDate;
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
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.shade800
                  : isInRange
                      ? Colors.blue.shade100
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isToday && !isSelected
                  ? Border.all(color: Colors.blue.shade800, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isInRange
                          ? Colors.blue.shade800
                          : Colors.black,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Đảm bảo luôn đủ 6 tuần (42 ô)
    const maxCells = 42;
    while (dayWidgets.length < maxCells) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  /// Nút Huỷ / Đồng ý
  static Widget _buildActionButtons(
    BuildContext context,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
  ) {
    return Row(
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
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Huỷ",
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
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
              onPressed: (selectedStartDate != null && selectedEndDate != null)
                  ? () {
                      Navigator.pop(context, [selectedStartDate, selectedEndDate]);
                    }
                  : null,
              child: const Text(
                "Đồng ý",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
