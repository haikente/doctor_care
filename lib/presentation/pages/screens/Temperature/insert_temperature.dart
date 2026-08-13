import 'package:doctor_care/core/localization/app_localizations.dart';
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
  final Temperature? temperature;

  const InsertTemperature({super.key, this.temperature});

  @override
  State<InsertTemperature> createState() => _InsertTemperatureState();
}

class _InsertTemperatureState extends State<InsertTemperature> {
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  bool isValid = false;
  bool hasChanges = false;

  DateTime? _selectedDateTime;

  bool get isEditing => widget.temperature != null;

  @override
  void initState() {
    super.initState();
    if (widget.temperature != null) {
      _selectedDateTime = widget.temperature!.timestamp;
      _dateTimeController.text = _formatDateTime(widget.temperature!.timestamp);
      _temperatureController.text = widget.temperature!.value.toString();
    } else {
      _selectedDateTime = DateTime.now();
      _dateTimeController.text = _formatDateTime(DateTime.now());
    }
    _validate();
  }

  @override
  void dispose() {
    _temperatureController.dispose();
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
    final temp = double.tryParse(_temperatureController.text);
    final valid = temp != null && temp >= 30 && temp <= 45;
    final changed =
        widget.temperature == null ||
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
        title: isEditing
            ? context.tr('edit_temperature_title')
            : context.tr('add_temperature_title'),
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
              children: [
                Text(
                  context.tr('temperature_value'),
                  style: const TextStyle(
                    color: Colors.black,
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
              controller: _temperatureController,
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
                  if (numValue != null && numValue > 45) {
                    _temperatureController.text = '45';
                    _temperatureController
                        .selection = TextSelection.fromPosition(
                      TextPosition(offset: _temperatureController.text.length),
                    );
                  }
                }
                _validate();
              },
              decoration: _inputDecoration(
                hintText: context.tr('enter_temperature'),
                suffixIcon: const Icon(
                  Icons.thermostat_outlined,
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
      content: context.tr('confirm_delete_temperature'),
      onConfirm: () {
        if (widget.temperature?.id != null) {
          context.read<TemperatureCubit>().deleteTemperatureRecord(
            widget.temperature!.id.toString(),
          );
        }
        AppSnackBar.showtemperature(
          context: context,
          type: SnackBarType.delete,
        );
        Navigator.pop(context);
      },
    );
  }

  void _submit() {
    final temperature = Temperature(
      id: widget.temperature?.id,
      value: double.parse(_temperatureController.text),
      timestamp: _selectedDateTime!,
    );

    if (widget.temperature == null) {
      context.read<TemperatureCubit>().addTemperatureRecords(temperature);
      AppSnackBar.showtemperature(context: context, type: SnackBarType.add);
    } else {
      context.read<TemperatureCubit>().updateTemperatureRecord(temperature);
      AppSnackBar.showtemperature(context: context, type: SnackBarType.update);
    }
    Navigator.pop(context);
  }
}
