import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/bmi_weight.dart';
import 'package:doctor_care/presentation/bloc/BMIWeight/bmi_weight_bloc.dart';
import 'package:doctor_care/presentation/pages/screens/custom_date_time/custom_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertBmiWeight extends StatefulWidget {
  final BMIWeight? record;
  const InsertBmiWeight({super.key, this.record});

  @override
  State<InsertBmiWeight> createState() => _InsertBmiWeightState();
}

class _InsertBmiWeightState extends State<InsertBmiWeight> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool isValid = false;
  bool hasChanges = false;

  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
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
      _weightController.text = widget.record!.weight.toStringAsFixed(1);
      _heightController.text = widget.record!.height.toStringAsFixed(0);
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
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    final valid = weight != null && 
                  weight >= 10 && 
                  weight <= 300 && 
                  height != null && 
                  height >= 50 && 
                  height <= 250;
                  
    final changed = widget.record == null ||
        weight != widget.record!.weight ||
        height != widget.record!.height ||
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
        title: widget.record != null ? "Cập nhật BMI & Cân nặng" : "Thêm BMI & Cân nặng",
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
                      context.read<BMIWeightBloc>().add(DeleteBMIWeightRecord(widget.record!.id!.toString()));
                    }
                    AppSnackBar.show(
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

              // Weight
              Row(
                children: [
                  Icon(Icons.monitor_weight, size: 18, color: Colors.purple),
                  Gap(6),
                  Text(
                    "Cân nặng (kg)",
                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Gap(5),
                  Icon(Icons.grade, size: 15, color: Colors.red),
                ],
              ),
              Gap(8),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Nhập cân nặng (10-300 kg)",
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
                    borderSide: BorderSide(color: Colors.purple, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (value) => _validate(),
              ),
              Gap(20),

              // Height
              Row(
                children: [
                  Icon(Icons.height, size: 18, color: Colors.teal),
                  Gap(6),
                  Text(
                    "Chiều cao (cm)",
                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Gap(5),
                  Icon(Icons.grade, size: 15, color: Colors.red),
                ],
              ),
              Gap(8),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Nhập chiều cao (50-250 cm)",
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
                    borderSide: BorderSide(color: Colors.teal, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (value) => _validate(),
              ),
              Gap(20),

              // BMI Preview
              if (isValid) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Builder(
                    builder: (context) {
                      final weight = double.parse(_weightController.text);
                      final height = double.parse(_heightController.text);
                      final tempRecord = BMIWeight(
                        weight: weight,
                        height: height,
                        timestamp: DateTime.now(),
                      );
                      
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics_outlined, size: 20, color: tempRecord.bmiColor),
                              Gap(8),
                              Text(
                                "BMI: ${tempRecord.bmi.toStringAsFixed(1)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: tempRecord.bmiColor,
                                ),
                              ),
                            ],
                          ),
                          Gap(8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: tempRecord.bmiBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: tempRecord.bmiColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tempRecord.bmiIcon, size: 16, color: tempRecord.bmiColor),
                                Gap(6),
                                Text(
                                  tempRecord.bmiStatus,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: tempRecord.bmiColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Gap(20),
              ],

              // Save Button
              CustomButton(
                text: widget.record != null ? "Cập nhật" : "Lưu",
                onPressed: isValid && hasChanges
                    ? () {
                        final weight = double.parse(_weightController.text);
                        final height = double.parse(_heightController.text);
                        final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

                        final record = BMIWeight(
                          id: widget.record?.id,
                          weight: weight,
                          height: height,
                          timestamp: _selectedDateTime!,
                          note: note,
                        );

                        if (widget.record != null) {
                          context.read<BMIWeightBloc>().add(UpdateBMIWeightRecord(record));
                          AppSnackBar.showbmiweight(
                            context: context,
                            type: SnackBarType.update,
                          );
                        } else {
                          context.read<BMIWeightBloc>().add(AddBMIWeightRecord(record));
                          AppSnackBar.showbmiweight(
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
