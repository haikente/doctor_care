import 'package:doctor_care/core/pages/custom_date_range_picker.dart';
import 'package:doctor_care/domain/entities/menstrual_cycle.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/presentation/bloc/menstrual_cycle/menstrual_cycle_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/MenstrualCycle/widgets/symptom_chip_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddEditCycleBottomSheet extends StatefulWidget {
  final MenstrualCycle? existing;

  const AddEditCycleBottomSheet({super.key, this.existing});

  @override
  State<AddEditCycleBottomSheet> createState() =>
      _AddEditCycleBottomSheetState();
}

class _AddEditCycleBottomSheetState extends State<AddEditCycleBottomSheet> {
  late DateTime _startDate;
  DateTime? _endDate;
  late int _periodLength;
  List<String> _symptoms = [];
  final _noteCtrl = TextEditingController();
  final _fmt = DateFormat('dd/MM/yyyy');

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.existing!;
      _startDate = e.startDate;
      _endDate = e.endDate;
      _periodLength = e.periodLength;
      _symptoms = List.from(e.symptoms);
      _noteCtrl.text = e.note ?? '';
    } else {
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, now.day);
      _periodLength = 5;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _pickDate() {
    CustomDateRangePickerDialog.show(
      context: context,
      initialStartDate: _startDate,
      initialEndDate: _endDate,
      onConfirm: (start, end) {
        setState(() {
          _startDate = start;
          _endDate = end;
          _periodLength = end.difference(start).inDays + 1;
        });
      },
    );
  }

  void _save() {
    final cubit = context.read<MenstrualCycleCubit>();
    final cycle = MenstrualCycle(
      id: widget.existing?.id,
      startDate: _startDate,
      endDate: _endDate,
      periodLength: _periodLength,
      symptoms: _symptoms,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (_isEditing) {
      cubit.editCycle(cycle);
    } else {
      cubit.addCycle(cycle);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing ? 'Chỉnh sửa chu kỳ' : 'Thêm chu kỳ mới',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Ngày bắt đầu
              _DatePickerTile(
                label: 'Ngày bắt đầu hành kinh',
                date: _startDate,
                fmt: _fmt,
                icon: Icons.play_circle_outline_rounded,
                color: Colors.blue.shade600,
                onTap: () => _pickDate(),
              ),
              const SizedBox(height: 12),

              // Ngày kết thúc
              _DatePickerTile(
                label: 'Ngày kết thúc hành kinh (tuỳ chọn)',
                date: _endDate,
                fmt: _fmt,
                icon: Icons.stop_circle_outlined,
                color: Colors.grey,
                onTap: () => _pickDate(),
                placeholder: 'Chưa chọn (đang diễn ra)',
              ),
              const SizedBox(height: 12),

              // Số ngày hành kinh
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Thời gian hành kinh',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _periodLength > 1
                          ? () => setState(() => _periodLength--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.blue.shade600,
                      iconSize: 22,
                    ),
                    Text(
                      '$_periodLength ngày',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    IconButton(
                      onPressed: _periodLength < 10
                          ? () => setState(() => _periodLength++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.blue.shade600,
                      iconSize: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Triệu chứng
              Text(
                'Triệu chứng',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              SymptomChipSelector(
                selected: _symptoms,
                onChanged: (v) => setState(() => _symptoms = v),
              ),
              const SizedBox(height: 16),

              // Ghi chú
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (tuỳ chọn)',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  hintText: 'Thêm ghi chú...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                  prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              CustomButton(
                expanded: true,
                onPressed: _save,
                text: _isEditing ? 'Cập nhật' : 'Lưu chu kỳ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat fmt;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? placeholder;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.fmt,
    required this.icon,
    required this.color,
    required this.onTap,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? fmt.format(date!)
                        : (placeholder ?? 'Chưa chọn'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: date != null ? color : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
