import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
    String selectedRole = userData['role'] ?? 'patient';
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
                        value: 'patient',
                        child: Text('Bệnh nhân'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Thống kê'),
        content: const Text('Chức năng thống kê đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚙️ Cấu hình hệ thống'),
        content: const Text('Chức năng cấu hình đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💾 Sao lưu & Khôi phục'),
        content: const Text('Chức năng backup đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
