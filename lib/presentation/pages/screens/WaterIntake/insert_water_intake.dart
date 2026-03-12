import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/water_intake.dart';
import 'package:doctor_care/presentation/bloc/water_intake/water_intake_bloc.dart';
import 'package:doctor_care/presentation/pages/screens/custom_date_time/custom_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertWaterIntake extends StatefulWidget {
  final WaterIntake? record;
  const InsertWaterIntake({super.key, this.record});

  @override
  State<InsertWaterIntake> createState() => _InsertWaterIntakeState();
}

class _InsertWaterIntakeState extends State<InsertWaterIntake> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool isValid = false;
  bool hasChanges = false;

  DateTime? _selectedDateTime;


  final List<int> _quickAmounts = [200, 300, 500, 750, 1000];

  @override
  void dispose() {
    _amountController.dispose();
    _dateTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _selectedDateTime = widget.record!.timestamp;
      _dateTimeController.text = _formatDateTime(widget.record!.timestamp);
      _amountController.text = widget.record!.amount.toString();
      _noteController.text = widget.record!.note ?? '';
    } else {
      _selectedDateTime = DateTime.now();
      _dateTimeController.text = _formatDateTime(DateTime.now());
    }
    _validate();
  }

  String _formatDateTime(DateTime dateTime) {
    String date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    String time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return "$time $date";
  }

  void _validate() {
    final amount = int.tryParse(_amountController.text);

    final valid = amount != null && amount >= 50 && amount <= 2000;

    final changed = widget.record == null ||
        amount != widget.record!.amount ||
        _noteController.text != (widget.record!.note ?? '') ||
        !_selectedDateTime!.isAtSameMomentAs(widget.record!.timestamp);

    if (valid != isValid || changed != hasChanges) {
      setState(() {
        isValid = valid;
        hasChanges = changed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: widget.record != null ? "Cập nhật lượng nước" : "Thêm lượng nước",
        centerTitle: true,
        icon: widget.record != null
            ? const Icon(Icons.delete_forever_outlined, color: Colors.white, size: 22)
            : null,
        onInfo: widget.record != null
            ? () => AppDialog.showDeleteConfirm(
                  context: context,
                  content: "Bạn có chắc chắn muốn xoá bản ghi này không?",
                  onConfirm: () {
                    if (widget.record?.id != null) {
                      context.read<WaterIntakeBloc>().add(DeleteWaterIntakeRecord(widget.record!.id!.toString()));
                    }
                    AppSnackBar.showwater(
                      context: context,
                      type: SnackBarType.delete,
                    );
                    Navigator.pop(context);
                  })
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chọn thời gian",
                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Gap(8),
              TextField(
                controller: _dateTimeController,
                readOnly: true,
                style: TextStyle(fontSize: 14),
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
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  suffixIcon: Icon(Icons.access_time, color: Colors.grey, size: 24),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onTap: () {
                  CustomDateTimePicker.show(
                    context: context,
                    initialDateTime: _selectedDateTime,
                    onSelected: (dateTime) {
                      _selectedDateTime = dateTime;
                      _dateTimeController.text = _formatDateTime(dateTime);
                      _validate();
                    },
                  );
                },
              ),
              Gap(20),

              // Quick add buttons
              Text(
                "Thêm nhanh",
                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Gap(8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts.map((amount) {
                  return InkWell(
                    onTap: () {
                      _amountController.text = amount.toString();
                      _validate();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.lightBlue.shade400, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.lightBlue.shade200,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$amount ml',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Gap(20),

              // Amount
              Row(
                children: [
                  Icon(Icons.water_drop, size: 18, color: Colors.lightBlue),
                  Gap(6),
                  Text(
                    "Lượng nước (ml)",
                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Gap(5),
                  Icon(Icons.grade, size: 15, color: Colors.red),
                ],
              ),
              Gap(8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Nhập lượng nước (50-2000 ml)",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.lightBlue, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (value) => _validate(),
              ),
              Gap(20),

              // Note (optional)
              Row(
                children: [
                  Icon(Icons.note, size: 18, color: Colors.grey),
                  Gap(6),
                  Text(
                    "Ghi chú (tùy chọn)",
                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Gap(8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Ví dụ: Sau khi tập thể dục, uống nước ấm...",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (value) => _validate(),
              ),
              Gap(20),

              // Save Button
              CustomButton(
                text: widget.record != null ? "Cập nhật" : "Lưu",
                onPressed: isValid && hasChanges
                    ? () {
                        final amount = int.parse(_amountController.text);
                        final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

                        final record = WaterIntake(
                          id: widget.record?.id,
                          amount: amount,
                          timestamp: _selectedDateTime!,
                          note: note,
                        );

                        if (widget.record != null) {
                          context.read<WaterIntakeBloc>().add(UpdateWaterIntakeRecord(record));
                          AppSnackBar.showwater(
                            context: context,
                            type: SnackBarType.update,
                          );
                        } else {
                          context.read<WaterIntakeBloc>().add(AddWaterIntakeRecord(record));
                          AppSnackBar.showwater(
                            context: context,
                            type: SnackBarType.add,
                          );
                        }
                        Navigator.pop(context);
                      }
                    : null,
                expanded: true,
                enabled: isValid && hasChanges,
              ),
              Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
