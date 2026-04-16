import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/services/auth_storage_service.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:doctor_care/presentation/pages/screens/admin/widgets/controller/usercase.dart';
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
            colors: [Colors.blue.shade50, Colors.blueAccent],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
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
                                content: const Text(
                                  'Bạn có chắc muốn đăng xuất?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
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
                              final authBloc = context.read<AuthBloc>();
                              // Clear tất cả dữ liệu đăng nhập
                              await AuthStorageService.clearAll();
                              if (!context.mounted) return;
                              // Logout
                              authBloc.add(SignOutEvent());
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.blue),
                        ),
                      ],
                    ),
                    const Gap(12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.orange.shade400,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),

                    const Gap(12),

                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.blue.shade700, Colors.orange.shade700],
                      ).createShader(bounds),
                      child: const Text(
                        'DrCare Admin',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const Gap(6),

                    Text(
                      user?.email ?? 'Admin',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Gap(6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const Gap(4),
                          Text(
                            'Administrator',
                            style: TextStyle(
                              color: Colors.blue.shade700,
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

              // Stats Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final totalUsers = snapshot.data!.docs.length;
                    final adminCount = snapshot.data!.docs
                        .where(
                          (doc) =>
                              (doc.data() as Map<String, dynamic>)['role'] ==
                              'admin',
                        )
                        .length;
                    final userCount = totalUsers - adminCount;

                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            icon: Icons.people,
                            value: totalUsers.toString(),
                            label: 'Tổng',
                            color: Colors.blue,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            icon: Icons.admin_panel_settings,
                            value: adminCount.toString(),
                            label: 'Admin',
                            color: Colors.red,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            icon: Icons.person,
                            value: userCount.toString(),
                            label: 'Người dùng',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Gap(16),

              // Main Content
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
                    padding: const EdgeInsets.all(20),
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
                        subtitle: 'Tổng quan người dùng & hoạt động',
                        color: Colors.purple,
                        onTap: () {
                          Usercase().showStatistics(context);
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
                          Usercase().showBackupDialog(context);
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
                          Usercase().showSettings(context);
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const Gap(6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Gap(3),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 11,
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
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Gap(3),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  void _showUsersList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
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
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.manage_accounts_rounded,
                            color: Colors.blue,
                            size: 26,
                          ),
                        ),
                        const Gap(16),
                        const Expanded(
                          child: Text(
                            'Quản lý Người dùng',
                            style: TextStyle(
                              fontSize: 22,
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
                            foregroundColor: Colors.grey.shade700,
                          ),
                        ),
                      ],
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
                      padding: const EdgeInsets.all(20),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userData =
                            users[index].data() as Map<String, dynamic>;
                        final email = userData['email'] ?? 'No email';
                        final role = userData['role'] ?? 'users';
                        final uid = userData['uid'] ?? users[index].id;
                        final fullName =
                            userData['fullName'] ?? 'Chưa cập nhật';
                        final phoneNumber = userData['phoneNumber'];
                        final gender = userData['gender'];
                        final bloodType = userData['bloodType'];
                        final isAdmin = role == 'admin';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.15),
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                16,
                              ),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: isAdmin
                                    ? Colors.red.shade50
                                    : Colors.blue.shade50,
                                child: Icon(
                                  isAdmin
                                      ? Icons.admin_panel_settings_rounded
                                      : Icons.person_rounded,
                                  color: isAdmin ? Colors.red : Colors.blue,
                                  size: 26,
                                ),
                              ),
                              title: Text(
                                fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isAdmin
                                      ? Colors.red.shade50
                                      : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isAdmin
                                        ? Colors.red.withOpacity(0.3)
                                        : Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: isAdmin
                                        ? Colors.red.shade700
                                        : Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade50.withOpacity(
                                      0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blueGrey.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow('📧 Email', email),
                                      _buildInfoRow('🆔 UID', uid),
                                      if (phoneNumber != null)
                                        _buildInfoRow(
                                          '📱 Số điện thoại',
                                          phoneNumber,
                                        ),
                                      if (gender != null)
                                        _buildInfoRow(
                                          '👤 Giới tính',
                                          gender == 'male'
                                              ? 'Nam'
                                              : gender == 'female'
                                              ? 'Nữ'
                                              : 'Khác',
                                        ),
                                      if (bloodType != null)
                                        _buildInfoRow('🩸 Nhóm máu', bloodType),
                                      if (userData['dateOfBirth'] != null)
                                        _buildInfoRow(
                                          '🎂 Ngày sinh',
                                          DateTime.parse(
                                            userData['dateOfBirth'],
                                          ).toString().substring(0, 10),
                                        ),
                                      if (userData['height'] != null)
                                        _buildInfoRow(
                                          '📏 Chiều cao',
                                          '${userData['height']} cm',
                                        ),
                                      if (userData['weight'] != null)
                                        _buildInfoRow(
                                          '⚖️ Cân nặng',
                                          '${userData['weight']} kg',
                                        ),
                                      if (userData['address'] != null)
                                        _buildInfoRow(
                                          '🏠 Địa chỉ',
                                          userData['address'],
                                        ),
                                      if (userData['emergencyContact'] != null)
                                        _buildInfoRow(
                                          '🆘 Liên hệ khẩn cấp',
                                          userData['emergencyContact'],
                                        ),
                                      if (userData['emergencyPhone'] != null)
                                        _buildInfoRow(
                                          '📞 SĐT khẩn cấp',
                                          userData['emergencyPhone'],
                                        ),
                                      if (userData['allergies'] != null &&
                                          (userData['allergies'] as List)
                                              .isNotEmpty)
                                        _buildInfoRow(
                                          '⚠️ Dị ứng',
                                          (userData['allergies'] as List).join(
                                            ', ',
                                          ),
                                        ),
                                      if (userData['chronicDiseases'] != null &&
                                          (userData['chronicDiseases'] as List)
                                              .isNotEmpty)
                                        _buildInfoRow(
                                          '🏥 Bệnh mãn',
                                          (userData['chronicDiseases'] as List)
                                              .join(', '),
                                        ),
                                      if (userData['medications'] != null &&
                                          (userData['medications'] as List)
                                              .isNotEmpty)
                                        _buildInfoRow(
                                          '💊 Trị liệu',
                                          (userData['medications'] as List)
                                              .join(', '),
                                        ),
                                    ],
                                  ),
                                ),
                                const Gap(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Usercase().showEditUserDialog(
                                            context,
                                            users[index].id,
                                            userData,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.edit_rounded,
                                          size: 18,
                                        ),
                                        label: const Text('Chỉnh sửa'),
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.blue.shade50,
                                          foregroundColor: Colors.blue.shade700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Usercase().showDeleteUserDialog(
                                            context,
                                            users[index].id,
                                            email,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.delete_rounded,
                                          size: 18,
                                        ),
                                        label: const Text('Xóa'),
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.red.shade50,
                                          foregroundColor: Colors.red.shade700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
