import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/domain/entities/blood_sugar.dart';
import 'package:doctor_care/presentation/bloc/blood_sugar/blood_sugar_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/custom_date_time/custom_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertBloodSugar extends StatefulWidget {
  final BloodSugar? bloodSugar;
  const InsertBloodSugar({super.key, this.bloodSugar});

  @override
  State<InsertBloodSugar> createState() => _InsertBloodSugarState();
}

class _InsertBloodSugarState extends State<InsertBloodSugar> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool isValid = false;
  bool hasChanges = false;
  DateTime? _selectedDateTime;
  String _selectedMealStatus = 'fasting';

  List<Map<String, String>> _getMealOptions(BuildContext context) => [
    {'key': 'fasting', 'label': context.tr('meal_status_fasting')},
    {'key': 'before_meal', 'label': context.tr('meal_status_before_meal')},
    {'key': 'after_meal', 'label': context.tr('meal_status_after_meal')},
    {'key': 'random', 'label': context.tr('meal_status_random')},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bloodSugar != null) {
      _selectedDateTime = widget.bloodSugar!.timestamp;
      _dateTimeController.text = _formatDateTime(widget.bloodSugar!.timestamp);
      _valueController.text = widget.bloodSugar!.value.toStringAsFixed(0);
      _selectedMealStatus = widget.bloodSugar!.mealStatus;
      _noteController.text = widget.bloodSugar!.note ?? '';
    } else {
      _selectedDateTime = DateTime.now();
      _dateTimeController.text = _formatDateTime(DateTime.now());
    }
    _validate();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _dateTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    String date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    String time =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return "$time $date";
  }

  void _validate() {
    setState(() {
      final value = double.tryParse(_valueController.text);
      final hasData =
          _valueController.text.isNotEmpty && value != null && value > 0;
      isValid = hasData;

      if (widget.bloodSugar == null) {
        hasChanges = isValid;
      } else {
        hasChanges =
            value != widget.bloodSugar!.value ||
            _selectedMealStatus != widget.bloodSugar!.mealStatus ||
            _selectedDateTime != widget.bloodSugar!.timestamp ||
            _noteController.text != (widget.bloodSugar!.note ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        centerTitle: true,
        title: widget.bloodSugar != null
            ? context.tr('edit_blood_sugar_title')
            : context.tr('add_blood_sugar_title'),
        icon: widget.bloodSugar != null
            ? const Icon(
                Icons.delete_forever_outlined,
                color: Colors.white,
                size: 22,
              )
            : null,
        onInfo: widget.bloodSugar != null
            ? () {
                AppDialog.showDeleteConfirm(
                  context: context,
                  content: context.tr('confirm_delete_blood_sugar'),
                  onConfirm: () {
                    if (widget.bloodSugar?.id != null) {
                      context.read<BloodSugarCubit>().deleteBloodSugarRecord(
                        widget.bloodSugar!.id.toString(),
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
          children: [
            Expanded(
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
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
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
                          context.tr('blood_sugar_value'),
                          style: const TextStyle(
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
                      controller: _valueController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}\.?\d{0,1}'),
                        ),
                      ],
                      onChanged: (_) => _validate(),
                      decoration: InputDecoration(
                        hintText: context.tr('enter_blood_sugar'),
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

                    const Gap(20),
                    Text(
                      context.tr('measurement_time'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: _getMealOptions(context).map((option) {
                        final isSelected = _selectedMealStatus == option['key'];
                        return ChoiceChip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade400,
                              width: 1.2,
                            ),
                          ),
                          label: Text(option['label']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedMealStatus = option['key']!;
                            });
                            _validate();
                          },
                          selectedColor: Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.blue.shade600
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        );
                      }).toList(),
                    ),

                    const Gap(20),
                    Text(
                      context.tr('note_optional'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(8),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      onChanged: (_) => _validate(),
                      decoration: InputDecoration(
                        hintText: "Nhập ghi chú...",
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
                  ],
                ),
              ),
            ),
            const Gap(12),
            CustomButton(
              expanded: true,
              text: widget.bloodSugar != null
                  ? context.tr('update_btn')
                  : context.tr('save'),
              enabled: isValid && hasChanges,
              onPressed: () {
                final record = BloodSugar(
                  id: widget.bloodSugar?.id,
                  value: double.parse(_valueController.text),
                  mealStatus: _selectedMealStatus,
                  timestamp: _selectedDateTime!,
                  note: _noteController.text.isEmpty
                      ? null
                      : _noteController.text,
                );

                if (widget.bloodSugar == null) {
                  context.read<BloodSugarCubit>().insertBloodSugarRecord(
                    record,
                  );
                } else {
                  context.read<BloodSugarCubit>().updateBloodSugarRecord(
                    record,
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
