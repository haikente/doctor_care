import 'package:doctor_care/domain/entities/family_profile.dart';
import 'package:doctor_care/presentation/bloc/family_profile/family_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class AddEditFamilyProfileScreen extends StatefulWidget {
  final FamilyProfile? profile;

  const AddEditFamilyProfileScreen({super.key, this.profile});

  @override
  State<AddEditFamilyProfileScreen> createState() =>
      _AddEditFamilyProfileScreenState();
}

class _AddEditFamilyProfileScreenState
    extends State<AddEditFamilyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  String _selectedRelationship = 'self';
  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _dateOfBirth;
  bool _isSubmitting = false;

  bool get isEditing => widget.profile != null;

  final List<Map<String, dynamic>> _relationships = [
    {'value': 'self', 'label': 'Bản thân', 'icon': Icons.person},
    {'value': 'spouse', 'label': 'Vợ/Chồng', 'icon': Icons.favorite},
    {'value': 'child', 'label': 'Con', 'icon': Icons.child_care},
    {'value': 'parent', 'label': 'Bố/Mẹ', 'icon': Icons.elderly},
    {'value': 'sibling', 'label': 'Anh/Chị/Em', 'icon': Icons.people},
    {'value': 'grandparent', 'label': 'Ông/Bà', 'icon': Icons.elderly_woman},
    {'value': 'other', 'label': 'Khác', 'icon': Icons.person_outline},
  ];

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _heightController = TextEditingController(
      text: widget.profile?.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.profile?.weight?.toString() ?? '',
    );
    _selectedRelationship = widget.profile?.relationship ?? 'self';
    _selectedGender = widget.profile?.gender;
    _selectedBloodType = widget.profile?.bloodType;
    _dateOfBirth = widget.profile?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FamilyProfileCubit, FamilyProfileState>(
      listener: (context, state) {
        if (state is FamilyProfileLoaded && _isSubmitting) {
          _isSubmitting = false;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing ? 'Đã cập nhật hồ sơ' : 'Đã thêm hồ sơ mới',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is FamilyProfileError && _isSubmitting) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            isEditing ? 'Chỉnh sửa hồ sơ' : 'Thêm hồ sơ mới',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar preview
                _buildAvatarPreview(),
                const Gap(24),

                // Tên
                _buildSectionTitle('Thông tin cơ bản'),
                const Gap(12),
                _buildNameField(),
                const Gap(16),

                // Mối quan hệ
                _buildRelationshipSelector(),
                const Gap(16),

                // Giới tính
                _buildGenderSelector(),
                const Gap(16),

                // Ngày sinh
                _buildDateOfBirthField(),
                const Gap(24),

                // Thông tin sức khỏe
                _buildSectionTitle('Thông tin sức khỏe'),
                const Gap(12),

                // Nhóm máu
                _buildBloodTypeSelector(),
                const Gap(16),

                // Chiều cao & Cân nặng
                Row(
                  children: [
                    Expanded(child: _buildHeightField()),
                    const Gap(12),
                    Expanded(child: _buildWeightField()),
                  ],
                ),
                const Gap(32),

                // Button
                _buildSubmitButton(),
                const Gap(20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    final name = _nameController.text.trim();
    String initials = "?";
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        initials =
            "${parts[parts.length - 2][0]}${parts.last[0]}".toUpperCase();
      } else {
        initials = parts.first
            .substring(0, parts.first.length >= 2 ? 2 : 1)
            .toUpperCase();
      }
    }

    final color = _relationships
            .firstWhere((r) => r['value'] == _selectedRelationship)['icon'] ==
        Icons.person
        ? Colors.blue
        : _getRelationshipColor(_selectedRelationship);

    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Gap(8),
          Text(
            name.isEmpty ? 'Nhập tên để xem trước' : name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: name.isEmpty ? Colors.grey : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRelationshipColor(String relationship) {
    switch (relationship) {
      case 'self':
        return Colors.blue;
      case 'spouse':
        return Colors.pink;
      case 'child':
        return Colors.green;
      case 'parent':
        return Colors.orange;
      case 'sibling':
        return Colors.purple;
      case 'grandparent':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Họ và tên *',
        hintText: 'Ví dụ: Nguyễn Văn A',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập họ tên';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildRelationshipSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mối quan hệ *',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _relationships.map((r) {
            final isSelected = _selectedRelationship == r['value'];
            final color = _getRelationshipColor(r['value']);
            return GestureDetector(
              onTap: () => setState(() => _selectedRelationship = r['value']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(r['icon'] as IconData, size: 16, color: isSelected ? color : Colors.grey),
                    const Gap(6),
                    Text(
                      r['label'] as String,
                      style: TextStyle(
                        color: isSelected ? color : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới tính',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const Gap(8),
        Row(
          children: [
            _buildGenderChip('male', 'Nam', Icons.male, Colors.blue),
            const Gap(8),
            _buildGenderChip('female', 'Nữ', Icons.female, Colors.pink),
            const Gap(8),
            _buildGenderChip('other', 'Khác', Icons.transgender, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedGender = isSelected ? null : value;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : Colors.grey),
              const Gap(4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime(2000),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          locale: const Locale('vi'),
        );
        if (date != null) {
          setState(() => _dateOfBirth = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ngày sinh',
          prefixIcon: const Icon(Icons.cake_outlined),
          suffixIcon: _dateOfBirth != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => setState(() => _dateOfBirth = null),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _dateOfBirth != null
              ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
              : 'Chọn ngày sinh',
          style: TextStyle(
            color: _dateOfBirth != null ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildBloodTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodType,
      decoration: InputDecoration(
        labelText: 'Nhóm máu',
        prefixIcon: const Icon(Icons.bloodtype_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Chưa chọn')),
        ..._bloodTypes.map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            )),
      ],
      onChanged: (value) => setState(() => _selectedBloodType = value),
    );
  }

  Widget _buildHeightField() {
    return TextFormField(
      controller: _heightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Chiều cao (cm)',
        prefixIcon: const Icon(Icons.height),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final num = double.tryParse(value);
          if (num == null || num < 30 || num > 250) {
            return 'Chiều cao không hợp lệ';
          }
        }
        return null;
      },
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Cân nặng (kg)',
        prefixIcon: const Icon(Icons.monitor_weight_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final num = double.tryParse(value);
          if (num == null || num < 1 || num > 300) {
            return 'Cân nặng không hợp lệ';
          }
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        child: Text(
          isEditing ? 'Cập nhật hồ sơ' : 'Thêm hồ sơ',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    _isSubmitting = true;

    final profile = FamilyProfile(
      id: widget.profile?.id,
      name: _nameController.text.trim(),
      relationship: _selectedRelationship,
      dateOfBirth: _dateOfBirth,
      gender: _selectedGender,
      bloodType: _selectedBloodType,
      height: _heightController.text.isNotEmpty
          ? double.tryParse(_heightController.text)
          : null,
      weight: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
      isActive: widget.profile?.isActive ?? false,
      createdAt: widget.profile?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      context.read<FamilyProfileCubit>().editProfile(profile);
    } else {
      context.read<FamilyProfileCubit>().addProfile(profile);
    }
  }
}
