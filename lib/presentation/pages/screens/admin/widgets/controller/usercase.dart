import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/presentation/pages/screens/admin/widgets/controller/admin_stats.dart';
import 'package:doctor_care/presentation/pages/screens/admin/widgets/controller/admin_stats_widgets.dart';
import 'package:doctor_care/presentation/pages/screens/admin/widgets/controller/admin_backup_service.dart';
import 'package:doctor_care/domain/entities/notification_entity.dart';
import 'package:doctor_care/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:doctor_care/presentation/pages/screens/admin/admin_settings_screen.dart';

class Usercase {
  static const List<DropdownMenuItem<String>> _roleItems = [
    DropdownMenuItem(value: 'users', child: Text('Người dùng')),
    DropdownMenuItem(value: 'patient', child: Text('Bệnh nhân')),
    DropdownMenuItem(value: 'doctor', child: Text('Bác sĩ')),
    DropdownMenuItem(value: 'admin', child: Text('Admin')),
  ];

  static String _normalizedRole(dynamic role) {
    final value = role?.toString().trim().toLowerCase();
    if (value == null || value.isEmpty) {
      return 'users';
    }
    if (value == 'user') {
      return 'users';
    }

    final hasMatchingItem = _roleItems.any((item) => item.value == value);
    return hasMatchingItem ? value : 'users';
  }

