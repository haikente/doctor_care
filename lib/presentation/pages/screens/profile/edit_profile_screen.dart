import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
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

  final List<String> _bloodTypes = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

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
            _selectedDate = DateTime.tryParse(data['dateOfBirth']);
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
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr("error")}: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

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
        'height': _heightController.text.trim().isNotEmpty
            ? double.tryParse(_heightController.text.trim())
            : null,
        'weight': _weightController.text.trim().isNotEmpty
            ? double.tryParse(_weightController.text.trim())
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('update_success')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr("error")}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: context.tr('edit_profile_title'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  _buildProfileHeader(theme),
                  const Gap(24),
                  _buildSectionTitle(
                    title: context.tr('basic_info'),
                    icon: Icons.badge_outlined,
                  ),
                  const Gap(12),
                  _buildFieldCard([
                    _buildTextField(
                      controller: _fullNameController,
                      label: '${context.tr("full_name")} *',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.tr('please_enter_full_name');
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const Gap(14),
                    _buildTextField(
                      controller: _phoneController,
                      label: context.tr('phone_number'),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const Gap(14),
                    _buildGenderSelector(),
                    const Gap(14),
                    _buildDateField(),
                  ]),
                  const Gap(24),
                  _buildSectionTitle(
                    title: context.tr('health_info'),
                    icon: Icons.monitor_heart_outlined,
                  ),
                  const Gap(12),
                  _buildFieldCard([
                    _buildBloodTypeSelector(),
                    const Gap(14),
                    Row(
                      children: [
                        Expanded(child: _buildHeightField()),
                        const Gap(12),
                        Expanded(child: _buildWeightField()),
                      ],
                    ),
                  ]),
                  const Gap(24),
                  _buildSectionTitle(
                    title: context.tr('address'),
                    icon: Icons.home_outlined,
                  ),
                  const Gap(12),
                  _buildFieldCard([
                    _buildTextField(
                      controller: _addressController,
                      label: context.tr('address'),
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                      textInputAction: TextInputAction.newline,
                    ),
                  ]),
                  const Gap(24),
                  _buildSectionTitle(
                    title: context.tr('emergency_contact'),
                    icon: Icons.emergency_outlined,
                  ),
                  const Gap(12),
                  _buildFieldCard([
                    _buildTextField(
                      controller: _emergencyContactController,
                      label: context.tr('emergency_contact_name'),
                      icon: Icons.person_pin_circle_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const Gap(14),
                    _buildTextField(
                      controller: _emergencyPhoneController,
                      label: context.tr('emergency_phone'),
                      icon: Icons.phone_in_talk_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ]),
                  const Gap(28),
                  _buildSaveButton(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    final name = _fullNameController.text.trim();
    final initials = _initials(name);
    final email = FirebaseAuth.instance.currentUser?.email;
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, const Color(0xFF20A386)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.24)),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? context.tr('full_name') : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(8),
                if (email != null)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const Gap(12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHeaderPill(
                      _selectedGender == null
                          ? context.tr('gender')
                          : _genderLabel(_selectedGender!),
                    ),
                    _buildHeaderPill(
                      _selectedBloodType ?? context.tr('blood_type'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required IconData icon}) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: theme.colorScheme.primary),
        ),
        const Gap(10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldCard(List<Widget> children) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.55),
      ),
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.18)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        _buildGenderChip(
          value: 'male',
          label: context.tr('gender_male'),
          icon: Icons.male_rounded,
          color: Colors.blue,
        ),
        const Gap(8),
        _buildGenderChip(
          value: 'female',
          label: context.tr('gender_female'),
          icon: Icons.female_rounded,
          color: Colors.pink,
        ),
        const Gap(8),
        _buildGenderChip(
          value: 'other',
          label: context.tr('gender_other'),
          icon: Icons.transgender_rounded,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildGenderChip({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedGender == value;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedGender = isSelected ? null : value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.14)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : theme.dividerColor.withOpacity(0.20),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : Colors.grey),
              const Gap(5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? color
                        : theme.colorScheme.onSurface.withOpacity(0.62),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final theme = Theme.of(context);
    final text = _selectedDate == null
        ? context.tr('choose_date_of_birth')
        : DateFormat('dd/MM/yyyy').format(_selectedDate!);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _pickDateOfBirth,
      child: InputDecorator(
        decoration:
            _inputDecoration(
              label: context.tr('choose_date_of_birth'),
              icon: Icons.cake_outlined,
            ).copyWith(
              suffixIcon: Icon(
                Icons.calendar_today_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
        child: Text(
          text,
          style: TextStyle(
            color: _selectedDate == null
                ? theme.colorScheme.onSurface.withOpacity(0.55)
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Widget _buildBloodTypeSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBloodType,
      decoration: _inputDecoration(
        label: context.tr('blood_type'),
        icon: Icons.bloodtype_outlined,
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(
            context.tr('not_selected'),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ..._bloodTypes.map(
          (type) => DropdownMenuItem(value: type, child: Text(type)),
        ),
      ],
      onChanged: (value) => setState(() => _selectedBloodType = value),
    );
  }

  Widget _buildHeightField() {
    return _buildTextField(
      controller: _heightController,
      label: context.tr('height_cm'),
      icon: Icons.height_rounded,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          final number = double.tryParse(value.trim());
          if (number == null || number < 30 || number > 250) {
            return context.tr('height_invalid');
          }
        }
        return null;
      },
    );
  }

  Widget _buildWeightField() {
    return _buildTextField(
      controller: _weightController,
      label: context.tr('weight_kg'),
      icon: Icons.monitor_weight_outlined,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          final number = double.tryParse(value.trim());
          if (number == null || number < 1 || number > 300) {
            return context.tr('weight_invalid');
          }
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isSaving
                ? [Colors.blue.shade100, Colors.blue.shade200]
                : [theme.colorScheme.primary, const Color(0xFF1F8F7A)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isSaving
              ? null
              : [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.white,
                  ),
                )
              : Text(
                  context.tr('save'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    final first = parts.first;
    return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _genderLabel(String gender) {
    switch (gender) {
      case 'male':
        return context.tr('gender_male');
      case 'female':
        return context.tr('gender_female');
      default:
        return context.tr('gender_other');
    }
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
