import 'package:doctor_care/core/localization/app_localizations.dart';
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
  final SpO2HeartRate? record;

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

  bool get isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _selectedDateTime = widget.record!.timestamp;
      _dateTimeController.text = _formatDateTime(widget.record!.timestamp);
      _spo2Controller.text = widget.record!.spo2.toString();
      _heartRateController.text = widget.record!.heartRate.toString();
      _noteController.text = widget.record!.note ?? '';
    } else {
      _selectedDateTime = DateTime.now();
      _dateTimeController.text = _formatDateTime(DateTime.now());
    }
    _validate();
  }

  @override
  void dispose() {
    _spo2Controller.dispose();
    _heartRateController.dispose();
    _dateTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$time $date';
  }

  void _validate() {
    final spo2 = int.tryParse(_spo2Controller.text);
    final heartRate = int.tryParse(_heartRateController.text);

    final valid =
        spo2 != null &&
        spo2 >= 70 &&
        spo2 <= 100 &&
        heartRate != null &&
        heartRate >= 30 &&
        heartRate <= 200;

    final changed =
        widget.record == null ||
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
        title: isEditing
            ? context.tr('edit_spo2_heart_rate_title')
            : context.tr('add_spo2_heart_rate_title'),
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
        child: SingleChildScrollView(
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
              const Gap(20),
              _buildFieldLabel(
                icon: Icons.water_drop,
                iconColor: Colors.blue,
                label: 'SPO2 (%)',
              ),
              const Gap(8),
              TextField(
                controller: _spo2Controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 14),
                decoration: _inputDecoration(
                  hintText: context.tr('enter_spo2'),
                  focusedColor: Colors.blue,
                ),
                onChanged: (value) => _validate(),
              ),
              const Gap(20),
              _buildFieldLabel(
                icon: Icons.favorite,
                iconColor: Colors.red,
                label:
                    "${context.tr('heart_rate_label')} (${context.tr('unit_bpm')})",
              ),
              const Gap(8),
              TextField(
                controller: _heartRateController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 14),
                decoration: _inputDecoration(
                  hintText: context.tr('enter_heart_rate'),
                  focusedColor: Colors.red,
                ),
                onChanged: (value) => _validate(),
              ),
              const Gap(20),
              CustomButton(
                text: isEditing ? context.tr('update_btn') : context.tr('save'),
                onPressed: isValid && hasChanges ? _submit : null,
                expanded: true,
                enabled: isValid && hasChanges,
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const Gap(6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(5),
        const Icon(Icons.grade, size: 15, color: Colors.red),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    Widget? suffixIcon,
    Color? focusedColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusedColor ?? Colors.grey, width: 1.5),
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  void _confirmDelete() {
    AppDialog.showDeleteConfirm(
      context: context,
      content: context.tr('confirm_delete_spo2_heart_rate'),
      onConfirm: () {
        if (widget.record?.id != null) {
          context.read<Spo2heartrateBloc>().add(
            DeleteSpo2HeartRateRecord(widget.record!.id!.toString()),
          );
        }
        AppSnackBar.show(context: context, type: SnackBarType.delete);
        Navigator.pop(context);
      },
    );
  }

  void _submit() {
    final spo2 = int.parse(_spo2Controller.text);
    final heartRate = int.parse(_heartRateController.text);
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    final record = SpO2HeartRate(
      id: widget.record?.id,
      spo2: spo2,
      heartRate: heartRate,
      timestamp: _selectedDateTime!,
      note: note,
    );

    if (widget.record != null) {
      context.read<Spo2heartrateBloc>().add(UpdateSpo2HeartRateRecord(record));
      AppSnackBar.showSpo2heartRate(
        context: context,
        type: SnackBarType.update,
      );
    } else {
      context.read<Spo2heartrateBloc>().add(AddSpo2HeartRateRecord(record));
      AppSnackBar.showSpo2heartRate(context: context, type: SnackBarType.add);
    }
    Navigator.pop(context);
  }
}
