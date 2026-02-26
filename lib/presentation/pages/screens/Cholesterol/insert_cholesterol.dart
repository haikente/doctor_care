import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/domain/entities/cholesterol.dart';
import 'package:doctor_care/presentation/bloc/cholesterol/cholesterol_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/custom_date_time/custom_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertCholesterol extends StatefulWidget {
  final Cholesterol? cholesterol;
  const InsertCholesterol({super.key, this.cholesterol});

  @override
  State<InsertCholesterol> createState() => _InsertCholesterolState();
}

class _InsertCholesterolState extends State<InsertCholesterol> {
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _hdlController = TextEditingController();
  final TextEditingController _ldlController = TextEditingController();
  final TextEditingController _triglyceridesController =
      TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool isValid = false;
  bool hasChanges = false;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.cholesterol != null) {
      _selectedDateTime = widget.cholesterol!.timestamp;
      _dateTimeController.text = _formatDateTime(widget.cholesterol!.timestamp);
      _totalController.text = widget.cholesterol!.totalCholesterol
          .toStringAsFixed(0);
      _hdlController.text = widget.cholesterol!.hdl.toStringAsFixed(0);
      _ldlController.text = widget.cholesterol!.ldl.toStringAsFixed(0);
      _triglyceridesController.text = widget.cholesterol!.triglycerides
          .toStringAsFixed(0);
      _noteController.text = widget.cholesterol!.note ?? '';
    } else {
      _selectedDateTime = DateTime.now();
      _dateTimeController.text = _formatDateTime(DateTime.now());
    }
    _validate();
  }

  @override
  void dispose() {
    _totalController.dispose();
    _hdlController.dispose();
    _ldlController.dispose();
    _triglyceridesController.dispose();
    _dateTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}/${dt.month}/${dt.year}";

  void _validate() {
    setState(() {
      final total = double.tryParse(_totalController.text);
      final hdl = double.tryParse(_hdlController.text);
      final ldl = double.tryParse(_ldlController.text);
      final tg = double.tryParse(_triglyceridesController.text);

      isValid =
          total != null &&
          total > 0 &&
          hdl != null &&
          hdl > 0 &&
          ldl != null &&
          ldl > 0 &&
          tg != null &&
          tg > 0;

      if (widget.cholesterol == null) {
        hasChanges = isValid;
      } else {
        hasChanges =
            total != widget.cholesterol!.totalCholesterol ||
            hdl != widget.cholesterol!.hdl ||
            ldl != widget.cholesterol!.ldl ||
            tg != widget.cholesterol!.triglycerides;
      }
    });
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (required) ...[
              const Gap(5),
              const Icon(Icons.grade, size: 15, color: Colors.red),
            ],
          ],
        ),
        const Gap(8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
          ],
          onChanged: (_) => _validate(),
          decoration: InputDecoration(
            hintText: "mg/dL",
            hintStyle: const TextStyle(fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        centerTitle: true,
        title: widget.cholesterol != null
            ? "Chỉnh sửa Cholesterol"
            : "Thêm mới Cholesterol",
        icon: widget.cholesterol != null
            ? const Icon(
                Icons.delete_forever_outlined,
                color: Colors.white,
                size: 22,
              )
            : null,
        onInfo: widget.cholesterol != null
            ? () {
                AppDialog.showDeleteConfirm(
                  context: context,
                  content: "Bạn có chắc chắn muốn xoá bản ghi này không?",
                  onConfirm: () {
                    if (widget.cholesterol?.id != null) {
                      context.read<CholesterolCubit>().deleteCholesterolRecord(
                        widget.cholesterol!.id.toString(),
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
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chọn thời gian",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
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
                    _buildField(
                      "Cholesterol toàn phần (mg/dL)",
                      _totalController,
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField("HDL (mg/dL)", _hdlController),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _buildField("LDL (mg/dL)", _ldlController),
                        ),
                      ],
                    ),
                    const Gap(16),
                    _buildField(
                      "Triglycerides (mg/dL)",
                      _triglyceridesController,
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

                    const Gap(30),
                    CustomButton(
                      expanded: true,
                      text: widget.cholesterol != null ? "Cập nhật" : "Lưu",
                      enabled: isValid && hasChanges,
                      onPressed: () {
                        final record = Cholesterol(
                          id: widget.cholesterol?.id,
                          totalCholesterol: double.parse(_totalController.text),
                          hdl: double.parse(_hdlController.text),
                          ldl: double.parse(_ldlController.text),
                          triglycerides: double.parse(
                            _triglyceridesController.text,
                          ),
                          timestamp: _selectedDateTime!,
                          note: _noteController.text.isEmpty
                              ? null
                              : _noteController.text,
                        );
                        if (widget.cholesterol == null) {
                          context
                              .read<CholesterolCubit>()
                              .insertCholesterolRecord(record);
                        } else {
                          context
                              .read<CholesterolCubit>()
                              .updateCholesterolRecord(record);
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
