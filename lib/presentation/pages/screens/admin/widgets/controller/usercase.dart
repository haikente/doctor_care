import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/presentation/pages/screens/admin/widgets/controller/admin_stats.dart';
import 'package:doctor_care/presentation/pages/screens/admin/widgets/controller/admin_stats_widgets.dart';
import 'package:doctor_care/presentation/pages/screens/admin/widgets/controller/admin_backup_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:doctor_care/presentation/pages/screens/admin/admin_settings_screen.dart';

class Usercase {
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
    String selectedRole = userData['role'] ?? 'users';
    DateTime? selectedDate = userData['dateOfBirth'] != null
        ? DateTime.parse(userData['dateOfBirth'])
        : null;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('✏️ Chỉnh sửa thông tin'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  TextField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Gap(12),

                  // Phone
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Gap(12),

                  // Gender
                  DropdownButtonFormField<String>(
                    initialValue: selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Giới tính',
                      prefixIcon: Icon(Icons.wc),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Nam')),
                      DropdownMenuItem(value: 'female', child: Text('Nữ')),
                      DropdownMenuItem(value: 'other', child: Text('Khác')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                  ),
                  const Gap(12),

                  // Date of Birth
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime(2000),
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
                      decoration: const InputDecoration(
                        labelText: 'Ngày sinh',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedDate != null
                            ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                            : 'Chọn ngày sinh',
                        style: TextStyle(
                          color: selectedDate != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),

                  // Blood Type
                  DropdownButtonFormField<String>(
                    value: selectedBloodType,
                    decoration: const InputDecoration(
                      labelText: 'Nhóm máu',
                      prefixIcon: Icon(Icons.bloodtype),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'A+', child: Text('A+')),
                      DropdownMenuItem(value: 'A-', child: Text('A-')),
                      DropdownMenuItem(value: 'B+', child: Text('B+')),
                      DropdownMenuItem(value: 'B-', child: Text('B-')),
                      DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                      DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                      DropdownMenuItem(value: 'O+', child: Text('O+')),
                      DropdownMenuItem(value: 'O-', child: Text('O-')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedBloodType = value!;
                      });
                    },
                  ),
                  const Gap(12),

                  // Height
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Chiều cao (cm)',
                      prefixIcon: Icon(Icons.height),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Gap(12),

                  // Weight
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cân nặng (kg)',
                      prefixIcon: Icon(Icons.monitor_weight),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Gap(12),

                  // Address
                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Gap(12),

                  // Emergency Contact
                  TextField(
                    controller: emergencyContactController,
                    decoration: const InputDecoration(
                      labelText: 'Liên hệ khẩn cấp',
                      prefixIcon: Icon(Icons.contact_emergency),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Gap(12),

                  // Emergency Phone
                  TextField(
                    controller: emergencyPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'SĐT khẩn cấp',
                      prefixIcon: Icon(Icons.phone_in_talk),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Gap(12),

                  // Role (Admin only)
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Vai trò',
                      prefixIcon: Icon(Icons.admin_panel_settings),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'users',
                        child: Text('Người dùng'),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
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
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  print('🔄 Bắt đầu cập nhật user: $docId');
                  
                  // Prepare update data
                  final updateData = <String, dynamic>{
                    'fullName': fullNameController.text.trim(),
                    'phoneNumber': phoneController.text.trim(),
                    'gender': selectedGender,
                    'bloodType': selectedBloodType,
                    'role': selectedRole,
                    'address': addressController.text.trim(),
                    'emergencyContact': emergencyContactController.text.trim(),
                    'emergencyPhone': emergencyPhoneController.text.trim(),
                  };

                  // Add optional fields
                  if (selectedDate != null) {
                    updateData['dateOfBirth'] = selectedDate!.toIso8601String();
                  }

                  if (heightController.text.isNotEmpty) {
                    updateData['height'] =
                        double.tryParse(heightController.text) ?? 0;
                  }

                  if (weightController.text.isNotEmpty) {
                    updateData['weight'] =
                        double.tryParse(weightController.text) ?? 0;
                  }

                  print('📝 Update data: $updateData');

                  // Update Firestore
                  print('🔥 Updating Firestore...');
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(docId)
                      .update(updateData);
                  
                  print('✅ Firestore updated successfully!');

                  // Dispose controllers
                  fullNameController.dispose();
                  phoneController.dispose();
                  addressController.dispose();
                  heightController.dispose();
                  weightController.dispose();
                  emergencyContactController.dispose();
                  emergencyPhoneController.dispose();
                  
                  if (!dialogContext.mounted) {
                    
                    return;
                  }

                  Navigator.pop(dialogContext);
                  
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Cập nhật thành công!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  
                  print('✅ Success message shown!');
                } catch (e, stackTrace) {
                  print('❌ ERROR: $e');
                  print('📍 Stack trace: $stackTrace');
                  
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text('❌ Lỗi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
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
                    Icon(Icons.analytics, color: Colors.blue.shade500,),
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
                                value: (stats.stepCountDocs +
                                        stats.waterIntakeDocs +
                                        stats.spo2Docs +
                                        stats.temperatureDocs)
                                    .toString(),
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

                          AdminStatsWidgets.modernCollectionRow(
                            theme,
                            label: 'Dữ liệu Bước chân',
                            value: stats.stepCountDocs,
                            icon: Icons.directions_walk,
                            color: Colors.blue,
                          ),
                          AdminStatsWidgets.modernCollectionRow(
                            theme,
                            label: 'Lượng nước uống',
                            value: stats.waterIntakeDocs,
                            icon: Icons.water_drop,
                            color: Colors.lightBlue,
                          ),
                          AdminStatsWidgets.modernCollectionRow(
                            theme,
                            label: 'Nhịp tim & SpO2',
                            value: stats.spo2Docs,
                            icon: Icons.monitor_heart,
                            color: Colors.red,
                          ),
                          AdminStatsWidgets.modernCollectionRow(
                            theme,
                            label: 'Nhiệt độ cơ thể',
                            value: stats.temperatureDocs,
                            icon: Icons.thermostat,
                            color: Colors.orange,
                          ),

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

  void showBackupDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                        onPressed: () => Navigator.pop(context),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Lưu ý: Bạn có thể trích xuất Database ra file (.db), hoặc khôi phục từ file chọn trong máy. Sau khi khôi phục, bạn cần khởi động lại ứng dụng.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await AdminBackupService.exportDatabase(context);
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
                      onPressed: () async {
                        final success = await AdminBackupService.importDatabase(context);
                        if (success && context.mounted) {
                          Navigator.pop(context);
                        }
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
                      onPressed: () async {
                        await AdminBackupService.exportToExcel(context);
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
      ),
    );
  }
}
