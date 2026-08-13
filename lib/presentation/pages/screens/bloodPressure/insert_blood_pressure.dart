import 'package:doctor_care/core/localization/app_localizations.dart';
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
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  bool isValid = false;
  bool hasChanges = false;
  String? errorMessage;

  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    // Nếu có dữ liệu sẵn (edit mode), fill vào form
    if (widget.bloodPressure != null) {
      _selectedDateTime = widget.bloodPressure!.timestamp;
      _dateTimeController.text = _formatDateTime(
        widget.bloodPressure!.timestamp,
      );
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
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    final date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    final time =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return "$time $date";
  }

  TextInputFormatter _bloodPressureInputFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text;
      if (text.isEmpty || RegExp(r'^\d{0,3}(\.\d{0,2})?$').hasMatch(text)) {
        return newValue;
      }
      return oldValue;
    });
  }

  void _validate() {
    setState(() {
      // Parse values
      final systolic = double.tryParse(_systolicController.text);
      final diastolic = double.tryParse(_diastolicController.text);

      // 1. Kiểm tra có đủ dữ liệu không
      final hasData =
          _systolicController.text.isNotEmpty &&
          _diastolicController.text.isNotEmpty;

      // 2. Kiểm tra tâm thu > tâm trương
      if (hasData && systolic != null && diastolic != null) {
        if (systolic <= diastolic) {
          errorMessage = 'blood_pressure_systolic_greater_error';
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
        hasChanges =
            systolic != widget.bloodPressure!.systolic ||
            diastolic != widget.bloodPressure!.diastolic ||
            _selectedDateTime != widget.bloodPressure!.timestamp;
      }

      // 4. chỉ số huyết áp không được âm và không quá 300
      if (systolic != null && (systolic < 0 || systolic > 300)) {
        errorMessage = 'Chỉ số huyết áp tâm thu phải từ 0 đến 300';
        isValid = false;
      } else if (diastolic != null && (diastolic < 0 || diastolic > 300)) {
        errorMessage = 'Chỉ số huyết áp tâm trương phải từ 0 đến 300';
        isValid = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        centerTitle: true,
        title: widget.bloodPressure != null
            ? context.tr('edit_blood_pressure_title')
            : context.tr('add_blood_pressure_title'),
        icon: widget.bloodPressure != null
            ? const Icon(
                Icons.delete_forever_outlined,
                color: Colors.white,
                size: 22,
              )
            : null,
        onInfo: widget.bloodPressure != null
            ? () {
                AppDialog.showDeleteConfirm(
                  context: context,
                  content: context.tr('confirm_delete_blood_pressure'),
                  onConfirm: () {
                    if (widget.bloodPressure?.id != null) {
                      context
                          .read<BloodPressureCubit>()
                          .deleteBloodPressureRecord(
                            widget.bloodPressure!.id.toString(),
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
            Text(
              context.tr('select_time'),
              style: TextStyle(
                color: AppColor.textSecondary(context),
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
                onSelected: (datetime) {
                  _selectedDateTime = datetime;
                  _dateTimeController.text = _formatDateTime(datetime);
                  _validate();
                },
              ),
            ),
            const Gap(20),
            Row(
              children: [
                Text(
                  "${context.tr('blood_pressure_systolic')} (${context.tr('unit_mmhg')})",
                  style: TextStyle(
                    color: AppColor.textSecondary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(5),
                const Icon(Icons.grade, size: 15, color: Colors.red),
              ],
            ),
            const Gap(8),
            TextField(
              controller: _systolicController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                _bloodPressureInputFormatter(),
              ],
              onChanged: (value) {
                _validate();
              },
              decoration: InputDecoration(
                hintText: context.tr('enter_blood_pressure_systolic'),
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
            if (errorMessage != null) ...[
              const Gap(8),
              Text(
                context.tr(errorMessage!),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const Gap(20),
            Row(
              children: [
                Text(
                  "${context.tr('blood_pressure_diastolic')} (${context.tr('unit_mmhg')})",
                  style: TextStyle(
                    color: AppColor.textSecondary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(5),
                const Icon(Icons.grade, size: 15, color: Colors.red),
              ],
            ),
            const Gap(8),
            TextField(
              controller: _diastolicController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                _bloodPressureInputFormatter(),
              ],
              onChanged: (value) {
                _validate();
              },
              decoration: InputDecoration(
                hintText: context.tr('enter_blood_pressure_diastolic'),
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
            if (errorMessage != null) ...[
              const Gap(8),
              Text(
                context.tr('blood_pressure_diastolic_less_error'),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const Spacer(),
            CustomButton(
              expanded: true,
              text: widget.bloodPressure != null
                  ? context.tr('update_btn')
                  : context.tr('save'),
              enabled: isValid && hasChanges,
              onPressed: () {
                final bloodPressure = BloodPressure(
                  timestamp: _selectedDateTime!,
                  id: widget.bloodPressure?.id,
                  systolic: double.parse(_systolicController.text).toInt(),
                  diastolic: double.parse(_diastolicController.text).toInt(),
                  source: widget.bloodPressure?.source ?? 'manual',
                );

                if (widget.bloodPressure == null) {
                  context
                      .read<BloodPressureCubit>()
                      .insertBloodPressureRecord(bloodPressure);
                  AppSnackBar.showBloodPressure(
                    context: context,
                    type: SnackBarType.add,
                  );
                } else {
                  context
                      .read<BloodPressureCubit>()
                      .updateBloodPressureRecord(bloodPressure);
                  AppSnackBar.showBloodPressure(
                    context: context,
                    type: SnackBarType.update,
                  );
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
