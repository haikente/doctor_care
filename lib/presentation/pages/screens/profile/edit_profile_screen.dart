import 'package:cloud_firestore/cloud_firestore.dart';
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
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
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
          const SnackBar(
            content: Text('✅ Cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${e.toString()}'),
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
          title: 'Chỉnh sửa hồ sơ',
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: 'Chỉnh sửa hồ sơ',
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info
            _buildSection(
              'Thông tin cơ bản',
              Icons.person,
              [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên *',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ tên';
                    }
                    return null;
                  },
                ),
                const Gap(16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const Gap(16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Giới tính',
                    prefixIcon: Icon(Icons.wc),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Nam')),
                    DropdownMenuItem(value: 'female', child: Text('Nữ')),
                    DropdownMenuItem(value: 'other', child: Text('Khác')),
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const Gap(16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cake),
                  title: Text(_selectedDate == null
                      ? 'Chọn ngày sinh'
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
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
              ],
            ),

            const Gap(24),

            // Health Info
            _buildSection(
              'Thông tin sức khỏe',
              Icons.favorite,
              [
                DropdownButtonFormField<String>(
                  initialValue: _selectedBloodType,
                  decoration: const InputDecoration(
                    labelText: 'Nhóm máu',
                    prefixIcon: Icon(Icons.bloodtype),
                  ),
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedBloodType = value),
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Chiều cao (cm)',
                          prefixIcon: Icon(Icons.height),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Cân nặng (kg)',
                          prefixIcon: Icon(Icons.monitor_weight),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Gap(24),

            // Address
            _buildSection(
              'Địa chỉ',
              Icons.home,
              [
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
              ],
            ),

            const Gap(24),

            // Emergency Contact
            _buildSection(
              'Liên hệ khẩn cấp',
              Icons.emergency,
              [
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
              ],
            ),

            const Gap(32),

            CustomButton(text: 'Lưu', onPressed: () {
              if (_isSaving) return;
              _saveProfile();
            }),
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
