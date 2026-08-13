import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:doctor_care/presentation/bloc/notification/notification_cubit.dart';
import 'package:doctor_care/presentation/pages/mainscreen/notificationpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _Avatar(primary: primary),
          const Gap(14),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final name = state is Authenticated
                    ? (state.user.fullName?.trim().isNotEmpty == true
                          ? state.user.fullName!.trim()
                          : state.user.email)
                    : context.tr('user');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _greetingIcon(),
                          size: 15,
                          color: primary.withOpacity(0.85),
                        ),
                        const Gap(6),
                        Flexible(
                          child: Text(
                            _greetingText(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColor.textSecondary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900.withOpacity(0.7),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Gap(12),
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final unreadCount = state is NotificationLoaded
                  ? state.unreadCount
                  : 0;
              return _NotificationButton(
                primary: primary,
                unreadCount: unreadCount,
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _greetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 18) return Icons.light_mode_rounded;
    return Icons.nights_stay_rounded;
  }

  String _greetingText(BuildContext context) {
    final baseGreeting = context.tr('hello');
    final hour = DateTime.now().hour;
    if (hour < 12) return '$baseGreeting, buổi sáng';
    if (hour < 18) return '$baseGreeting, buổi chiều';
    return '$baseGreeting, buổi tối';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withOpacity(0.10),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [primary, const Color(0xFF20A386)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.primary, required this.unreadCount});

  final Color primary;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Thông báo',
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Notificationpage()),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.09),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primary.withOpacity(0.14)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.notifications_none_rounded, color: primary, size: 25),
              if (unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
