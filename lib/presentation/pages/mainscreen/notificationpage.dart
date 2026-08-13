import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/domain/entities/notification_entity.dart';
import 'package:doctor_care/presentation/bloc/notification/notification_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  String selectedFilter = 'all';
  final List<String> filterOptions = ['all', 'unread', 'read'];

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().startListening();
  }

  List<NotificationEntity> _applyFilter(List<NotificationEntity> items) {
    if (selectedFilter == 'unread') {
      return items.where((n) => !n.isRead).toList();
    }
    if (selectedFilter == 'read') {
      return items.where((n) => n.isRead).toList();
    }
    return items;
  }

  void markAsRead(String id) {
    context.read<NotificationCubit>().markAsRead(id);
  }

  void markAllAsRead() {
    context.read<NotificationCubit>().markAllAsRead();
  }

  void deleteNotification(String id) {
    context.read<NotificationCubit>().deleteNotification(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomStackAppBar(
        title: context.tr('notifications_title'),
        centerTitle: true,
        onBack: () => Navigator.pop(context),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            );
          }

          if (state is NotificationError) {
            return _buildErrorState(state.message);
          }

          final notifications = state is NotificationLoaded
              ? state.notifications
              : <NotificationEntity>[];
          final unreadCount = state is NotificationLoaded
              ? state.unreadCount
              : 0;
          final filteredNotifications = _applyFilter(notifications);

          return Column(
            children: [
              _buildHeader(
                totalCount: notifications.length,
                unreadCount: unreadCount,
              ),
              Expanded(
                child: filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: theme.primaryColor,
                        onRefresh: () async {
                          context.read<NotificationCubit>().startListening();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: filteredNotifications.length,
                          separatorBuilder: (_, __) => const Gap(12),
                          itemBuilder: (context, index) {
                            return _buildNotificationItem(
                              filteredNotifications[index],
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader({required int totalCount, required int unreadCount}) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary,
                  Color.lerp(primary, Colors.teal, 0.45) ?? primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.24)),
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'unread_count',
                          params: {'count': unreadCount.toString()},
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '${context.tr('all')}: $totalCount',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unreadCount > 0)
                  TextButton.icon(
                    onPressed: markAllAsRead,
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: Text(context.tr('mark_all')),
                    style: TextButton.styleFrom(
                      foregroundColor: primary,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(14),
          _buildFilterBar(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.06)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: filterOptions.map((filter) {
          final isSelected = selectedFilter == filter;
          final label = switch (filter) {
            'all' => context.tr('all'),
            'unread' => context.tr('filter_unread'),
            'read' => context.tr('filter_read'),
            _ => filter,
          };

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? theme.primaryColor
                        : AppColor.textSecondary(context),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationEntity notification) {
    final theme = Theme.of(context);
    final typeColor = notification.type.color;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('deleted_notification')),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Material(
        color: notification.isRead
            ? theme.cardColor
            : theme.primaryColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (!notification.isRead) {
              markAsRead(notification.id);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: notification.isRead
                    ? AppColor.divider(context)
                    : theme.primaryColor.withOpacity(0.22),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    notification.type.icon,
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.25,
                                fontWeight: notification.isRead
                                    ? FontWeight.w700
                                    : FontWeight.w800,
                                color: AppColor.textPrimary(context),
                              ),
                            ),
                          ),
                          if (!notification.isRead) ...[
                            const Gap(8),
                            Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Gap(7),
                      Text(
                        notification.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColor.textSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColor.textSecondary(context),
                          ),
                          const Gap(5),
                          Text(
                            _formatTimestamp(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.textSecondary(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    String message;
    IconData icon;

    if (selectedFilter == 'unread') {
      message = context.tr('no_unread_notifications');
      icon = Icons.mark_email_read_outlined;
    } else if (selectedFilter == 'read') {
      message = context.tr('no_read_notifications');
      icon = Icons.notifications_none_rounded;
    } else {
      message = context.tr('no_notifications');
      icon = Icons.notifications_off_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 46, color: theme.primaryColor),
            ),
            const Gap(18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColor.textPrimary(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.divider(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 34,
                  color: Colors.red,
                ),
              ),
              const Gap(14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColor.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(16),
              FilledButton.icon(
                onPressed: () =>
                    context.read<NotificationCubit>().startListening(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(context.tr('retry')),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return context.tr('just_now');
    } else if (difference.inMinutes < 60) {
      return context.tr(
        'minutes_ago',
        params: {'count': difference.inMinutes.toString()},
      );
    } else if (difference.inHours < 24) {
      return context.tr(
        'hours_ago',
        params: {'count': difference.inHours.toString()},
      );
    } else if (difference.inDays < 7) {
      return context.tr(
        'days_ago',
        params: {'count': difference.inDays.toString()},
      );
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }
}

extension NotificationTypeUi on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.promotion:
        return Icons.local_offer_outlined;
      case NotificationType.system:
        return Icons.settings_outlined;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.info:
        return Colors.teal;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.promotion:
        return Colors.purple;
      case NotificationType.system:
        return Colors.blueGrey;
    }
  }
}