  void showEditUserDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> userData,
  ) {
    final fullNameController = TextEditingController(
      text: userData['fullName'] ?? '',
    );
    final phoneController = TextEditingController(
      text: userData['phoneNumber'] ?? '',
    );
    final addressController = TextEditingController(
      text: userData['address'] ?? '',
    );
    final heightController = TextEditingController(
      text: userData['height']?.toString() ?? '',
    );
    final weightController = TextEditingController(
      text: userData['weight']?.toString() ?? '',
    );
    final emergencyContactController = TextEditingController(
      text: userData['emergencyContact'] ?? '',
    );
    final emergencyPhoneController = TextEditingController(
      text: userData['emergencyPhone'] ?? '',
    );

    String selectedGender = userData['gender'] ?? 'male';
    String selectedBloodType = userData['bloodType'] ?? 'O+';
    String selectedRole = _normalizedRole(userData['role']);
    DateTime? selectedDate = userData['dateOfBirth'] != null
        ? DateTime.parse(userData['dateOfBirth'])
        : null;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          final initials = (userData['fullName'] ?? 'U')
              .toString()
              .trim()
              .split(' ')
              .where((s) => s.isNotEmpty)
              .map((s) => s[0].toUpperCase())
              .take(2)
              .join();
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 8,
            shadowColor: theme.colorScheme.primary.withOpacity(0.2),
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Gradient Header ──
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Gap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chỉnh sửa thông tin',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                userData['email'] ??
                                    'Cập nhật dữ liệu người dùng',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            fullNameController.dispose();
                            phoneController.dispose();
                            addressController.dispose();
                            heightController.dispose();
                            weightController.dispose();
                            emergencyContactController.dispose();
                            emergencyPhoneController.dispose();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Section 1: Thông tin cơ bản ──
                          _buildSectionCard(
                            theme,
                            icon: Icons.person_rounded,
                            title: 'Thông tin cơ bản',
                            color: Colors.blue,
                            children: [
                              _buildTextField(
                                controller: fullNameController,
                                label: 'Họ và tên',
                                icon: Icons.person_outline,
                              ),
                              const Gap(12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: phoneController,
                                      label: 'Số điện thoại',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: _buildDropdown<String>(
                                      value: selectedGender,
                                      label: 'Giới tính',
                                      icon: Icons.wc_outlined,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'male',
                                          child: Text('Nam'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'female',
                                          child: Text('Nữ'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'other',
                                          child: Text('Khác'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGender = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(12),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              selectedDate ?? DateTime(2000),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            selectedDate = date;
                                          });
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Ngày sinh',
                                          prefixIcon: Icon(
                                            Icons.cake_outlined,
                                            color: Colors.grey.shade500,
                                          ),
                                          filled: true,
                                          fillColor: theme
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withOpacity(0.35),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                        ),
                                        child: Text(
                                          selectedDate != null
                                              ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
                                              : 'Chọn ngày',
                                          style: TextStyle(
                                            color: selectedDate != null
                                                ? theme.colorScheme.onSurface
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: _buildDropdown<String>(
                                      value: selectedRole,
                                      label: 'Vai trò',
                                      icon: Icons.admin_panel_settings_outlined,
                                      items: _roleItems,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedRole = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(16),

                          // ── Section 2: Thông tin sức khỏe ──
                          _buildSectionCard(
                            theme,
                            icon: Icons.favorite_rounded,
                            title: 'Thông tin sức khỏe',
                            color: Colors.redAccent,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdown<String>(
                                      value: selectedBloodType,
                                      label: 'Nhóm máu',
                                      icon: Icons.bloodtype_outlined,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'A+',
                                          child: Text('A+'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'A-',
                                          child: Text('A-'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'B+',
                                          child: Text('B+'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'B-',
                                          child: Text('B-'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'AB+',
                                          child: Text('AB+'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'AB-',
                                          child: Text('AB-'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'O+',
                                          child: Text('O+'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'O-',
                                          child: Text('O-'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedBloodType = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: heightController,
                                      label: 'Chiều cao (cm)',
                                      icon: Icons.height,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: weightController,
                                      label: 'Cân nặng (kg)',
                                      icon: Icons.monitor_weight_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(16),

                          // ── Section 3: Liên hệ & Địa chỉ ──
                          _buildSectionCard(
                            theme,
                            icon: Icons.contact_mail_rounded,
                            title: 'Liên hệ & Địa chỉ',
                            color: Colors.teal,
                            children: [
                              _buildTextField(
                                controller: addressController,
                                label: 'Địa chỉ',
                                icon: Icons.home_outlined,
                                maxLines: 2,
                              ),
                              const Gap(12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: emergencyContactController,
                                      label: 'Liên hệ khẩn cấp',
                                      icon: Icons.contact_emergency_outlined,
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: emergencyPhoneController,
                                      label: 'SĐT khẩn cấp',
                                      icon: Icons.phone_in_talk_outlined,
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(8),
                        ],
                      ),
                    ),
                  ),

                  // ── Actions Footer ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              fullNameController.dispose();
                              phoneController.dispose();
                              addressController.dispose();
                              heightController.dispose();
                              weightController.dispose();
                              emergencyContactController.dispose();
                              emergencyPhoneController.dispose();
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const Gap(14),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final updateData = <String, dynamic>{
                                  'fullName': fullNameController.text.trim(),
                                  'phoneNumber': phoneController.text.trim(),
                                  'gender': selectedGender,
                                  'bloodType': selectedBloodType,
                                  'role': selectedRole,
                                  'address': addressController.text.trim(),
                                  'emergencyContact': emergencyContactController
                                      .text
                                      .trim(),
                                  'emergencyPhone': emergencyPhoneController
                                      .text
                                      .trim(),
                                };
                                if (selectedDate != null) {
                                  updateData['dateOfBirth'] = selectedDate!
                                      .toIso8601String();
                                }
                                if (heightController.text.isNotEmpty) {
                                  updateData['height'] =
                                      double.tryParse(heightController.text) ??
                                      0;
                                }
                                if (weightController.text.isNotEmpty) {
                                  updateData['weight'] =
                                      double.tryParse(weightController.text) ??
                                      0;
                                }
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(docId)
                                    .update(updateData);

                                fullNameController.dispose();
                                phoneController.dispose();
                                addressController.dispose();
                                heightController.dispose();
                                weightController.dispose();
                                emergencyContactController.dispose();
                                emergencyPhoneController.dispose();

                                if (!dialogContext.mounted) return;
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        Gap(8),
                                        Text('Cập nhật thành công!'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } catch (e) {
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const Gap(8),
                                          Expanded(
                                            child: Text('Lỗi: ${e.toString()}'),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.red.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.save_rounded, size: 20),
                            label: const Text(
                              'Lưu thay đổi',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: theme.colorScheme.primary
                                  .withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Gap(10),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Gap(14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 16, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 16, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  void showDeleteUserDialog(BuildContext context, String docId, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xóa người dùng'),
        content: Text(
          'Bạn có chắc muốn xóa người dùng "$email"?\n\nHành động này không thể hoàn tác!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(docId)
                    .delete();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Đã xóa người dùng thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Lỗi: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void showStatistics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);

        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue.shade500),
                    const Gap(8),
                    Text(
                      'Thống kê',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),

              Expanded(
                child: FutureBuilder<AdminStats>(
                  future: const AdminStatsService().load(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 40),
                            const Gap(8),
                            Text(
                              'Không tải được thống kê',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              snapshot.error.toString(),
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final stats = snapshot.data;
                    if (stats == null) {
                      return const Center(child: Text('Không có dữ liệu.'));
                    }

                    final collectionIcons = <String, IconData>{
                      'step_count': Icons.directions_walk,
                      'water_intake': Icons.water_drop,
                      'spo2heartrate': Icons.monitor_heart,
                      'temperature': Icons.thermostat,
                      'sleep_record': Icons.bedtime,
                      'blood_pressure': Icons.favorite,
                      'blood_sugar': Icons.bloodtype,
                      'bmi_weight': Icons.monitor_weight,
                      'cholesterol': Icons.science,
                      'creatinine': Icons.biotech,
                      'hba1c': Icons.opacity,
                      'menstrual_cycle': Icons.calendar_month,
                    };

                    final collectionColors = <String, Color>{
                      'step_count': Colors.blue,
                      'water_intake': Colors.lightBlue,
                      'spo2heartrate': Colors.red,
                      'temperature': Colors.orange,
                      'sleep_record': Colors.indigo,
                      'blood_pressure': Colors.pink,
                      'blood_sugar': Colors.teal,
                      'bmi_weight': Colors.deepOrange,
                      'cholesterol': Colors.amber,
                      'creatinine': Colors.cyan,
                      'hba1c': Colors.green,
                      'menstrual_cycle': Colors.purple,
                    };

                    final detailRows = kAdminHealthCollections
                        .map(
                          (collection) => AdminStatsWidgets.modernCollectionRow(
                            theme,
                            label: collection.label,
                            value: stats.docsOf(collection.key),
                            icon:
                                collectionIcons[collection.key] ?? Icons.folder,
                            color:
                                collectionColors[collection.key] ??
                                Colors.blueGrey,
                          ),
                        )
                        .toList();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.15,
                            children: [
                              AdminStatsWidgets.statsGridCard(
                                theme,
                                icon: Icons.people,
                                title: 'Tổng người dùng',
                                value: stats.totalUsers.toString(),
                                gradientColors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade800,
                                ],
                              ),
                              AdminStatsWidgets.statsGridCard(
                                theme,
                                icon: Icons.person,
                                title: 'Người dùng',
                                value: stats.userCount.toString(),
                                gradientColors: [
                                  Colors.green.shade400,
                                  Colors.green.shade800,
                                ],
                              ),
                              AdminStatsWidgets.statsGridCard(
                                theme,
                                icon: Icons.admin_panel_settings,
                                title: 'Admin',
                                value: stats.adminCount.toString(),
                                gradientColors: [
                                  Colors.deepPurple.shade400,
                                  Colors.deepPurple.shade800,
                                ],
                              ),
                              AdminStatsWidgets.statsGridCard(
                                theme,
                                icon: Icons.storage,
                                title: 'Dữ liệu y tế',
                                value: stats.totalHealthDocs.toString(),
                                gradientColors: [
                                  Colors.orange.shade400,
                                  Colors.orange.shade800,
                                ],
                              ),
                            ],
                          ),

                          const Gap(24),
                          Text(
                            'Chi Tiết Dữ Liệu Lưu Trữ',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Gap(12),
                          ...detailRows,

                          const Gap(24),
                          Text(
                            'Thống Kê Bước Chân (7 Ngày Qua)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Gap(12),
                          AdminStatsWidgets.stepsBarChart(
                            theme,
                            stats.last7DaysSteps,
                          ),

                          const Gap(24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                                const Gap(10),
                                Expanded(
                                  child: Text(
                                    'Dữ liệu được cập nhật tự động từ hệ thống cloud tĩnh của tất cả người dùng.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showHealthData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💊 Dữ liệu sức khỏe'),
        content: const Text(
          'Chức năng quản lý dữ liệu sức khỏe đang được phát triển...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
    );
  }

  void showSendNotificationDialogModern(BuildContext context) {
    final rootContext = context;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    NotificationType selectedType = NotificationType.info;
    var isSending = false;

    final typeOptions = <NotificationType, ({String label, IconData icon, Color color})>{
      NotificationType.info: (
        label: 'Thông tin',
        icon: Icons.info_outline_rounded,
        color: Colors.blue,
      ),
      NotificationType.warning: (
        label: 'Cảnh báo',
        icon: Icons.warning_amber_rounded,
        color: Colors.orange,
      ),
      NotificationType.error: (
        label: 'Lỗi',
        icon: Icons.error_outline_rounded,
        color: Colors.red,
      ),
      NotificationType.success: (
        label: 'Thành công',
        icon: Icons.check_circle_outline_rounded,
        color: Colors.green,
      ),
      NotificationType.promotion: (
        label: 'Khuyến mãi',
        icon: Icons.local_offer_outlined,
        color: Colors.purple,
      ),
      NotificationType.system: (
        label: 'Hệ thống',
        icon: Icons.settings_outlined,
        color: Colors.blueGrey,
      ),
    };

    InputDecoration fieldDecoration({
      required BuildContext context,
      required String hint,
      required IconData icon,
      bool alignLabelWithHint = false,
    }) {
      final theme = Theme.of(context);
      final borderColor = theme.dividerColor.withOpacity(0.35);
      return InputDecoration(
        hintText: hint,
        alignLabelWithHint: alignLabelWithHint,
        prefixIcon: Icon(icon, size: 21),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.22),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
        ),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          final selectedOption = typeOptions[selectedType]!;

          Future<void> sendNotification() async {
            if (!(formKey.currentState?.validate() ?? false)) return;

            final title = titleController.text.trim();
            final body = bodyController.text.trim();

            setState(() => isSending = true);
            try {
              final usersSnap = await FirebaseFirestore.instance
                  .collection('users')
                  .get();
              final userIds = usersSnap.docs
                  .map((doc) => doc.id.trim())
                  .where((id) => id.isNotEmpty)
                  .toSet()
                  .toList();

              if (userIds.isEmpty) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Không có người dùng để gửi thông báo.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              await InjectionContainer().notificationRepository
                  .sendNotification(
                    title: title,
                    body: body,
                    type: selectedType,
                    userIds: userIds,
                  );

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã gửi thông báo cho ${userIds.length} người dùng.',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            } catch (e) {
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text('Gửi thông báo thất bại: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            } finally {
              if (dialogContext.mounted) {
                setState(() => isSending = false);
              }
            }
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            backgroundColor: theme.colorScheme.surface,
            elevation: 8,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.92,
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.campaign_rounded,
                                color: theme.primaryColor,
                                size: 27,
                              ),
                            ),
                            const Gap(14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gửi thông báo',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Gap(3),
                                  Text(
                                    'Thông báo sẽ hiển thị trong hộp thư của người dùng.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.62),
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Đóng',
                              onPressed: isSending
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const Gap(22),
                        Text(
                          'Tiêu đề',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(8),
                        TextFormField(
                          controller: titleController,
                          enabled: !isSending,
                          textInputAction: TextInputAction.next,
                          maxLength: 80,
                          decoration: fieldDecoration(
                            context: context,
                            hint: 'Nhập tiêu đề ngắn gọn',
                            icon: Icons.title_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tiêu đề.';
                            }
                            if (value.trim().length < 3) {
                              return 'Tiêu đề cần ít nhất 3 ký tự.';
                            }
                            return null;
                          },
                        ),
                        const Gap(14),
                        Text(
                          'Nội dung',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(8),
                        TextFormField(
                          controller: bodyController,
                          enabled: !isSending,
                          minLines: 4,
                          maxLines: 6,
                          maxLength: 500,
                          textInputAction: TextInputAction.newline,
                          decoration: fieldDecoration(
                            context: context,
                            hint: 'Nhập nội dung thông báo',
                            icon: Icons.notes_rounded,
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập nội dung.';
                            }
                            if (value.trim().length < 5) {
                              return 'Nội dung cần ít nhất 5 ký tự.';
                            }
                            return null;
                          },
                        ),
                        const Gap(14),
                        Text(
                          'Loại thông báo',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(8),
                        DropdownButtonFormField<NotificationType>(
                          value: selectedType,
                          isExpanded: true,
                          icon: const Icon(Icons.expand_more_rounded),
                          decoration: fieldDecoration(
                            context: context,
                            hint: 'Chọn loại thông báo',
                            icon: selectedOption.icon,
                          ),
                          selectedItemBuilder: (context) {
                            return NotificationType.values.map((type) {
                              final option = typeOptions[type]!;
                              return Row(
                                children: [
                                  Icon(
                                    option.icon,
                                    color: option.color,
                                    size: 20,
                                  ),
                                  const Gap(10),
                                  Text(option.label),
                                ],
                              );
                            }).toList();
                          },
                          items: NotificationType.values.map((type) {
                            final option = typeOptions[type]!;
                            return DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: option.color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      option.icon,
                                      color: option.color,
                                      size: 19,
                                    ),
                                  ),
                                  const Gap(12),
                                  Text(option.label),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: isSending
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => selectedType = value);
                                  }
                                },
                        ),
                        const Gap(18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selectedOption.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedOption.color.withOpacity(0.18),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.people_alt_outlined,
                                color: selectedOption.color,
                                size: 21,
                              ),
                              const Gap(10),
                              Expanded(
                                child: Text(
                                  'Người nhận: tất cả tài khoản trong hệ thống.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    height: 1.35,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.72),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(22),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSending
                                    ? null
                                    : () => Navigator.pop(dialogContext),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('Hủy'),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: isSending ? null : sendNotification,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      theme.primaryColor.withOpacity(0.55),
                                  disabledForegroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: isSending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send_rounded,
                                        size: 18,
                                      ),
                                label: Text(
                                  isSending ? 'Đang gửi...' : 'Gửi ngay',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      titleController.dispose();
      bodyController.dispose();
    });
  }

  void showSendNotificationDialog(BuildContext context) {
    final rootContext = context;
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    NotificationType selectedType = NotificationType.info;
    var isSending = false;

    IconData getNotificationIcon(NotificationType type) {
      switch (type) {
        case NotificationType.info:
          return Icons.info_outline;
        case NotificationType.warning:
          return Icons.warning_amber_rounded;
        case NotificationType.error:
          return Icons.error_outline_rounded;
        case NotificationType.success:
          return Icons.check_circle_outline_rounded;
        case NotificationType.promotion:
          return Icons.local_offer_outlined;
        case NotificationType.system:
          return Icons.settings_outlined;
      }
    }

    Color getNotificationColor(NotificationType type) {
      switch (type) {
        case NotificationType.info:
          return Colors.blue;
        case NotificationType.warning:
          return Colors.orange;
        case NotificationType.error:
          return Colors.red;
        case NotificationType.success:
          return Colors.green;
        case NotificationType.promotion:
          return Colors.purple;
        case NotificationType.system:
          return Colors.grey;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 450),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gửi thông báo',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Gửi đến tất cả người dùng',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),

                    // Tiêu đề
                    Text(
                      'Tiêu đề',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(8),
                    TextField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Nhập tiêu đề thông báo...',
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.title,
                          color: Colors.grey.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const Gap(16),

                    // Nội dung
                    Text(
                      'Nội dung',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(8),
                    TextField(
                      controller: bodyController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Nhập nội dung chi tiết...',
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const Gap(16),

                    // Loại thông báo
                    Text(
                      'Loại thông báo',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(8),
                    DropdownButtonFormField<NotificationType>(
                      value: selectedType,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.withOpacity(0.6),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        prefixIcon: Icon(
                          getNotificationIcon(selectedType),
                          color: getNotificationColor(selectedType),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: NotificationType.info,
                          child: Text(
                            'Thông tin',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: NotificationType.warning,
                          child: Text(
                            'Cảnh báo',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: NotificationType.error,
                          child: Text(
                            'Lỗi',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: NotificationType.success,
                          child: Text(
                            'Thành công',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: NotificationType.promotion,
                          child: Text(
                            'Khuyến mãi',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: NotificationType.system,
                          child: Text(
                            'Hệ thống',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedType = value);
                        }
                      },
                    ),
                    const Gap(24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSending
                                ? null
                                : () {
                                    titleController.dispose();
                                    bodyController.dispose();
                                    Navigator.pop(dialogContext);
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSending
                                ? null
                                : () async {
                                    final title = titleController.text.trim();
                                    final body = bodyController.text.trim();

                                    if (title.isEmpty || body.isEmpty) {
                                      ScaffoldMessenger.of(
                                        dialogContext,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Vui lòng nhập đủ tiêu đề và nội dung.',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => isSending = true);

                                    try {
                                      final usersSnap = await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .get();
                                      final userIds = usersSnap.docs
                                          .map((doc) => doc.id.trim())
                                          .where((id) => id.isNotEmpty)
                                          .toList();

                                      if (userIds.isEmpty) {
                                        if (!dialogContext.mounted) return;
                                        ScaffoldMessenger.of(
                                          dialogContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Không có người dùng để gửi.',
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }

                                      await InjectionContainer()
                                          .notificationRepository
                                          .sendNotification(
                                            title: title,
                                            body: body,
                                            type: selectedType,
                                            userIds: userIds,
                                          );

                                      if (!dialogContext.mounted) return;
                                      titleController.dispose();
                                      bodyController.dispose();
                                      Navigator.pop(dialogContext);

                                      ScaffoldMessenger.of(
                                        rootContext,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '✅ Đã gửi thông báo cho ${userIds.length} người dùng.',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!dialogContext.mounted) return;
                                      ScaffoldMessenger.of(
                                        dialogContext,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '❌ Lỗi: ${e.toString()}',
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 5),
                                        ),
                                      );
                                    } finally {
                                      if (dialogContext.mounted) {
                                        setState(() => isSending = false);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isSending
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Gửi ngay',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void showBackupDialog(BuildContext context) {
    var isProcessing = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> runWithLock(Future<void> Function() task) async {
            if (isProcessing) return;
            setSheetState(() => isProcessing = true);
            try {
              await task();
            } finally {
              if (sheetContext.mounted) {
                setSheetState(() => isProcessing = false);
              }
            }
          }

          return Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(sheetContext).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 16, 16),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.backup_rounded,
                              color: Colors.teal,
                              size: 26,
                            ),
                          ),
                          const Gap(16),
                          const Expanded(
                            child: Text(
                              'Sao lưu & Khôi phục',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isProcessing
                                ? null
                                : () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    'Lưu ý: Bạn có thể trích xuất Database ra file (.db), hoặc khôi phục từ file chọn trong máy. Sau khi khôi phục, bạn cần khởi động lại ứng dụng.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                if (isProcessing)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        Gap(10),
                        Expanded(
                          child: Text(
                            'Đang xử lý, vui lòng chờ...',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Gap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  await runWithLock(() async {
                                    await AdminBackupService.exportDatabase(
                                      sheetContext,
                                    );
                                  });
                                },
                          icon: const Icon(Icons.ios_share_rounded),
                          label: const Text('Trích xuất (Export)'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blue.shade50,
                            foregroundColor: Colors.blue.shade700,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: sheetContext,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Xác nhận khôi phục'),
                                      content: const Text(
                                        'Khôi phục sẽ ghi đè dữ liệu cục bộ hiện tại trên thiết bị này. Bạn có chắc chắn muốn tiếp tục?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: const Text('Huỷ'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          child: const Text('Khôi phục'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed != true) return;

                                  await runWithLock(() async {
                                    final success =
                                        await AdminBackupService.importDatabase(
                                          sheetContext,
                                        );
                                    if (success && sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
                                  });
                                },
                          icon: const Icon(Icons.file_download_rounded),
                          label: const Text('Phục hồi (Import)'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.orange.shade50,
                            foregroundColor: Colors.orange.shade700,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  await runWithLock(() async {
                                    await AdminBackupService.exportToExcel(
                                      sheetContext,
                                    );
                                  });
                                },
                          icon: const Icon(Icons.table_chart_rounded),
                          label: const Text('Xuất báo cáo Excel (.xlsx)'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green.shade700,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
