import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/hba1c.dart';
import 'package:doctor_care/presentation/bloc/hba1c/hba1c_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/custom_date_time/custom_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertHba1c extends StatefulWidget {
  final HbA1c? hba1c; // Optional parameter để edit
  const InsertHba1c({super.key, this.hba1c});

  @override
  State<InsertHba1c> createState() => _InsertHba1cState();
}

class _InsertHba1cState extends State<InsertHba1c> {
  final TextEditingController _hba1cController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  bool isValid = false;
  bool hasChanges = false; // Kiểm tra có thay đổi hay không
  
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _hba1cController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

// initState de chuan bi du lieu khi vao trang
  @override
void initState() {
  super.initState();
  // Nếu có dữ liệu sẵn (edit mode), fill vào form
  if (widget.hba1c != null) {
    _selectedDateTime = widget.hba1c!.date;
    _dateTimeController.text = _formatDateTime(widget.hba1c!.date);
    _hba1cController.text = widget.hba1c!.value.toString();
  } else {
    // Nếu thêm mới, dùng giá trị mặc định
    _selectedDateTime = DateTime.now();
    _dateTimeController.text = _formatDateTime(DateTime.now());
  }
  _valiSate();
}

String _formatDateTime(DateTime dateTime) {
  String date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  String time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  return "$time $date";
}

// Hàm kiểm tra tính hợp lệ và thay đổi
void _valiSate(){
  setState(() {
    if (_hba1cController.text.isEmpty) {
      isValid = false;
      return;
    }
    
    final value = double.tryParse(_hba1cController.text);
    isValid = value != null && value >= 1 && value <= 99;
    
    // Kiểm tra có thay đổi hay không (chỉ khi edit mode)
    if (widget.hba1c != null) {
      final valueChanged = _hba1cController.text != widget.hba1c!.value.toString();
      final dateChanged = _selectedDateTime != widget.hba1c!.date;
      hasChanges = valueChanged || dateChanged;
    } else {
      // Add mode: luôn cho phép lưu nếu valid
      hasChanges = true;
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
         title: widget.hba1c != null ? "Cập nhật chỉ số HbA1c" : "Thêm chỉ số HbA1c",
         centerTitle: true,
         icon: widget.hba1c != null 
           ? const Icon(Icons.delete_forever_outlined, color: Colors.white, size: 22) 
           : null,
         onInfo: widget.hba1c != null 
           ? () => AppDialog.showDeleteConfirm(
           context: context, 
           content: "Bạn có chắc chắn muốn xoá chỉ số HbA1c này không?",
           onConfirm: (){
             // Xóa bản ghi từ database
             if (widget.hba1c?.id != null) {
               context.read<Hba1cCubit>().deleteHba1cRecord(widget.hba1c!.id.toString());
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
                      _valiSate();
                    },
                  );
                },
              ),
              Gap(15),

              Row(
                children: [
                  Text("HbA1c", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),),
                  Gap(5),
                  Icon(Icons.grade, size: 15, color: Colors.red,),
                ],
              ),

              Gap(8),
              TextField(
                controller: _hba1cController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  // Kiểm tra nếu giá trị > 99 thì cắt về 99
                  if (value.isNotEmpty) {
                    final numValue = double.tryParse(value);
                    if (numValue != null && numValue > 99) {
                      _hba1cController.text = '99';
                      _hba1cController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _hba1cController.text.length),
                      );
                    }
                  }
                  _valiSate();
                },
                decoration: InputDecoration(
                  hintText: "Nhập chỉ số HbA1c",
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
                  suffixIcon: Icon(Icons.percent, color: Colors.grey, size: 24),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              
              Spacer(),       
              CustomButton(
                expanded: true,
                text: widget.hba1c != null ? "Cập nhật" : "Lưu",
                enabled: isValid && hasChanges,
                onPressed: () {
              final hba1c = HbA1c(
              id: widget.hba1c?.id,
              value: double.parse(_hba1cController.text),
              date: _selectedDateTime!,
             );

              if (widget.hba1c == null) {
              context.read<Hba1cCubit>().addHba1cRecord(hba1c);
              AppSnackBar.show(context: context, type: SnackBarType.add);
              } else {
              context.read<Hba1cCubit>().updateHba1cRecord(hba1c);
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