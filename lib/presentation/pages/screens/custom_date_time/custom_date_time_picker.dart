import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomDateTimePicker {
  static void show({
    required BuildContext context,
    DateTime? initialDateTime,
    required Function(DateTime) onSelected,
  }) {
    DateTime tempDate = initialDateTime ?? DateTime.now();
    int tempHour = tempDate.hour;
    int tempMinute = tempDate.minute;
    DateTime? selectedDateTime = initialDateTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _header(),
                  _calendarSection(
                    tempDate,
                    selectedDateTime,
                    (date) {
                      setModalState(() {
                        selectedDateTime = date;
                        tempDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          tempHour,
                          tempMinute,
                        );
                      });
                    },
                    (newDate) => setModalState(() => tempDate = newDate),
                    tempHour,
                    tempMinute,
                  ),
                  const Gap(10),
                  _timePicker(
                    tempHour,
                    tempMinute,
                    (h) => setModalState(() => tempHour = h),
                    (m) => setModalState(() => tempMinute = m),
                  ),
                  _buttons(
                    onCancel: () => Navigator.pop(context),
                    onConfirm: () {
                      onSelected(
                        DateTime(
                          tempDate.year,
                          tempDate.month,
                          tempDate.day,
                          tempHour,
                          tempMinute,
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ===================== UI PARTS =====================

  static Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: 48,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static Widget _calendarSection(
    DateTime tempDate,
    DateTime? selectedDateTime,
    Function(DateTime) onDateSelected,
    Function(DateTime) onMonthChanged,
    int hour,
    int minute,
  ) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              _calendarNavigation(tempDate, onMonthChanged, hour, minute),
              Divider(color: Colors.grey.shade300),
              _weekDays(),
              Expanded(
                child: _buildCalendarGrid(tempDate, selectedDateTime, onDateSelected),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _calendarNavigation(
    DateTime tempDate,
    Function(DateTime) onChanged,
    int hour,
    int minute,
  ) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.keyboard_double_arrow_left, color: Colors.blue.shade800),
          onPressed: () => onChanged(
            DateTime(tempDate.year - 1, tempDate.month, tempDate.day, hour, minute),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.blue.shade800),
          onPressed: () => onChanged(
            DateTime(tempDate.year, tempDate.month - 1, tempDate.day, hour, minute),
          ),
        ),
        Text(
          "Tháng ${tempDate.month} ${tempDate.year}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Icon(Icons.arrow_drop_down, color: Colors.grey),
        IconButton(
          icon: Icon(Icons.chevron_right, color: Colors.blue.shade800),
          onPressed: () => onChanged(
            DateTime(tempDate.year, tempDate.month + 1, tempDate.day, hour, minute),
          ),
        ),
        Expanded(
          child: IconButton(
            icon: Icon(Icons.keyboard_double_arrow_right_outlined, color: Colors.blue.shade800),
            onPressed: () => onChanged(
              DateTime(tempDate.year + 1, tempDate.month, tempDate.day, hour, minute),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _weekDays() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
          .map(
            (day) => SizedBox(
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
            ),
          )
          .toList(),
    );
  }

  static Widget _timePicker(
    int hour,
    int minute,
    Function(int) onHourChanged,
    Function(int) onMinuteChanged,
  ) {
    return SizedBox(
      height: 160,
      width: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background highlight
          Positioned(
            left: 16,
            right: 16,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Pickers
          Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: hour),
                  selectionOverlay: null,
                  onSelectedItemChanged: onHourChanged,
                  children: List.generate(
                    24,
                    (index) => Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 24, color: Colors.blue.shade900),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: minute),
                  selectionOverlay: null,
                  onSelectedItemChanged: onMinuteChanged,
                  children: List.generate(
                    60,
                    (index) => Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 24, color: Colors.blue.shade900),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buttons({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
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
                onPressed: onCancel,
                child: Text(
                  "Hủy",
                  style: TextStyle(color: Colors.blue.shade900),
                ),
              ),
            ),
          ),
          const Gap(10),
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
                onPressed: onConfirm,
                child: const Text(
                  "Xác nhận",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== CALENDAR GRID =====================

  static Widget _buildCalendarGrid(
    DateTime displayMonth,
    DateTime? selectedDateTime,
    Function(DateTime) onDateSelected,
  ) {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    // Empty cells for previous month
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(SizedBox(width: 40, height: 40));
    }

    // Days in month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final isSelected = selectedDateTime != null &&
          date.year == selectedDateTime.year &&
          date.month == selectedDateTime.month &&
          date.day == selectedDateTime.day;
      final isToday = date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;

      dayWidgets.add(
        GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade800 : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isToday && !isSelected
                  ? Border.all(color: Colors.blue.shade800, width: 1)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fill remaining cells
    const maxCells = 42;
    while (dayWidgets.length < maxCells) {
      dayWidgets.add(SizedBox(width: 40, height: 40));
    }

    const rowCount = 6;
    const cellSize = 40.0;
    const cellMargin = 8.0;
    const mainSpacing = 2.0;
    const height = rowCount * (cellSize + cellMargin) + (rowCount - 1) * mainSpacing;

    return SizedBox(
      height: height,
      child: GridView.count(
        crossAxisCount: 7,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: dayWidgets,
      ),
    );
  }
}