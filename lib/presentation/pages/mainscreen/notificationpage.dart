import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
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

  List<NotificationEntity> _applyFilter(
    List<NotificationEntity> items,
  ) {
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomStackAppBar(
        title: context.tr('notifications_title'),
        centerTitle: true,
        onBack: () => Navigator.pop(context),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return _buildErrorState(state.message);
          }

          final notifications = state is NotificationLoaded
              ? state.notifications
              : <NotificationEntity>[];
          final unreadCount =
              state is NotificationLoaded ? state.unreadCount : 0;
          final filteredNotifications = _applyFilter(notifications);

          return Column(
            children: [
              Container(
                color: theme.colorScheme.surface,
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            Gap(8),
                            Text(
                              context.tr(
                                'unread_count',
                                params: {'count': unreadCount.toString()},
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),

                        // Mark all as read button
                        if (unreadCount > 0)
                          TextButton.icon(
                            onPressed: markAllAsRead,
                            icon: Icon(Icons.done_all, size: 18),
                            label: Text(context.tr('mark_all')),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue.shade700,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                      ],
                    ),

                    Gap(12),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filterOptions.map((filter) {
                          final isSelected = selectedFilter == filter;
                          final label = switch (filter) {
                            'all' => context.tr('all'),
                            'unread' => context.tr('filter_unread'),
                            'read' => context.tr('filter_read'),
                            _ => filter,
                          };
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(label),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedFilter = filter;
                                });
                              },
                              backgroundColor: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              selectedColor: theme.primaryColor.withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? theme.primaryColor
                                    : AppColor.textSecondary(context),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? theme.primaryColor
                                    : AppColor.divider(context),
                                width: 1.5,
                              ),
                              checkmarkColor: theme.primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: AppColor.divider(context)),

              // ========== NOTIFICATION LIST ==========
              Expanded(
                child: filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          context.read<NotificationCubit>().startListening();
                        },
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredNotifications.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: AppColor.divider(context),
                            indent: 70,
                          ),
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return _buildNotificationItem(notification);
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

  // ========== NOTIFICATION ITEM ==========
  Widget _buildNotificationItem(NotificationEntity notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('deleted_notification')),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            markAsRead(notification.id);
          }
        },
        child: Container(
          color: notification.isRead
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).primaryColor.withOpacity(0.05),
          padding: EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification.type.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.type.icon,
                  color: notification.type.color,
                  size: 24,
                ),
              ),

              Gap(12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: AppColor.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade700,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    Gap(4),

                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColor.textSecondary(context),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Gap(6),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColor.textSecondary(context),
                        ),
                        Gap(4),
                        Text(
                          _formatTimestamp(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColor.textSecondary(context),
                            fontWeight: FontWeight.w500,
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
    );
  }

  // ========== EMPTY STATE ==========
  Widget _buildEmptyState() {
    String message;
    IconData icon;

    if (selectedFilter == 'unread') {
      message = context.tr('no_unread_notifications');
      icon = Icons.check_circle_outline;
    } else if (selectedFilter == 'read') {
      message = context.tr('no_read_notifications');
      icon = Icons.notifications_none;
    } else {
      message = context.tr('no_notifications');
      icon = Icons.notifications_off_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColor.textSecondary(context).withOpacity(0.5),
          ),
          Gap(16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColor.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColor.textSecondary(context).withOpacity(0.6),
          ),
          Gap(12),
          Text(
            context.tr(message),
            style: TextStyle(
              fontSize: 14,
              color: AppColor.textSecondary(context),
            ),
          ),
          Gap(12),
          ElevatedButton(
            onPressed: () =>
                context.read<NotificationCubit>().startListening(),
            child: Text(context.tr('retry')),
          ),
        ],
      ),
    );
  }

  // ========== FORMAT TIMESTAMP ==========
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return context.tr('just_now');
    } else if (difference.inMinutes < 60) {
      return context.tr('minutes_ago', params: {'count': difference.inMinutes.toString()});
    } else if (difference.inHours < 24) {
      return context.tr('hours_ago', params: {'count': difference.inHours.toString()});
    } else if (difference.inDays < 7) {
      return context.tr('days_ago', params: {'count': difference.inDays.toString()});
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
