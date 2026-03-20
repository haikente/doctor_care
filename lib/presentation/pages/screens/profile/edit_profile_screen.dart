import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedBloodType;
  List<String> _allergies = [];
  List<String> _chronicDiseases = [];
  List<String> _medications = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
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
          _fullNameController.text = data['fullName'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _addressController.text = data['address'] ?? '';
          _emergencyContactController.text = data['emergencyContact'] ?? '';
          _emergencyPhoneController.text = data['emergencyPhone'] ?? '';
          _heightController.text = data['height']?.toString() ?? '';
          _weightController.text = data['weight']?.toString() ?? '';
          _selectedGender = data['gender'];
          _selectedBloodType = data['bloodType'];
          if (data['dateOfBirth'] != null) {
            _selectedDate = DateTime.parse(data['dateOfBirth']);
          }
          _allergies = data['allergies'] != null
              ? List<String>.from(data['allergies'])
              : [];
          _chronicDiseases = data['chronicDiseases'] != null
              ? List<String>.from(data['chronicDiseases'])
              : [];
          _medications = data['medications'] != null
              ? List<String>.from(data['medications'])
              : [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr("error")}: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final data = {
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'emergencyPhone': _emergencyPhoneController.text.trim(),
        'gender': _selectedGender,
        'bloodType': _selectedBloodType,
        'dateOfBirth': _selectedDate?.toIso8601String(),
        'height': _heightController.text.isNotEmpty
            ? double.parse(_heightController.text)
            : null,
        'weight': _weightController.text.isNotEmpty
            ? double.parse(_weightController.text)
            : null,
        'allergies': _allergies,
        'chronicDiseases': _chronicDiseases,
        'medications': _medications,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('update_success')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${context.tr("error")}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomStackAppBar(
          onBack: () => Navigator.pop(context),
          title: context.tr('edit_profile_title'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: context.tr('edit_profile_title'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info
            _buildSection(context.tr('basic_info'), Icons.person, [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: '${context.tr("full_name")} *',
                  prefixIcon: const Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('please_enter_full_name');
                  }
                  return null;
                },
              ),
              const Gap(16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: context.tr('phone_number'),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const Gap(16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: context.tr('gender'),
                  prefixIcon: const Icon(Icons.wc),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text(context.tr('gender_male')),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text(context.tr('gender_female')),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text(context.tr('gender_other')),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const Gap(16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake),
                title: Text(
                  _selectedDate == null
                      ? context.tr('choose_date_of_birth')
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
            ]),

            const Gap(24),

            // Health Info
            _buildSection(context.tr('health_info'), Icons.favorite, [
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodType,
                decoration: InputDecoration(
                  labelText: context.tr('blood_type'),
                  prefixIcon: const Icon(Icons.bloodtype),
                ),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedBloodType = value),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        labelText: context.tr('height_cm'),
                        prefixIcon: const Icon(Icons.height),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: context.tr('weight_kg'),
                        prefixIcon: const Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ]),

            const Gap(24),

            // Address
            _buildSection(context.tr('address'), Icons.home, [
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: context.tr('address'),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
            ]),

            const Gap(24),

            // Emergency Contact
            _buildSection('Liên hệ khẩn cấp', Icons.emergency, [
              TextFormField(
                controller: _emergencyContactController,
                decoration: const InputDecoration(
                  labelText: 'Tên người liên hệ',
                  prefixIcon: Icon(Icons.person_pin),
                ),
              ),
              const Gap(16),
              TextFormField(
                controller: _emergencyPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại khẩn cấp',
                  prefixIcon: Icon(Icons.phone_in_talk),
                ),
                keyboardType: TextInputType.phone,
              ),
            ]),

            const Gap(32),

            CustomButton(
              text: context.tr('save'),
              onPressed: () {
                if (_isSaving) return;
                _saveProfile();
              },
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const Gap(8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(16),
          ...children,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
