import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/spO2heartrate.dart';
import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:doctor_care/presentation/pages/screens/custom_date_time/custom_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertSpo2HeartRate extends StatefulWidget {
  final SpO2HeartRate? record; // Optional parameter để edit
  const InsertSpo2HeartRate({super.key, this.record});

  @override
  State<InsertSpo2HeartRate> createState() => _InsertSpo2HeartRateState();
}

class _InsertSpo2HeartRateState extends State<InsertSpo2HeartRate> {
  final TextEditingController _spo2Controller = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool isValid = false;
  bool hasChanges = false;

  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _spo2Controller.dispose();
    _heartRateController.dispose();
    _dateTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Nếu có dữ liệu sẵn (edit mode), fill vào form
    if (widget.record != null) {
      _selectedDateTime = widget.record!.timestamp;
      _dateTimeController.text = _formatDateTime(widget.record!.timestamp);
      _spo2Controller.text = widget.record!.spo2.toString();
      _heartRateController.text = widget.record!.heartRate.toString();
      _noteController.text = widget.record!.note ?? '';
    } else {
      // Nếu thêm mới, dùng giá trị mặc định
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
    final spo2 = int.tryParse(_spo2Controller.text);
    final heartRate = int.tryParse(_heartRateController.text);

    final valid = spo2 != null && 
                  spo2 >= 70 && 
                  spo2 <= 100 && 
                  heartRate != null && 
                  heartRate >= 30 && 
                  heartRate <= 200;
                  
    final changed = widget.record == null ||
        spo2 != widget.record!.spo2 ||
        heartRate != widget.record!.heartRate ||
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
        title: widget.record != null ? "Cập nhật SPO2 & Nhịp tim" : "Thêm SPO2 & Nhịp tim",
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
                      context.read<Spo2heartrateBloc>().add(DeleteSpo2HeartRateRecord(widget.record!.id!.toString()));
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

              // SPO2
              Row(
                children: [
                  Icon(Icons.water_drop, size: 18, color: Colors.blue),
                  Gap(6),
                  Text(
                    "SPO2 (%)",
                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Gap(5),
                  Icon(Icons.grade, size: 15, color: Colors.red),
                ],
              ),
              Gap(8),
              TextField(
                controller: _spo2Controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Nhập SPO2 (70-100%)",
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
                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (value) => _validate(),
              ),
              Gap(20),

              // Heart Rate
              Row(
                children: [
                  Icon(Icons.favorite, size: 18, color: Colors.red),
                  Gap(6),
                  Text(
                    "Nhịp tim (bpm)",
                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Gap(5),
                  Icon(Icons.grade, size: 15, color: Colors.red),
                ],
              ),
              Gap(8),
              TextField(
                controller: _heartRateController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Nhập nhịp tim (30-200 bpm)",
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
                    borderSide: BorderSide(color: Colors.red, width: 1.5),
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
                        final spo2 = int.parse(_spo2Controller.text);
                        final heartRate = int.parse(_heartRateController.text);
                        final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

                        final record = SpO2HeartRate(
                          id: widget.record?.id,
                          spo2: spo2,
                          heartRate: heartRate,
                          timestamp: _selectedDateTime!,
                          note: note,
                        );

                        if (widget.record != null) {
                          // Update
                          context.read<Spo2heartrateBloc>().add(UpdateSpo2HeartRateRecord(record));
                          AppSnackBar.showSpo2heartRate(
                            context: context,
                            type: SnackBarType.update,
                          );
                        } else {
                          // Add
                          context.read<Spo2heartrateBloc>().add(AddSpo2HeartRateRecord(record));
                          AppSnackBar.showSpo2heartRate(
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
