import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/domain/entities/sleep_record.dart';
import 'package:doctor_care/presentation/bloc/sleep_record/sleep_record_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertSleepRecordScreen extends StatefulWidget {
  final SleepRecord? sleepRecord;
  const InsertSleepRecordScreen({super.key, this.sleepRecord});

  @override
  State<InsertSleepRecordScreen> createState() =>
      _InsertSleepRecordScreenState();
}

class _InsertSleepRecordScreenState extends State<InsertSleepRecordScreen> {
  final TextEditingController _noteController = TextEditingController();

  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 0);
  int _quality = 3;
  DateTime _selectedDate = DateTime.now();
  bool isValid = true;
  bool hasChanges = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.sleepRecord != null) {
      _bedTime = TimeOfDay.fromDateTime(widget.sleepRecord!.bedTime);
      _wakeTime = TimeOfDay.fromDateTime(widget.sleepRecord!.wakeTime);
      _quality = widget.sleepRecord!.quality;
      _selectedDate = widget.sleepRecord!.timestamp;
      _noteController.text = widget.sleepRecord!.note ?? '';
    }
    _validate();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      isValid = true;
      if (widget.sleepRecord == null) {
        hasChanges = true;
      } else {
        hasChanges =
            _bedTime != TimeOfDay.fromDateTime(widget.sleepRecord!.bedTime) ||
            _wakeTime != TimeOfDay.fromDateTime(widget.sleepRecord!.wakeTime) ||
            _quality != widget.sleepRecord!.quality ||
            _noteController.text != (widget.sleepRecord!.note ?? '');
      }
    });
  }

  Future<void> _pickTime(bool isBedTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedTime ? _bedTime : _wakeTime,
    );
    if (picked != null) {
      setState(() {
        if (isBedTime) {
          _bedTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
      _validate();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _validate();
    }
  }

  DateTime _buildDateTime(
    TimeOfDay time,
    DateTime date, {
    bool isPreviousDay = false,
  }) {
    final d = isPreviousDay ? date.subtract(const Duration(days: 1)) : date;
    return DateTime(d.year, d.month, d.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SleepRecordCubit, SleepRecordState>(
      listener: (context, state) {
        if (!_isSubmitting) return;
        if (state is SleepRecordLoaded) {
          _isSubmitting = false;
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else if (state is SleepRecordError) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: CustomStackAppBar(
          onBack: () => Navigator.pop(context),
          centerTitle: true,
          title: widget.sleepRecord != null
              ? "Chỉnh sửa giấc ngủ"
              : "Thêm mới giấc ngủ",
          icon: widget.sleepRecord != null
              ? const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.white,
                  size: 22,
                )
              : null,
          onInfo: widget.sleepRecord != null
              ? () {
                  AppDialog.showDeleteConfirm(
                    context: context,
                    content:
                        "Bạn có chắc chắn muốn xoá bản ghi giấc ngủ này không?",
                    onConfirm: () {
                      if (widget.sleepRecord?.id != null) {
                        _isSubmitting = true;
                        context.read<SleepRecordCubit>().deleteSleepRecordData(
                          widget.sleepRecord!.id.toString(),
                        );
                      }
                    },
                  );
                }
              : null,
        ),
        body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ngày ghi nhận",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Gap(20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Giờ đi ngủ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Gap(8),
                              GestureDetector(
                                onTap: () => _pickTime(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bedtime,
                                        color: Colors.indigo.shade400,
                                        size: 20,
                                      ),
                                      const Gap(8),
                                      Text(
                                        "${_bedTime.hour.toString().padLeft(2, '0')}:${_bedTime.minute.toString().padLeft(2, '0')}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Giờ thức dậy",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Gap(8),
                              GestureDetector(
                                onTap: () => _pickTime(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.wb_sunny,
                                        color: Colors.amber.shade600,
                                        size: 20,
                                      ),
                                      const Gap(8),
                                      Text(
                                        "${_wakeTime.hour.toString().padLeft(2, '0')}:${_wakeTime.minute.toString().padLeft(2, '0')}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Gap(20),
                    const Text(
                      "Chất lượng giấc ngủ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final q = index + 1;
                        final labels = ['Rất tệ', 'Tệ', 'TB', 'Tốt', 'Rất tốt'];
                        final icons = [
                          Icons.sentiment_very_dissatisfied,
                          Icons.sentiment_dissatisfied,
                          Icons.sentiment_neutral,
                          Icons.sentiment_satisfied,
                          Icons.sentiment_very_satisfied,
                        ];
                        final isSelected = _quality == q;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _quality = q);
                            _validate();
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue.shade400
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Icon(
                                  icons[index],
                                  color: isSelected
                                      ? Colors.blue.shade600
                                      : Colors.grey,
                                  size: 24,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                labels[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    const Gap(20),
                    const Text(
                      "Ghi chú (tuỳ chọn)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(8),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      onChanged: (_) => _validate(),
                      decoration: InputDecoration(
                        hintText: "Nhập ghi chú...",
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),
            CustomButton(
              expanded: true,
              text: widget.sleepRecord != null ? "Cập nhật" : "Lưu",
              enabled: isValid && hasChanges,
              onPressed: () {
                // Nếu bedTime > wakeTime → bedTime là ngày hôm trước
                final bedDateTime = _buildDateTime(
                  _bedTime,
                  _selectedDate,
                  isPreviousDay:
                      _bedTime.hour > _wakeTime.hour ||
                      (_bedTime.hour == _wakeTime.hour &&
                          _bedTime.minute >= _wakeTime.minute),
                );
                final wakeDateTime = _buildDateTime(_wakeTime, _selectedDate);

                final record = SleepRecord(
                  id: widget.sleepRecord?.id,
                  bedTime: bedDateTime,
                  wakeTime: wakeDateTime,
                  quality: _quality,
                  timestamp: _selectedDate,
                  note: _noteController.text.isEmpty
                      ? null
                      : _noteController.text,
                );

                if (widget.sleepRecord == null) {
                  _isSubmitting = true;
                  context.read<SleepRecordCubit>().insertSleepRecordData(
                    record,
                  );
                } else {
                  _isSubmitting = true;
                  context.read<SleepRecordCubit>().updateSleepRecordData(
                    record,
                  );
                }
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}
