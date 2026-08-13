import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/services/auth_storage_service.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    final tr = AppLocalizations.of(context).translate;

    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('error')}: ${tr('email')} ${tr('not_selected')}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('loading')),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('reset_password')} ✅ ($email)'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('error')}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context).translate;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '--';
    final isEmailVerified = user?.emailVerified ?? false;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: tr('account_security'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('personal_info'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Gap(10),
                _InfoRow(label: 'Email', value: email),
                const Gap(6),
                _InfoRow(
                  label: tr('confirm'),
                  value: isEmailVerified ? tr('verified') : tr('not_verified'),
                ),
              ],
            ),
          ),
          const Gap(16),

          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.lock_reset_rounded,
                  color: Colors.teal,
                  title: tr('reset_password'),
                  subtitle: tr('send_reset_password_email'),
                  onTap: () => _sendPasswordResetEmail(context),
                ),
                Divider(height: 1, indent: 64, endIndent: 16, color: theme.dividerColor.withOpacity(0.25)),
                _ActionTile(
                  icon: Icons.verified_user_outlined,
                  color: Colors.indigo,
                  title: tr('reload_account_status'),
                  subtitle: tr('refresh_verification_state'),
                  onTap: () async {
                    // Immediate feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tr('loading')),
                        duration: const Duration(seconds: 1),
                      ),
                    );

                    try {
                      await FirebaseAuth.instance.currentUser?.reload();
                      if (!context.mounted) return;

                      (context as Element).markNeedsBuild();

                      // Show result
                      final refreshedUser = FirebaseAuth.instance.currentUser;
                      final refreshedVerified = refreshedUser?.emailVerified ?? false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            refreshedVerified ? tr('verified') : tr('not_verified'),
                          ),
                          backgroundColor: refreshedVerified ? Colors.green : Colors.orange,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${tr('error')}: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                Divider(height: 1, indent: 64, endIndent: 16, color: theme.dividerColor.withOpacity(0.25)),
                _ActionTile(
                  icon: Icons.logout_rounded,
                  color: Colors.red,
                  title: tr('logout'),
                  subtitle: tr('sign_out_and_clear_session'),
                  onTap: () => _showLogoutDialog(context, theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const Gap(2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: theme.colorScheme.onSurface.withOpacity(0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  void _showLogoutDialog(BuildContext context, ThemeData theme) {
    //final tr = AppLocalizations.of(context).translate;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.blue,
                size: 70,
              ),
            ),
            const Gap(25),
            Text(
              "Thông báo",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5
              ),
            ),
            Gap(20),
            Text(
            "Bạn có chắc chắn muốn đăng xuất?",
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          Gap(20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                text: "Huỷ", 
                onPressed: () => Navigator.pop(ctx),
                gradient: [Colors.blue.shade50, Colors.blue.shade50],
                          textColor: Colors.blue,
                ),
              ),
              Gap(10),
              Expanded(
                child: CustomButton(text: "Đồng ý", onPressed: () async {
                Navigator.pop(ctx);
                await AuthStorageService.clearLoginSessionOnly();
                // ignore: use_build_context_synchronously
                  context.read<AuthBloc>().add(SignOutEvent());
                },
               ),
             ),
           ],
          ),
         ],
        ), 
      ),
    );
  }
