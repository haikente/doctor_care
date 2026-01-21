import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/services/auth_storage_service.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade50,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Đăng xuất'),
                                content: const Text('Bạn có chắc muốn đăng xuất?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text('Đăng xuất'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true && context.mounted) {
                              // Clear remember me data
                              await AuthStorageService.clearRememberMe();
                              // Logout
                              context.read<AuthBloc>().add(SignOutEvent());
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                        ),
                      ],
                    ),
                    const Gap(16),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.orange.shade400],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    
                    const Gap(16),
                    
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.red.shade700, Colors.orange.shade700],
                      ).createShader(bounds),
                      child: const Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const Gap(8),
                    
                    Text(
                      user?.email ?? 'Admin',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    
                    const Gap(8),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 16,
                            color: Colors.red.shade700,
                          ),
                          const Gap(4),
                          Text(
                            'Administrator',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    final totalUsers = snapshot.data!.docs.length;
                    final adminCount = snapshot.data!.docs
                        .where((doc) => (doc.data() as Map<String, dynamic>)['role'] == 'admin')
                        .length;
                    final patientCount = totalUsers - adminCount;
                    
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            icon: Icons.people,
                            value: totalUsers.toString(),
                            label: 'Total Users',
                            color: Colors.blue,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            icon: Icons.admin_panel_settings,
                            value: adminCount.toString(),
                            label: 'Admins',
                            color: Colors.red,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            icon: Icons.person,
                            value: patientCount.toString(),
                            label: 'Patients',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              const Gap(24),
              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildAdminCard(
                        context,
                        theme,
                        icon: Icons.people,
                        title: 'Quản lý Người dùng',
                        subtitle: 'Xem và quản lý tất cả người dùng',
                        color: Colors.blue,
                        onTap: () {
                          _showUsersList(context);
                        },
                      ),
                      
                      _buildAdminCard(
                        context,
                        theme,
                        icon: Icons.analytics,
                        title: 'Thống kê',
                        subtitle: 'Xem báo cáo và phân tích dữ liệu',
                        color: Colors.purple,
                        onTap: () {
                          _showStatistics(context);
                        },
                      ),
                      
                      _buildAdminCard(
                        context,
                        theme,
                        icon: Icons.medical_services,
                        title: 'Dữ liệu sức khỏe',
                        subtitle: 'Huyết áp, HbA1c, nhiệt độ',
                        color: Colors.green,
                        onTap: () {
                          _showHealthData(context);
                        },
                      ),
                      
                      _buildAdminCard(
                        context,
                        theme,
                        icon: Icons.settings,
                        title: 'Cấu hình hệ thống',
                        subtitle: 'Cài đặt và tùy chỉnh ứng dụng',
                        color: Colors.orange,
                        onTap: () {
                          _showSettings(context);
                        },
                      ),
                      
                      _buildAdminCard(
                        context,
                        theme,
                        icon: Icons.backup,
                        title: 'Sao lưu & Khôi phục',
                        subtitle: 'Quản lý dữ liệu và backup',
                        color: Colors.teal,
                        onTap: () {
                          _showBackupDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const Gap(8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Gap(4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== ACTION METHODS ==========

  void _showUsersList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(16),
                  const Text(
                    'Danh sách Người dùng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('email')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userData = users[index].data() as Map<String, dynamic>;
                      final email = userData['email'] ?? 'No email';
                      final role = userData['role'] ?? 'patient';
                      final uid = userData['uid'] ?? users[index].id;
                      final fullName = userData['fullName'] ?? 'Chưa cập nhật';
                      final phoneNumber = userData['phoneNumber'];
                      final gender = userData['gender'];
                      final bloodType = userData['bloodType'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: role == 'admin'
                                ? Colors.red.shade100
                                : Colors.blue.shade100,
                            child: Icon(
                              role == 'admin'
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: role == 'admin'
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                          title: Text(
                            fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            email,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Chip(
                            label: Text(
                              role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: role == 'admin'
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                            backgroundColor: role == 'admin'
                                ? Colors.red.shade50
                                : Colors.blue.shade50,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('📧 Email', email),
                                  _buildInfoRow('🆔 UID', uid),
                                  if (phoneNumber != null)
                                    _buildInfoRow('📱 Số điện thoại', phoneNumber),
                                  if (gender != null)
                                    _buildInfoRow('👤 Giới tính', 
                                      gender == 'male' ? 'Nam' : 
                                      gender == 'female' ? 'Nữ' : 'Khác'),
                                  if (bloodType != null)
                                    _buildInfoRow('🩸 Nhóm máu', bloodType),
                                  if (userData['dateOfBirth'] != null)
                                    _buildInfoRow('🎂 Ngày sinh', 
                                      DateTime.parse(userData['dateOfBirth'])
                                          .toString()
                                          .substring(0, 10)),
                                  if (userData['height'] != null)
                                    _buildInfoRow('📏 Chiều cao', 
                                      '${userData['height']} cm'),
                                  if (userData['weight'] != null)
                                    _buildInfoRow('⚖️ Cân nặng', 
                                      '${userData['weight']} kg'),
                                  if (userData['address'] != null)
                                    _buildInfoRow('🏠 Địa chỉ', userData['address']),
                                  if (userData['emergencyContact'] != null)
                                    _buildInfoRow('🆘 Liên hệ khẩn cấp', 
                                      userData['emergencyContact']),
                                  if (userData['emergencyPhone'] != null)
                                    _buildInfoRow('📞 SĐT khẩn cấp', 
                                      userData['emergencyPhone']),
                                  if (userData['allergies'] != null && 
                                      (userData['allergies'] as List).isNotEmpty)
                                    _buildInfoRow('⚠️ Dị ứng', 
                                      (userData['allergies'] as List).join(', ')),
                                  if (userData['chronicDiseases'] != null &&
                                      (userData['chronicDiseases'] as List).isNotEmpty)
                                    _buildInfoRow('🏥 Bệnh mãn tính', 
                                      (userData['chronicDiseases'] as List).join(', ')),
                                  if (userData['medications'] != null &&
                                      (userData['medications'] as List).isNotEmpty)
                                    _buildInfoRow('💊 Thuốc đang dùng', 
                                      (userData['medications'] as List).join(', ')),
                                  const Gap(8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            _showEditUserDialog(context, users[index].id, userData);
                                          },
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: const Text('Chỉnh sửa'),
                                        ),
                                      ),
                                      const Gap(8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            _showDeleteUserDialog(context, users[index].id, email);
                                          },
                                          icon: const Icon(Icons.delete, size: 16),
                                          label: const Text('Xóa'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatistics(BuildContext context) {
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

  void _showHealthData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💊 Dữ liệu sức khỏe'),
        content: const Text('Chức năng quản lý dữ liệu sức khỏe đang được phát triển...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
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

  void _showBackupDialog(BuildContext context) {
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

  // ========== HELPER METHODS ==========

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, String docId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✏️ Chỉnh sửa thông tin'),
        content: const Text('Chức năng chỉnh sửa sẽ được phát triển trong phiên bản tiếp theo.\n\nBạn có thể chỉnh sửa trực tiếp trong Firebase Console.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, String docId, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xóa người dùng'),
        content: Text('Bạn có chắc muốn xóa người dùng "$email"?\n\nHành động này không thể hoàn tác!'),
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
}