import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterBottomSheetFP extends StatelessWidget {
  final DateTime? initialDate;
  final Function(DateTime?) onDateSelected;

  const FilterBottomSheetFP({
    super.key,
    this.initialDate,
    required this.onDateSelected,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    DateTime? result;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return _DatePickerDialog(
          initialDate: initialDate,
          onConfirm: (date) {
            result = date;
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
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await FilterBottomSheetFP.show(
          context,
          initialDate: initialDate,
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.tr('date_of_birth_label'),
          prefixIcon: const Icon(Icons.cake_outlined),
          suffixIcon: initialDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onDateSelected(null),
                )
              : const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          initialDate != null
              ? _formatDate(initialDate!)
              : context.tr('choose_date_of_birth'),
          style: TextStyle(
            color: initialDate != null ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}

// ─── Dialog nội bộ ───────────────────────────────────────────────────────────

class _DatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onConfirm;

  const _DatePickerDialog({this.initialDate, required this.onConfirm});

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  late DateTime? selectedDate;
  late DateTime displayMonth;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    displayMonth = widget.initialDate ?? DateTime(2000);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 470,
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header navigation
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.keyboard_double_arrow_left,
                        color: Colors.blue.shade800,
                      ),
                      onPressed: () {
                        setState(() {
                          displayMonth = DateTime(
                            displayMonth.year - 1,
                            displayMonth.month,
                          );
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: Colors.blue.shade800,
                      ),
                      onPressed: () {
                        setState(() {
                          displayMonth = DateTime(
                            displayMonth.year,
                            displayMonth.month - 1,
                          );
                        });
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "${context.tr('month')} ${displayMonth.month} ${displayMonth.year}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: Colors.blue.shade800,
                      ),
                      onPressed: () {
                        setState(() {
                          displayMonth = DateTime(
                            displayMonth.year,
                            displayMonth.month + 1,
                          );
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.keyboard_double_arrow_right_outlined,
                        color: Colors.blue.shade800,
                      ),
                      onPressed: () {
                        setState(() {
                          displayMonth = DateTime(
                            displayMonth.year + 1,
                            displayMonth.month,
                          );
                        });
                      },
                    ),
                  ],
                ),
                Divider(color: Colors.grey.shade300),

                // Weekday headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:
                      [
                            context.tr('day_mon'),
                            context.tr('day_tue'),
                            context.tr('day_wed'),
                            context.tr('day_thu'),
                            context.tr('day_fri'),
                            context.tr('day_sat'),
                            context.tr('day_sun'),
                          ]
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
                ),

                // Calendar grid
                _buildCalendarGrid(),

                // Buttons
                Divider(color: Colors.grey.shade300),
                const Gap(5),
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
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            context.tr('cancel'),
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
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade900,
                            ],
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
                            if (selectedDate != null) {
                              widget.onConfirm(selectedDate!);
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            context.tr('confirm'),
                            style: const TextStyle(color: Colors.white),
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
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(
      displayMonth.year,
      displayMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    // Empty cells before first day
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final isSelected =
          selectedDate != null && _isSameDay(date, selectedDate!);
      final isToday = _isSameDay(date, DateTime.now());
      final isFuture = date.isAfter(DateTime.now());

      dayWidgets.add(
        GestureDetector(
          onTap: isFuture
              ? null
              : () {
                  setState(() {
                    selectedDate = date;
                  });
                },
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
                  color: isSelected
                      ? Colors.white
                      : isFuture
                      ? Colors.grey.shade300
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

    // Fill remaining cells (6 weeks = 42 cells)
    const maxCells = 42;
    while (dayWidgets.length < maxCells) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    const rowCount = 6;
    const cellSize = 40.0;
    const cellMargin = 8.0;
    const mainSpacing = 2.0;
    const height =
        rowCount * (cellSize + cellMargin) + (rowCount - 1) * mainSpacing;

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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
