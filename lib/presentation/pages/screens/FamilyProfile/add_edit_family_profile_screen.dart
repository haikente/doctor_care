import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/family_profile.dart';
import 'package:doctor_care/presentation/bloc/family_profile/family_profile_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/FamilyProfile/widgets/filter_bottom_sheet_fp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

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
  bool _selfExists = false; // Đã có hồ sơ "Bản thân" chưa
  bool hasChanges = false;

  bool get isEditing => widget.profile != null;

  List<Map<String, dynamic>> _getRelationships(BuildContext context) => [
    {'value': 'self', 'label': context.tr('rel_self'), 'icon': Icons.person},
    {
      'value': 'spouse',
      'label': context.tr('rel_spouse'),
      'icon': Icons.favorite,
    },
    {
      'value': 'child',
      'label': context.tr('rel_child'),
      'icon': Icons.child_care,
    },
    {
      'value': 'parent',
      'label': context.tr('rel_parent'),
      'icon': Icons.elderly,
    },
    {
      'value': 'sibling',
      'label': context.tr('rel_sibling'),
      'icon': Icons.people,
    },
    {
      'value': 'grandparent',
      'label': context.tr('rel_grandparent'),
      'icon': Icons.elderly_woman,
    },
    {
      'value': 'other',
      'label': context.tr('rel_other'),
      'icon': Icons.person_outline,
    },
  ];

  final List<String> _bloodTypes = [
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

    // Kiểm tra xem đã có hồ sơ "Bản thân" chưa
    final cubitState = context.read<FamilyProfileCubit>().state;
    if (cubitState is FamilyProfileLoaded) {
      _selfExists = cubitState.profiles.any(
        (p) => p.relationship == 'self' && p.id != widget.profile?.id,
      );
      // Nếu thêm mới mà đã có "Bản thân" → default sang "child"
      if (!isEditing && _selfExists) {
        _selectedRelationship = 'spouse';
      }
    }
    _validate();

    _nameController.addListener(_validate);
    _heightController.addListener(_validate);
    _weightController.addListener(_validate);
  }

  void _validate() {
    setState(() {
      if (!isEditing) {
        hasChanges = _nameController.text.trim().isNotEmpty;
        return;
      }

      final p = widget.profile!;
      final nameChanged = _nameController.text.trim() != p.name;
      final relationshipChanged = _selectedRelationship != p.relationship;
      final genderChanged = _selectedGender != p.gender;
      final bloodTypeChanged = _selectedBloodType != p.bloodType;
      final dobChanged = _dateOfBirth != p.dateOfBirth;
      final heightChanged =
          _heightController.text != (p.height?.toString() ?? '');
      final weightChanged =
          _weightController.text != (p.weight?.toString() ?? '');

      hasChanges =
          nameChanged ||
          relationshipChanged ||
          genderChanged ||
          bloodTypeChanged ||
          dobChanged ||
          heightChanged ||
          weightChanged;
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_validate);
    _heightController.removeListener(_validate);
    _weightController.removeListener(_validate);
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
          AppSnackBar.showFamilyProfile(
            context: context,
            type: isEditing ? SnackBarType.update : SnackBarType.add,
          );
        } else if (state is FamilyProfileError && _isSubmitting) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: CustomStackAppBar(
          onBack: () => Navigator.pop(context),
          title: widget.profile != null
              ? context.tr('update_profile_title')
              : context.tr('add_new_profile_title'),
          centerTitle: true,
          icon: widget.profile != null && widget.profile!.relationship != 'self'
              ? const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.white,
                  size: 22,
                )
              : null,
          onInfo:
              widget.profile != null && widget.profile!.relationship != 'self'
              ? () => AppDialog.showDeleteConfirm(
                  context: context,
                  content: context.tr('confirm_delete_profile'),
                  onConfirm: () {
                    // Xóa bản ghi từ database
                    if (widget.profile?.id != null) {
                      context.read<FamilyProfileCubit>().removeProfile(
                        widget.profile!.id!,
                      );
                    }
                    AppSnackBar.showFamilyProfile(
                      context: context,
                      type: SnackBarType.delete,
                    );
                    Navigator.pop(context);
                  },
                )
              : null,
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
                _buildSectionTitle(context.tr('basic_info')),
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
                _buildSectionTitle(context.tr('health_info')),
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
                const Gap(30),

                // Button
                CustomButton(
                  expanded: true,
                  text: widget.profile != null
                      ? context.tr('update_btn')
                      : context.tr('save'),
                  enabled: hasChanges,
                  onPressed: _submit,
                ),
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
        initials = "${parts[parts.length - 2][0]}${parts.last[0]}"
            .toUpperCase();
      } else {
        initials = parts.first
            .substring(0, parts.first.length >= 2 ? 2 : 1)
            .toUpperCase();
      }
    }

    final color =
        _getRelationships(
              context,
            ).firstWhere((r) => r['value'] == _selectedRelationship)['icon'] ==
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
            name.isEmpty ? context.tr('enter_name_preview') : name,
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
        labelText: context.tr('full_name'),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.person_outline, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.tr('please_enter_full_name');
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildRelationshipSelector() {
    final availableRelationships = _getRelationships(context).where((r) {
      if (r['value'] == 'self' && _selfExists) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('relationship_label'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableRelationships.map((r) {
            final isSelected = _selectedRelationship == r['value'];
            final color = _getRelationshipColor(r['value']);
            return GestureDetector(
              onTap: () {
                setState(() => _selectedRelationship = r['value']);
                _validate();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      r['icon'] as IconData,
                      size: 16,
                      color: isSelected ? color : Colors.grey,
                    ),
                    const Gap(6),
                    Text(
                      r['label'] as String,
                      style: TextStyle(
                        color: isSelected ? color : Colors.grey.shade700,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
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
        Text(
          context.tr('gender'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const Gap(8),
        Row(
          children: [
            _buildGenderChip(
              'male',
              context.tr('gender_male'),
              Icons.male,
              Colors.blue,
            ),
            const Gap(8),
            _buildGenderChip(
              'female',
              context.tr('gender_female'),
              Icons.female,
              Colors.pink,
            ),
            const Gap(8),
            _buildGenderChip(
              'other',
              context.tr('gender_other'),
              Icons.transgender,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = isSelected ? null : value;
          });
          _validate();
        },
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
    return FilterBottomSheetFP(
      initialDate: _dateOfBirth,
      onDateSelected: (date) {
        setState(() {
          _dateOfBirth = date;
        });
        _validate();
      },
    );
  }

  Widget _buildBloodTypeSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBloodType,
      decoration: InputDecoration(
        labelText: context.tr('blood_type'),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.bloodtype_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
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
      onChanged: (value) {
        setState(() => _selectedBloodType = value);
        _validate();
      },
    );
  }

  Widget _buildHeightField() {
    return TextFormField(
      controller: _heightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: context.tr('height_cm'),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.height),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final num = double.tryParse(value);
          if (num == null || num < 30 || num > 250) {
            return context.tr('height_invalid');
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
        labelText: context.tr('weight_kg'),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.monitor_weight_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final num = double.tryParse(value);
          if (num == null || num < 1 || num > 300) {
            return context.tr('weight_invalid');
          }
        }
        return null;
      },
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
