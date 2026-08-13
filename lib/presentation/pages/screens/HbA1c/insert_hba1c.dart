import 'package:doctor_care/core/localization/app_localizations.dart';
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
  final HbA1c? hba1c;

  const InsertHba1c({super.key, this.hba1c});

  @override
  State<InsertHba1c> createState() => _InsertHba1cState();
}

class _InsertHba1cState extends State<InsertHba1c> {
  final TextEditingController _hba1cController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  bool isValid = false;
  bool hasChanges = false;

  DateTime? _selectedDateTime;

  bool get isEditing => widget.hba1c != null;

  @override
  void initState() {
    super.initState();
    if (widget.hba1c != null) {
      _selectedDateTime = widget.hba1c!.date;
      _dateTimeController.text = _formatDateTime(widget.hba1c!.date);
      _hba1cController.text = widget.hba1c!.value.toString();
    } else {
      _selectedDateTime = DateTime.now();
      _dateTimeController.text = _formatDateTime(DateTime.now());
    }
    _validate();
  }

  @override
  void dispose() {
    _hba1cController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$time $date';
  }

  void _validate() {
    setState(() {
      if (_hba1cController.text.isEmpty) {
        isValid = false;
        return;
      }

      final value = double.tryParse(_hba1cController.text);
      isValid = value != null && value >= 1 && value <= 99;

      if (widget.hba1c != null) {
        final valueChanged =
            _hba1cController.text != widget.hba1c!.value.toString();
        final dateChanged = _selectedDateTime != widget.hba1c!.date;
        hasChanges = valueChanged || dateChanged;
      } else {
        hasChanges = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: isEditing
            ? context.tr('edit_hba1c_title')
            : context.tr('add_hba1c_title'),
        centerTitle: true,
        icon: isEditing
            ? const Icon(
                Icons.delete_forever_outlined,
                color: Colors.white,
                size: 22,
              )
            : null,
        onInfo: isEditing ? _confirmDelete : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('select_time'),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8),
            TextField(
              controller: _dateTimeController,
              readOnly: true,
              style: const TextStyle(fontSize: 14),
              decoration: _inputDecoration(
                suffixIcon: const Icon(
                  Icons.access_time,
                  color: Colors.grey,
                  size: 24,
                ),
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
            const Gap(15),
            Row(
              children: const [
                Text(
                  'HbA1c',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gap(5),
                Icon(Icons.grade, size: 15, color: Colors.red),
              ],
            ),
            const Gap(8),
            TextField(
              controller: _hba1cController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d{0,2}\.?\d{0,2}'),
                ),
              ],
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final numValue = double.tryParse(value);
                  if (numValue != null && numValue > 99) {
                    _hba1cController.text = '99';
                    _hba1cController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _hba1cController.text.length),
                    );
                  }
                }
                _validate();
              },
              decoration: _inputDecoration(
                hintText: context.tr('enter_hba1c'),
                suffixIcon: const Icon(
                  Icons.percent,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
            ),
            const Spacer(),
            CustomButton(
              expanded: true,
              text: isEditing ? context.tr('update_btn') : context.tr('save'),
              enabled: isValid && hasChanges,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  void _confirmDelete() {
    AppDialog.showDeleteConfirm(
      context: context,
      content: context.tr('confirm_delete_hba1c'),
      onConfirm: () {
        if (widget.hba1c?.id != null) {
          context.read<Hba1cCubit>().deleteHba1cRecord(
            widget.hba1c!.id.toString(),
          );
        }
        AppSnackBar.show(context: context, type: SnackBarType.delete);
        Navigator.pop(context);
      },
    );
  }

  void _submit() {
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
  }
}
