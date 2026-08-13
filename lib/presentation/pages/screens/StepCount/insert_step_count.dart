import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/domain/entities/step_count.dart';
import 'package:doctor_care/presentation/bloc/step_count/step_count_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/custom_date_time/custom_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertStepCount extends StatefulWidget {
  final StepCount? stepCount;
  const InsertStepCount({super.key, this.stepCount});

  @override
  State<InsertStepCount> createState() => _InsertStepCountState();
}

class _InsertStepCountState extends State<InsertStepCount> {
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool isValid = false;
  bool hasChanges = false;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.stepCount != null) {
      _selectedDateTime = widget.stepCount!.timestamp;
      _dateTimeController.text = _formatDateTime(widget.stepCount!.timestamp);
      _stepsController.text = widget.stepCount!.steps.toString();
      _distanceController.text =
          widget.stepCount!.distance?.toStringAsFixed(1) ?? '';
      _caloriesController.text =
          widget.stepCount!.caloriesBurned?.toStringAsFixed(0) ?? '';
      _noteController.text = widget.stepCount!.note ?? '';
    } else {
      _selectedDateTime = DateTime.now();
      _dateTimeController.text = _formatDateTime(DateTime.now());
    }
    _validate();
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _distanceController.dispose();
    _caloriesController.dispose();
    _dateTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}/${dt.month}/${dt.year}";

  void _validate() {
    setState(() {
      final steps = int.tryParse(_stepsController.text);
      isValid = steps != null && steps > 0;
      if (widget.stepCount == null) {
        hasChanges = isValid;
      } else {
        hasChanges =
            steps != widget.stepCount!.steps ||
            _distanceController.text !=
                (widget.stepCount!.distance?.toStringAsFixed(1) ?? '') ||
            _caloriesController.text !=
                (widget.stepCount!.caloriesBurned?.toStringAsFixed(0) ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        centerTitle: true,
        title: widget.stepCount != null
            ? "Chỉnh sửa bước chân"
            : "Thêm mới bước chân",
        icon: widget.stepCount != null
            ? const Icon(
                Icons.delete_forever_outlined,
                color: Colors.white,
                size: 22,
              )
            : null,
        onInfo: widget.stepCount != null
            ? () {
                AppDialog.showDeleteConfirm(
                  context: context,
                  content: "Bạn có chắc chắn muốn xoá bản ghi này không?",
                  onConfirm: () {
                    if (widget.stepCount?.id != null) {
                      context.read<StepCountCubit>().deleteStepCountRecord(
                        widget.stepCount!.id.toString(),
                      );
                      Navigator.pop(context);
                    }
                  },
                );
              }
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn thời gian",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const Gap(8),
            TextField(
              controller: _dateTimeController,
              readOnly: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                suffixIcon: const Icon(
                  Icons.access_time,
                  color: Colors.grey,
                  size: 24,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onTap: () => CustomDateTimePicker.show(
                context: context,
                initialDateTime: _selectedDateTime,
                onSelected: (dt) {
                  _selectedDateTime = dt;
                  _dateTimeController.text = _formatDateTime(dt);
                  _validate();
                },
              ),
            ),

            const Gap(20),
            Row(
              children: const [
                Text(
                  "Số bước chân",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Gap(5),
                Icon(Icons.grade, size: 15, color: Colors.red),
              ],
            ),
            const Gap(8),
            TextField(
              controller: _stepsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _validate(),
              decoration: InputDecoration(
                hintText: "Nhập số bước",
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
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
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
                        "Khoảng cách (km)",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(8),
                      TextField(
                        controller: _distanceController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,3}\.?\d{0,1}'),
                          ),
                        ],
                        onChanged: (_) => _validate(),
                        decoration: InputDecoration(
                          hintText: "Tuỳ chọn",
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
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Calo (kcal)",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(8),
                      TextField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => _validate(),
                        decoration: InputDecoration(
                          hintText: "Tuỳ chọn",
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
              ],
            ),

            const Spacer(),
            CustomButton(
              expanded: true,
              text: widget.stepCount != null ? "Cập nhật" : "Lưu",
              enabled: isValid && hasChanges,
              onPressed: () {
                final record = StepCount(
                  id: widget.stepCount?.id,
                  steps: int.parse(_stepsController.text),
                  distance: _distanceController.text.isNotEmpty
                      ? double.parse(_distanceController.text)
                      : null,
                  caloriesBurned: _caloriesController.text.isNotEmpty
                      ? double.parse(_caloriesController.text)
                      : null,
                  timestamp: _selectedDateTime!,
                  note: _noteController.text.isEmpty
                      ? null
                      : _noteController.text,
                  source: widget.stepCount?.source ?? StepCountSource.manual,
                );
                if (widget.stepCount == null) {
                  context.read<StepCountCubit>().insertStepCountRecord(record);
                } else {
                  context.read<StepCountCubit>().updateStepCountRecord(record);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
