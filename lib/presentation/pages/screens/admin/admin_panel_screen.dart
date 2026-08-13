import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/services/auth_storage_service.dart';
import 'package:doctor_care/core/services/admin_audit_service.dart';
import 'package:doctor_care/core/services/role_service.dart';
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
                        'HealthCare+ Admin',
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
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: Text('Không tải được thống kê')),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final totalUsers = snapshot.data!.docs.length;
                    final adminCount = snapshot.data!.docs
                        .where((doc) => doc.data()['role'] == 'admin')
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

                      _buildAdminCard(
                        context,
                        theme,
                        icon: Icons.notifications_active,
                        title: "Gửi thông báo",
                        subtitle: "Gửi thông báo người dùng",
                        color: Colors.indigo,
                        onTap: () => Usercase()
                            .showSendNotificationDialogModern(context),
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
      builder: (context) {
        String query = '';
        String filter = 'all';

        return StatefulBuilder(
          builder: (context, setModalState) => DraggableScrollableSheet(
            initialChildSize: 0.92,
            minChildSize: 0.55,
            maxChildSize: 0.98,
            expand: false,
            builder: (context, scrollController) {
              final theme = Theme.of(context);

              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    _buildUsersSheetHeader(
                      context,
                      queryChanged: (value) {
                        setModalState(() => query = value.trim().toLowerCase());
                      },
                      filter: filter,
                      filterChanged: (value) {
                        setModalState(() => filter = value);
                      },
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .orderBy('email')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                'Không tải được danh sách người dùng',
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final users = snapshot.data!.docs.where((doc) {
                            final data = doc.data();
                            final role = _displayText(
                              data['role'],
                              fallback: 'users',
                            );
                            final isActive = _isUserActive(data);
                            final searchable =
                                [
                                      data['fullName'],
                                      data['email'],
                                      data['phoneNumber'],
                                      data['uid'] ?? doc.id,
                                    ]
                                    .map(
                                      (v) => v?.toString().toLowerCase() ?? '',
                                    )
                                    .join(' ');
                            final matchesQuery =
                                query.isEmpty || searchable.contains(query);
                            final matchesFilter =
                                filter == 'all' ||
                                (filter == 'active' && isActive) ||
                                (filter == 'disabled' && !isActive) ||
                                filter == role;
                            return matchesQuery && matchesFilter;
                          }).toList();

                          if (users.isEmpty) {
                            return const Center(
                              child: Text('Không tìm thấy người dùng phù hợp'),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(20),
                            itemCount: users.length,
                            itemBuilder: (context, index) =>
                                _buildUserManagementCard(context, users[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUsersSheetHeader(
    BuildContext context, {
    required ValueChanged<String> queryChanged,
    required String filter,
    required ValueChanged<String> filterChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
              const Gap(14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý Người dùng',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(2),
                    Text(
                      'Danh sách, chi tiết, trạng thái và quyền truy cập',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
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
          const Gap(16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo tên, email, số điện thoại...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: queryChanged,
          ),
          const Gap(12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildUserFilterChip('Tất cả', 'all', filter, filterChanged),
                _buildUserFilterChip(
                  'Đang hoạt động',
                  'active',
                  filter,
                  filterChanged,
                ),
                _buildUserFilterChip(
                  'Đã khóa',
                  'disabled',
                  filter,
                  filterChanged,
                ),
                _buildUserFilterChip('Admin', 'admin', filter, filterChanged),
                _buildUserFilterChip(
                  'Người dùng',
                  'users',
                  filter,
                  filterChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserFilterChip(
    String label,
    String value,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = value == selected;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue.shade800 : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildUserManagementCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> userDoc,
  ) {
    final data = userDoc.data();
    final email = _displayText(data['email'], fallback: 'No email');
    final role = _displayText(data['role'], fallback: 'users');
    final fullName = _displayText(data['fullName']);
    final uid = _displayText(data['uid'] ?? userDoc.id, fallback: userDoc.id);
    final isAdmin = role == 'admin';
    final isActive = _isUserActive(data);
    final permissions = _readPermissions(data['accessPermissions']);
    final enabledCount = permissions.values.where((value) => value).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? Colors.grey.withOpacity(0.16) : Colors.red.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: isAdmin ? Colors.red.shade50 : Colors.blue.shade50,
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const Gap(6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildStatusPill(
                      _roleLabel(role).toUpperCase(),
                      isAdmin ? Colors.red : Colors.blue,
                    ),
                    _buildStatusPill(
                      isActive ? 'HOẠT ĐỘNG' : 'ĐÃ KHÓA',
                      isActive ? Colors.green : Colors.red,
                    ),
                    _buildStatusPill(
                      '$enabledCount/${permissions.length} QUYỀN',
                      Colors.teal,
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.expand_more_rounded),
          children: [
            _buildUserDetails(data, uid, email, role, isActive, permissions),
            const Gap(14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Chỉnh sửa',
                  color: Colors.blue,
                  onPressed: () =>
                      Usercase().showEditUserDialog(context, userDoc.id, data),
                ),
                _buildActionButton(
                  icon: Icons.security_rounded,
                  label: 'Quyền truy cập',
                  color: Colors.teal,
                  onPressed: () => _showAccessControlDialog(
                    context,
                    userDoc.id,
                    email,
                    data,
                  ),
                ),
                _buildActionButton(
                  icon: isActive ? Icons.lock_rounded : Icons.lock_open_rounded,
                  label: isActive ? 'Khóa tài khoản' : 'Mở khóa',
                  color: isActive ? Colors.orange : Colors.green,
                  onPressed: () => _showToggleStatusDialog(
                    context,
                    userDoc.id,
                    email,
                    isActive,
                  ),
                ),
                _buildActionButton(
                  icon: Icons.delete_rounded,
                  label: 'Xóa',
                  color: Colors.red,
                  onPressed: () => Usercase().showDeleteUserDialog(
                    context,
                    userDoc.id,
                    email,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetails(
    Map<String, dynamic> data,
    String uid,
    String email,
    String role,
    bool isActive,
    Map<String, bool> permissions,
  ) {
    final dobText = _formatDateOfBirth(data['dateOfBirth']);
    final allergies = _toStringList(data['allergies']);
    final chronicDiseases = _toStringList(data['chronicDiseases']);
    final medications = _toStringList(data['medications']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Email', email),
          _buildInfoRow('UID', uid),
          _buildInfoRow('Vai trò', _roleLabel(role)),
          _buildInfoRow('Trạng thái', isActive ? 'Đang hoạt động' : 'Đã khóa'),
          if (data['phoneNumber'] != null)
            _buildInfoRow('Số điện thoại', data['phoneNumber']),
          if (data['gender'] != null)
            _buildInfoRow('Giới tính', _genderLabel(data['gender'])),
          if (data['bloodType'] != null)
            _buildInfoRow('Nhóm máu', data['bloodType']),
          if (dobText != null) _buildInfoRow('Ngày sinh', dobText),
          if (data['height'] != null)
            _buildInfoRow('Chiều cao', '${data['height']} cm'),
          if (data['weight'] != null)
            _buildInfoRow('Cân nặng', '${data['weight']} kg'),
          if (data['address'] != null)
            _buildInfoRow('Địa chỉ', data['address']),
          if (data['emergencyContact'] != null)
            _buildInfoRow('Liên hệ khẩn cấp', data['emergencyContact']),
          if (data['emergencyPhone'] != null)
            _buildInfoRow('SĐT khẩn cấp', data['emergencyPhone']),
          if (allergies.isNotEmpty)
            _buildInfoRow('Dị ứng', allergies.join(', ')),
          if (chronicDiseases.isNotEmpty)
            _buildInfoRow('Bệnh mạn', chronicDiseases.join(', ')),
          if (medications.isNotEmpty)
            _buildInfoRow('Trị liệu', medications.join(', ')),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: permissions.entries
                .map(
                  (entry) => _buildStatusPill(
                    '${_permissionLabel(entry.key)}: ${entry.value ? 'Bật' : 'Tắt'}',
                    entry.value ? Colors.green : Colors.grey,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  // ignore: unused_element
  void _showUsersListLegacy(BuildContext context) {
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
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .orderBy('email')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Không tải được danh sách người dùng'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final users = snapshot.data!.docs;

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userData = users[index].data();
                        final email = _displayText(
                          userData['email'],
                          fallback: 'No email',
                        );
                        final role = _displayText(
                          userData['role'],
                          fallback: 'users',
                        );
                        final uid = _displayText(
                          userData['uid'] ?? users[index].id,
                          fallback: users[index].id,
                        );
                        final fullName = _displayText(
                          userData['fullName'],
                          fallback: 'Chưa cập nhật',
                        );
                        final phoneNumber = userData['phoneNumber'];
                        final gender = userData['gender'];
                        final bloodType = userData['bloodType'];
                        final isAdmin = role == 'admin';
                        final dobText = _formatDateOfBirth(
                          userData['dateOfBirth'],
                        );
                        final allergies = _toStringList(userData['allergies']);
                        final chronicDiseases = _toStringList(
                          userData['chronicDiseases'],
                        );
                        final medications = _toStringList(
                          userData['medications'],
                        );

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
                                      if (dobText != null)
                                        _buildInfoRow('🎂 Ngày sinh', dobText),
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
                                      if (allergies.isNotEmpty)
                                        _buildInfoRow(
                                          '⚠️ Dị ứng',
                                          allergies.join(', '),
                                        ),
                                      if (chronicDiseases.isNotEmpty)
                                        _buildInfoRow(
                                          '🏥 Bệnh mãn',
                                          chronicDiseases.join(', '),
                                        ),
                                      if (medications.isNotEmpty)
                                        _buildInfoRow(
                                          '💊 Trị liệu',
                                          medications.join(', '),
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

  void _showToggleStatusDialog(
    BuildContext context,
    String docId,
    String email,
    bool currentIsActive,
  ) {
    final nextIsActive = !currentIsActive;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(nextIsActive ? 'Mở khóa tài khoản' : 'Khóa tài khoản'),
        content: Text(
          nextIsActive
              ? 'Cho phép "$email" đăng nhập và sử dụng lại ứng dụng?'
              : 'Tài khoản "$email" sẽ không thể đăng nhập cho đến khi được mở khóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            icon: Icon(nextIsActive ? Icons.lock_open : Icons.lock),
            label: Text(nextIsActive ? 'Mở khóa' : 'Khóa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: nextIsActive ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final success = await RoleService.toggleUserActiveStatus(
                docId,
                nextIsActive,
              );
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Đã cập nhật trạng thái tài khoản'
                        : 'Không thể cập nhật trạng thái tài khoản',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );

              if (success) {
                await AdminAuditService().logToggleUserStatus(
                  docId,
                  email,
                  nextIsActive,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAccessControlDialog(
    BuildContext context,
    String docId,
    String email,
    Map<String, dynamic> userData,
  ) {
    final permissions = _readPermissions(userData['accessPermissions']);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Kiểm soát quyền truy cập'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: permissions.entries.map((entry) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_permissionLabel(entry.key)),
                  subtitle: Text(_permissionDescription(entry.key)),
                  value: entry.value,
                  onChanged: (value) {
                    setDialogState(() => permissions[entry.key] = value);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded),
              label: const Text('Lưu quyền'),
              onPressed: () async {
                final success = await RoleService.updateAccessPermissions(
                  docId,
                  permissions,
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Đã cập nhật quyền truy cập'
                          : 'Không thể cập nhật quyền truy cập',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                if (success) {
                  await AdminAuditService().logUpdateUserAccess(
                    docId,
                    email,
                    permissions,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _isUserActive(Map<String, dynamic> userData) {
    final status = userData['accountStatus']?.toString().toLowerCase();
    if (status == 'disabled' || status == 'locked' || status == 'inactive') {
      return false;
    }
    return userData['isActive'] != false;
  }

  Map<String, bool> _readPermissions(Object? rawValue) {
    final defaults = <String, bool>{
      'healthData': true,
      'appointments': true,
      'notifications': true,
      'profileEdit': true,
      'adminPanel': false,
    };

    if (rawValue is Map) {
      rawValue.forEach((key, value) {
        final name = key.toString();
        if (defaults.containsKey(name)) {
          defaults[name] = value == true;
        }
      });
    }

    return defaults;
  }

  String _permissionLabel(String key) {
    switch (key) {
      case 'healthData':
        return 'Dữ liệu sức khỏe';
      case 'appointments':
        return 'Lịch hẹn';
      case 'notifications':
        return 'Thông báo';
      case 'profileEdit':
        return 'Cập nhật hồ sơ';
      case 'adminPanel':
        return 'Trang quản trị';
      default:
        return key;
    }
  }

  String _permissionDescription(String key) {
    switch (key) {
      case 'healthData':
        return 'Cho phép xem và ghi nhận chỉ số sức khỏe.';
      case 'appointments':
        return 'Cho phép sử dụng chức năng lịch hẹn và ghi chú.';
      case 'notifications':
        return 'Cho phép nhận thông báo từ hệ thống.';
      case 'profileEdit':
        return 'Cho phép người dùng tự cập nhật hồ sơ cá nhân.';
      case 'adminPanel':
        return 'Chỉ bật cho tài khoản được cấp quyền quản trị.';
      default:
        return '';
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'doctor':
        return 'Bác sĩ';
      case 'patient':
      case 'users':
        return 'Người dùng';
      default:
        return role;
    }
  }

  String _genderLabel(Object? gender) {
    switch (gender?.toString()) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      default:
        return 'Khác';
    }
  }

  String _displayText(Object? value, {String fallback = 'Chưa cập nhật'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }
    return text;
  }

  String? _formatDateOfBirth(Object? rawValue) {
    if (rawValue == null) return null;

    DateTime? date;
    if (rawValue is Timestamp) {
      date = rawValue.toDate();
    } else if (rawValue is DateTime) {
      date = rawValue;
    } else {
      date = DateTime.tryParse(rawValue.toString());
    }

    if (date == null) return null;
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  List<String> _toStringList(Object? rawValue) {
    if (rawValue is! List) return const [];
    return rawValue
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Widget _buildInfoRow(String label, Object? value) {
    final text = _displayText(value, fallback: '-');

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
              text,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
