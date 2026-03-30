import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/domain/entities/creatinine.dart';
import 'package:doctor_care/presentation/bloc/creatinine/creatinine_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/custom_date_time/custom_date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertCreatinine extends StatefulWidget {
  final Creatinine? creatinine;
  const InsertCreatinine({super.key, this.creatinine});

  @override
  State<InsertCreatinine> createState() => _InsertCreatinineState();
}

class _InsertCreatinineState extends State<InsertCreatinine> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool isValid = false;
  bool hasChanges = false;
  String? errorMessage;

  DateTime? _selectedDateTime;
  int? _userAge;
  String? _userGender;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    if (widget.creatinine != null) {
      _selectedDateTime = widget.creatinine!.timestamp;
      _dateTimeController.text = _formatDateTime(widget.creatinine!.timestamp);
      _valueController.text = widget.creatinine!.value.toString();
      _noteController.text = widget.creatinine!.note ?? '';
    } else {
      _selectedDateTime = DateTime.now();
      _dateTimeController.text = _formatDateTime(DateTime.now());
    }
    _validate();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userGender = data['gender'];
          if (data['dateOfBirth'] != null) {
            final dob = DateTime.parse(data['dateOfBirth']);
            final today = DateTime.now();
            _userAge = today.year - dob.year;
            if (today.month < dob.month ||
                (today.month == dob.month && today.day < dob.day)) {
              _userAge = _userAge! - 1;
            }
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _valueController.dispose();
    _dateTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    String date =
        "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
    String time =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return "$time $date";
  }

  void _validate() {
    setState(() {
      final valueText = _valueController.text.trim();
      final value = double.tryParse(valueText);

      final hasData = valueText.isNotEmpty;

      if (hasData) {
        if (value == null || value <= 0) {
          errorMessage = "Giá trị không hợp lệ";
          isValid = false;
        } else if (value > 30) {
          errorMessage = "Giá trị quá cao (tối đa 30 mg/dL)";
          isValid = false;
        } else {
          errorMessage = null;
          isValid = true;
        }
      } else {
        errorMessage = null;
        isValid = false;
      }

      if (widget.creatinine == null) {
        hasChanges = isValid;
      } else {
        hasChanges =
            (value != widget.creatinine!.value ||
            _selectedDateTime != widget.creatinine!.timestamp ||
            _noteController.text.trim() != (widget.creatinine!.note ?? ''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        centerTitle: true,
        title: widget.creatinine != null
            ? "Chỉnh sửa Creatinine"
            : "Thêm mới Creatinine",
        icon: widget.creatinine != null
            ? const Icon(
                Icons.delete_forever_outlined,
                color: Colors.white,
                size: 22,
              )
            : null,
        onInfo: widget.creatinine != null
            ? () {
                AppDialog.showDeleteConfirm(
                  context: context,
                  content:
                      "Bạn có chắc chắn muốn xoá chỉ số Creatinine này không?",
                  onConfirm: () {
                    if (widget.creatinine?.id != null) {
                      context.read<CreatinineCubit>().deleteCreatinineRecord(
                        widget.creatinine!.id.toString(),
                      );
                      Navigator.pop(context);
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
                      "Chọn thời gian",
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
                          "Giá trị Creatinine (mg/dL)",
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
                      controller: _valueController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,2}\.?\d{0,2}'),
                        ),
                      ],
                      onChanged: (value) => _validate(),
                      decoration: InputDecoration(
                        hintText: "Nhập giá trị Creatinine",
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
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const Gap(20),

                    // eGFR Preview
                    _buildEGFRPreview(),

                    const Gap(20),

                    // Reference Info
                    _buildReferenceInfo(),

                    const Gap(20),

                    Text(
                      "Ghi chú (Tuỳ chọn)",
                      style: TextStyle(
                        color: AppColor.textSecondary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(8),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      onChanged: (value) => _validate(),
                      decoration: InputDecoration(
                        hintText: "Thêm ghi chú",
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
                  ],
                ),
              ),
            ),
            CustomButton(
              expanded: true,
              text: widget.creatinine != null ? "Cập nhật" : "Lưu",
              enabled: isValid && hasChanges,
              onPressed: () {
                final record = Creatinine(
                  id: widget.creatinine?.id,
                  value: double.parse(_valueController.text.trim()),
                  timestamp: _selectedDateTime!,
                  note: _noteController.text.trim().isEmpty
                      ? null
                      : _noteController.text.trim(),
                  age: _userAge,
                  gender: _userGender,
                );

                if (widget.creatinine == null) {
                  context.read<CreatinineCubit>().insertCreatinineRecord(
                    record,
                  );
                } else {
                  context.read<CreatinineCubit>().updateCreatinineRecord(
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

  Widget _buildEGFRPreview() {
    final value = double.tryParse(_valueController.text.trim());
    if (value == null ||
        value <= 0 ||
        _userAge == null ||
        _userGender == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade500, size: 20),
            const Gap(10),
            Expanded(
              child: Text(
                _userAge == null || _userGender == null
                    ? 'Cập nhật hồ sơ (tuổi, giới tính) để tự động tính eGFR'
                    : 'Nhập giá trị Creatinine hợp lệ để xem eGFR',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      );
    }

    final temp = Creatinine(
      value: value,
      timestamp: DateTime.now(),
      age: _userAge,
      gender: _userGender,
    );
    final eGFR = temp.eGFR;

    if (eGFR == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'eGFR ước tính',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _getEGFRColor(eGFR).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  temp.ckdStage,
                  style: TextStyle(
                    color: _getEGFRColor(eGFR),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                eGFR.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _getEGFRColor(eGFR),
                ),
              ),
              const Gap(6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  'mL/min/1.73m²',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const Gap(8),
          _buildEGFRBar(eGFR),
        ],
      ),
    );
  }

  Widget _buildEGFRBar(double eGFR) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(
                  flex: 15,
                  child: Container(color: Colors.red.shade400),
                ),
                Expanded(
                  flex: 15,
                  child: Container(color: Colors.deepOrange.shade300),
                ),
                Expanded(
                  flex: 15,
                  child: Container(color: Colors.orange.shade300),
                ),
                Expanded(
                  flex: 15,
                  child: Container(color: Colors.yellow.shade600),
                ),
                Expanded(
                  flex: 30,
                  child: Container(color: Colors.lightGreen.shade400),
                ),
                Expanded(
                  flex: 10,
                  child: Container(color: Colors.green.shade500),
                ),
              ],
            ),
          ),
        ),
        const Gap(4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            Text(
              '15',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            Text(
              '30',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            Text(
              '45',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            Text(
              '60',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            Text(
              '90',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            Text(
              '120+',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  Color _getEGFRColor(double eGFR) {
    if (eGFR >= 90) return Colors.green.shade600;
    if (eGFR >= 60) return Colors.lightGreen.shade600;
    if (eGFR >= 45) return Colors.yellow.shade800;
    if (eGFR >= 30) return Colors.orange;
    if (eGFR >= 15) return Colors.deepOrange;
    return Colors.red;
  }

  Widget _buildReferenceInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information,
                color: Colors.grey.shade700,
                size: 18,
              ),
              const Gap(8),
              Text(
                'Khoảng tham chiếu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const Gap(10),
          _buildRefRow('Nam', '0.7 – 1.3 mg/dL'),
          const Gap(6),
          _buildRefRow('Nữ', '0.5 – 1.1 mg/dL'),
          const Gap(10),
          Divider(color: Colors.grey.shade300),
          const Gap(6),
          Text(
            'eGFR (mức lọc cầu thận ước tính):',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const Gap(6),
          _buildRefRow('G1 (Bình thường)', '≥ 90 mL/min/1.73m²'),
          const Gap(4),
          _buildRefRow('G2 (Giảm nhẹ)', '60 – 89 mL/min'),
          const Gap(4),
          _buildRefRow('G3a', '45 – 59 mL/min'),
          const Gap(4),
          _buildRefRow('G3b', '30 – 44 mL/min'),
          const Gap(4),
          _buildRefRow('G4 (Giảm nặng)', '15 – 29 mL/min'),
          const Gap(4),
          _buildRefRow('G5 (Suy thận)', '< 15 mL/min'),
        ],
      ),
    );
  }

  Widget _buildRefRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
