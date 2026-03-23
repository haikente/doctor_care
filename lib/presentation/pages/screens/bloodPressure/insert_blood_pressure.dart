import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/blood_pressure.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/custom_date_time/custom_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertBloodPressure extends StatefulWidget {
  final BloodPressure? bloodPressure;
  const InsertBloodPressure({super.key, this.bloodPressure});

  @override
  State<InsertBloodPressure> createState() => _InsertBloodPressureState();
}

class _InsertBloodPressureState extends State<InsertBloodPressure> {
  final  TextEditingController _systolicController = TextEditingController();
  final  TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  bool isValid = false; 
  bool hasChanges = false; 
  String? errorMessage;
  
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }
  
 String _formatDateTime(DateTime dateTime) {
  String date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  String time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  return "$time $date";
}

void _validate() {
    setState(() {
      // Parse values
      final systolic = double.tryParse(_systolicController.text);
      final diastolic = double.tryParse(_diastolicController.text);
      
      // 1. Kiểm tra có đủ dữ liệu không
      final hasData = _systolicController.text.isNotEmpty && 
                      _diastolicController.text.isNotEmpty;
      
      // 2. Kiểm tra tâm thu > tâm trương
      if (hasData && systolic != null && diastolic != null) {
        if (systolic <= diastolic) {
          errorMessage = "Chỉ số tâm thu phải lớn hơn tâm trương";
          isValid = false;
        } else {
          errorMessage = null;
          isValid = true;
        }
      } else {
        errorMessage = null;
        isValid = hasData;
      }
      
      // 3. Kiểm tra changes
      if (widget.bloodPressure == null) {
        hasChanges = isValid;
      } else {
        hasChanges = systolic != widget.bloodPressure!.systolic ||
                     diastolic != widget.bloodPressure!.diastolic ||
                     _selectedDateTime != widget.bloodPressure!.timestamp;
      }
    });
  }

    @override
void initState() {
  super.initState();
  // Nếu có dữ liệu sẵn (edit mode), fill vào form
  if (widget.bloodPressure != null) {
    _selectedDateTime = widget.bloodPressure!.timestamp;
    _dateTimeController.text = _formatDateTime(widget.bloodPressure!.timestamp);
    _systolicController.text = widget.bloodPressure!.systolic.toString();
    _diastolicController.text = widget.bloodPressure!.diastolic.toString();
  } else {
    // Nếu thêm mới, dùng giá trị mặc định
    _selectedDateTime = DateTime.now();
    _dateTimeController.text = _formatDateTime(DateTime.now());
  }
  _validate();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
       onBack: () => Navigator.pop(context),
        centerTitle: true,
        title: widget.bloodPressure != null ? "Chỉnh sửa chỉ số huyết áp" : "Thêm mới chỉ số huyết áp",
        icon: widget.bloodPressure != null
          ? const Icon(Icons.delete_forever_outlined, color: Colors.white, size: 22) 
          : null,
        onInfo: widget.bloodPressure != null
          ? () {
              AppDialog.showDeleteConfirm(
                context: context,
                content: "Bạn có chắc chắn muốn xoá chỉ số huyết áp này không?",
                onConfirm: (){
                  if(widget.bloodPressure?.id != null) {
                    context.read<BloodPressureCubit>().deleteBloodPressureRecord(widget.bloodPressure!.id.toString());
                    Navigator.pop(context);
                  }
                });
            }
          : null,
        ),
      body: Padding( padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Chọn thời gian", style: TextStyle(color: AppColor.textSecondary(context), fontSize: 14, fontWeight: FontWeight.w500),),

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
                onTap: () => CustomDateTimePicker.show(
                  context: context,
                  initialDateTime: _selectedDateTime, 
                  onSelected: (datetime){
                    _selectedDateTime = datetime;
                    _dateTimeController.text = _formatDateTime(datetime);
                    _validate();
                  }),
              ),

              Gap(20),

              Row(
                children: [
                  Text("Tâm thu (mmHg)", style: TextStyle(color: AppColor.textSecondary(context), fontSize: 14, fontWeight: FontWeight.w500),),
                  Gap(5),
                  Icon(Icons.grade, size: 15, color: Colors.red,),
                ],
              ),

              Gap(8),
              TextField(
                controller: _systolicController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  _validate();
                },
                decoration: InputDecoration(
                  hintText: "Nhập chỉ số tâm thu",
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
                  borderSide: BorderSide(
                    color: Colors.grey.shade300, 
                    width: 1
                  ),
                ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),

              if (errorMessage != null) ...[
              Gap(8),
              Text(
                errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

              Gap(20),
              Row(
                children: [
                  Text("Tâm trương (mmHg)", style: TextStyle(color: AppColor.textSecondary(context), fontSize: 14, fontWeight: FontWeight.w500),),
                  Gap(5),
                  Icon(Icons.grade, size: 15, color: Colors.red,),
                ],
              ),

              Gap(8),
              TextField(
                controller: _diastolicController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  _validate();
                },
                decoration: InputDecoration(
                  hintText: "Nhập chỉ số tâm trương",
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
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1
                  ),
                ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),

              if (errorMessage != null) ...[
              Gap(8),
              Text(
                "Chỉ số tâm trương phải nhỏ hơn tâm thu",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

              Spacer(),       
              CustomButton(
                expanded: true,
                text: widget.bloodPressure != null ? "Cập nhật" : "Lưu",
                enabled: isValid && hasChanges,
                onPressed: () {
              final bloodPressure = BloodPressure(
                timestamp: _selectedDateTime!,
                id: widget.bloodPressure?.id,
                systolic: double.parse(_systolicController.text).toInt(),
                diastolic: double.parse(_diastolicController.text).toInt(),
              );

              if (widget.bloodPressure == null) {
              context.read<BloodPressureCubit>().insertBloodPressureRecord(bloodPressure);
              AppSnackBar.showBloodPressure(context: context, type: SnackBarType.add);
              } else {
              context.read<BloodPressureCubit>().updateBloodPressureRecord(bloodPressure);
              AppSnackBar.showBloodPressure(context: context, type: SnackBarType.update);
              }
              Navigator.pop(context);
               }
              ),
             ],
      ),
      ),  
    );
  }
}