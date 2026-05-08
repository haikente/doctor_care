import 'package:doctor_care/core/images/images.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/services/auth_storage_service.dart';
import 'package:doctor_care/core/services/image_upload_service.dart';
import 'package:doctor_care/presentation/bloc/locale/locale_cubit.dart';
import 'package:doctor_care/presentation/bloc/themestate/themestate_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/FamilyProfile/family_profile_screen.dart';
import 'package:doctor_care/presentation/pages/screens/profile/account_security_screen.dart';
import 'package:doctor_care/presentation/pages/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:image_picker/image_picker.dart';

class Profilepage extends StatelessWidget {
  const Profilepage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, theme, isDarkMode),

            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Quick Stats Card ──
                    _buildQuickStatsCard(context, theme),
                    const Gap(24),

                    // ── Cài đặt Section ──
                    _buildSectionTitle(context, context.tr('settings'), theme),
                    const Gap(10),
                    _buildMenuCard(theme, [
                      _buildMenuItem(
                        theme: theme,
                        icon: Icons.person_outline_rounded,
                        iconColor: Colors.blue,
                        title: context.tr('personal_info'),
                        subtitle: context.tr('personal_info_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(theme),
                      _buildMenuItem(
                        theme: theme,
                        icon: Icons.family_restroom_rounded,
                        iconColor: Colors.purple,
                        title: context.tr('family_members'),
                        subtitle: context.tr('family_members_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FamilyProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(theme),
                      _buildMenuItem(
                        theme: theme,
                        icon: Icons.shield_outlined,
                        iconColor: Colors.teal,
                        title: context.tr('account_security'),
                        subtitle: context.tr('account_security_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccountSecurityScreen(),
                            ),
                          );
                        },
                      ),
                    ]),

                    const Gap(24),

                    // ── Tùy chọn Section ──
                    _buildSectionTitle(
                      context,
                      context.tr('preferences'),
                      theme,
                    ),
                    const Gap(10),
                    _buildMenuCard(theme, [
                      _buildMenuItem(
                        theme: theme,
                        icon: Icons.notifications_outlined,
                        iconColor: Colors.orange,
                        title: context.tr('notifications'),
                        subtitle: context.tr('notifications_sub'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {},
                          activeThumbColor: theme.primaryColor,
                        ),
                        onTap: null,
                      ),
                      _buildDivider(theme),
                      _buildMenuItem(
                        theme: theme,
                        icon: isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        iconColor: isDarkMode ? Colors.indigo : Colors.amber,
                        title: context.tr('dark_mode'),
                        subtitle: isDarkMode
                            ? context.tr('dark_mode_on')
                            : context.tr('dark_mode_off'),
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            context.read<ThemeCubit>().toggleTheme();
                          },
                          activeThumbColor: theme.primaryColor,
                        ),
                        onTap: null,
                      ),
                      _buildDivider(theme),
                      _buildMenuItem(
                        theme: theme,
                        icon: Icons.translate_rounded,
                        iconColor: Colors.green,
                        title: context.tr('language'),
                        subtitle: context
                            .read<LocaleCubit>()
                            .currentLanguageName,
                        onTap: () => _showLanguageDialog(context, theme),
                      ),
                    ]),

                    const Gap(24),

                    // ── Hỗ trợ Section ──
                    _buildSectionTitle(context, context.tr('support'), theme),
                    const Gap(10),
                    _buildMenuCard(theme, [
                      _buildMenuItem(
                        theme: theme,
                        icon: Icons.help_outline_rounded,
                        iconColor: Colors.cyan,
                        title: context.tr('help_faq'),
                        onTap: () {},
                      ),
                      _buildDivider(theme),
                      _buildMenuItem(
                        theme: theme,
                        icon: Icons.info_outline_rounded,
                        iconColor: Colors.grey,
                        title: context.tr('about_app'),
                        subtitle: '${context.tr('version')} 1.0.0',
                        onTap: () {},
                      ),
                    ]),

                    const Gap(24),

                    // ── Logout Button ──
                    _buildLogoutButton(context, theme),

                    const Gap(100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Stack(
      children: [
        Positioned.fill(child: Image.asset(Images.profile, fit: BoxFit.cover)),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              children: [
                const Gap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('profile'),
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(28),

                // ── Avatar ──
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final String? photoUrl = state is Authenticated
                        ? state.user.profilePhotoUrl
                        : null;

                    return GestureDetector(
                      onTap: () => _showPhotoOptions(context, state),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              backgroundImage: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Gap(20),

                // ── Name + Info ──
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Authenticated) {
                      return Column(
                        children: [
                          Text(
                            state.user.fullName ?? context.tr('user'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Text(
                          context.tr('user'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Gap(10),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Row(
            children: [
              _buildStatItem(
                icon: Icons.favorite_rounded,
                color: Colors.red,
                label: context.tr('health_status'),
                value: context.tr('good'),
              ),
              _buildStatDivider(theme),
              _buildStatItem(
                icon: Icons.restaurant_rounded,
                color: Colors.orange,
                label: context.tr('meals'),
                value: context.tr('today'),
              ),
              _buildStatDivider(theme),
              _buildStatItem(
                icon: Icons.directions_walk_rounded,
                color: Colors.green,
                label: context.tr('steps'),
                value: context.tr('tracking'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Gap(8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const Gap(2),
          Text(
            value,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(ThemeData theme) {
    return Container(
      height: 40,
      width: 1,
      color: theme.dividerColor.withOpacity(0.3),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 64,
      endIndent: 16,
      color: theme.dividerColor.withOpacity(0.3),
    );
  }

  Widget _buildMenuItem({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
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
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
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
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const Gap(2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
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

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showLogoutDialog(context, theme),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                const Gap(10),
                Text(
                  context.tr('logout'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ThemeData theme) {
    final tr = AppLocalizations.of(context).translate;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
            const Gap(12),
            Text(
              tr('logout'),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          tr('logout_confirm'),
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              tr('cancel'),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthStorageService.clearAll();
              // ignore: use_build_context_synchronously
              context.read<AuthBloc>().add(SignOutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              tr('logout'),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, ThemeData theme) {
    final tr = AppLocalizations.of(context).translate;
    final localeCubit = context.read<LocaleCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(16),
            Text(
              tr('choose_language'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Gap(16),
            ListTile(
              leading: const Text('🇻🇳', style: TextStyle(fontSize: 28)),
              title: Text(
                'Tiếng Việt',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: localeCubit.isVietnamese
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              trailing: localeCubit.isVietnamese
                  ? Icon(Icons.check_circle, color: theme.primaryColor)
                  : null,
              onTap: () {
                localeCubit.changeLocale(const Locale('vi'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 28)),
              title: Text(
                'English',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: localeCubit.isEnglish
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              trailing: localeCubit.isEnglish
                  ? Icon(Icons.check_circle, color: theme.primaryColor)
                  : null,
              onTap: () {
                localeCubit.changeLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context, AuthState state) {
    if (state is! Authenticated) return;

    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context).translate;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(20),
            ListTile(
              leading: Icon(Icons.photo_library, color: theme.primaryColor),
              title: Text(
                tr('choose_from_gallery'),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _uploadPhoto(context, state.user.uid, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: theme.primaryColor),
              title: Text(
                tr('take_photo'),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _uploadPhoto(context, state.user.uid, ImageSource.camera);
              },
            ),
            if (state.user.profilePhotoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  tr('delete_avatar'),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _deletePhoto(context, state.user.uid);
                },
              ),
            const Gap(10),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadPhoto(
    BuildContext context,
    String userId,
    ImageSource source,
  ) async {
    final tr = AppLocalizations.of(context).translate;
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const Gap(15),
              Text(tr('uploading_photo')),
            ],
          ),
        ),
      ),
    );

    try {
      final String? photoUrl = await ImageUploadService.uploadProfilePhoto(
        userId: userId,
        source: source,
        onProgress: (progress) {
          // Update progress if needed
          print('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
        },
      );

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      if (photoUrl != null) {
        // Reload user data
        if (context.mounted) {
          context.read<AuthBloc>().add(CheckAuthStatusEvent());
        }

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('update_avatar_success')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('upload_failed')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr('error')}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto(BuildContext context, String userId) async {
    final tr = AppLocalizations.of(context).translate;
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('confirm')),
        content: Text(tr('confirm_delete_avatar')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // Delete from storage
      await ImageUploadService.deleteOldProfilePhoto(userId);

      // Update Firestore
      await ImageUploadService.updateUserProfilePhoto(
        userId: userId,
        photoUrl: '',
      );

      // Close loading
      if (context.mounted) Navigator.pop(context);

      // Reload user data
      if (context.mounted) {
        context.read<AuthBloc>().add(CheckAuthStatusEvent());
      }

      // Show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('deleted_avatar')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (context.mounted) Navigator.pop(context);

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr('error')}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
