import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/temperature.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/custom_date_time/custom_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertTemperature extends StatefulWidget {
  final Temperature? temperature; // Optional parameter để edit
  const InsertTemperature({super.key, this.temperature});

  @override
  State<InsertTemperature> createState() => _InsertTemperatureState();
}

class _InsertTemperatureState extends State<InsertTemperature> {
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  bool isValid = false;
  bool hasChanges = false; // Kiểm tra có thay đổi hay không

  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _temperatureController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
  super.initState();
  // Nếu có dữ liệu sẵn (edit mode), fill vào form
  if (widget.temperature != null) {
    _selectedDateTime = widget.temperature!.timestamp;
    _dateTimeController.text = _formatDateTime(widget.temperature!.timestamp);
    _temperatureController.text = widget.temperature!.value.toString();
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
  final temp = double.tryParse(_temperatureController.text);

  final valid = temp != null && temp >= 30 && temp <= 45;
  final changed = widget.temperature == null ||
      temp != widget.temperature!.value ||
      !_selectedDateTime!.isAtSameMomentAs(widget.temperature!.timestamp);

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
         title: widget.temperature != null ? "Cập nhật chỉ số nhiệt độ" : "Thêm chỉ số nhiệt độ",
         centerTitle: true,
         icon: widget.temperature != null
           ? const Icon(Icons.delete_forever_outlined, color: Colors.white, size: 22)
           : null,
         onInfo: widget.temperature != null
           ? () => AppDialog.showDeleteConfirm(
           context: context,
           content: "Bạn có chắc chắn muốn xoá chỉ số nhiệt độ này không?",
           onConfirm: (){
             // Xóa bản ghi từ database
             if (widget.temperature?.id != null) {
               context.read<TemperatureCubit>().deleteTemperatureRecord(widget.temperature!.id.toString());
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
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Chọn thời gian", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),),

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
              Gap(15),

              Row(
                children: [
                  Text("Nhiệt độ", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),),
                  Gap(5),
                  Icon(Icons.grade, size: 15, color: Colors.red,),
                ],
              ),

              Gap(8),
              TextField(
                controller: _temperatureController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  // Kiểm tra nếu giá trị > 99 thì cắt về 99
                  if (value.isNotEmpty) {
                    final numValue = double.tryParse(value);
                    if (numValue != null && numValue > 99) {
                      _temperatureController.text = '99';
                      _temperatureController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _temperatureController.text.length),
                      );
                    }
                  }
                  _validate();
                },
                decoration: InputDecoration(
                  hintText: "Nhập chỉ số nhiệt độ",
                  hintStyle: TextStyle(fontSize: 14),
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
                  suffixIcon: Icon(Icons.thermostat_outlined, color: Colors.grey, size: 24),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              
              Spacer(),       
              CustomButton(
                expanded: true,
                text: widget.temperature != null ? "Cập nhật" : "Lưu",
                enabled: isValid && hasChanges,
                onPressed: () {
              final temperatures = Temperature(
              id: widget.temperature?.id,
              value: double.parse(_temperatureController.text), 
              timestamp: _selectedDateTime!,
              );

              if (widget.temperature == null) {
              context.read<TemperatureCubit>().addTemperatureRecords(temperatures);
              AppSnackBar.show(context: context, type: SnackBarType.add);
              print("Thành công");
              } else {
              context.read<TemperatureCubit>().updateTemperatureRecord(temperatures);
              AppSnackBar.show(context: context, type: SnackBarType.update);
              }
              Navigator.pop(context);
              }),
             ],
           ),
         ),
    );
  }
}