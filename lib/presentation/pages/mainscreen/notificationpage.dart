import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  // Mock data - Replace with actual data from Bloc/Cubit
  final List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      type: NotificationType.reminder,
      title: 'Nhắc nhở đo huyết áp',
      message: 'Đã đến giờ đo huyết áp buổi sáng. Hãy đo và ghi lại kết quả.',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      type: NotificationType.warning,
      title: 'Cảnh báo HbA1c cao',
      message: 'Chỉ số HbA1c của bạn đang ở mức 7.2%. Cần điều chỉnh chế độ ăn uống.',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      type: NotificationType.achievement,
      title: 'Hoàn thành mục tiêu',
      message: 'Chúc mừng! Bạn đã duy trì đo huyết áp đều đặn trong 7 ngày.',
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      type: NotificationType.info,
      title: 'Cập nhật hệ thống',
      message: 'Ứng dụng đã được cập nhật với tính năng theo dõi SpO2 mới.',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      type: NotificationType.alert,
      title: 'Nhiệt độ cao bất thường',
      message: 'Nhiệt độ của bạn đạt 38.5°C. Nên nghỉ ngơi và theo dõi.',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
    ),
  ];

  String selectedFilter = 'Tất cả';
  final List<String> filterOptions = ['Tất cả', 'Chưa đọc', 'Đã đọc'];

  List<NotificationModel> get filteredNotifications {
    if (selectedFilter == 'Chưa đọc') {
      return notifications.where((n) => !n.isRead).toList();
    } else if (selectedFilter == 'Đã đọc') {
      return notifications.where((n) => n.isRead).toList();
    }
    return notifications;
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }
    });
  }

  void markAllAsRead() {
    setState(() {
      for (int i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    });
  }

  void deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomStackAppBar(
        title: "Thông báo",
        centerTitle: true,
        //onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // ========== HEADER WITH STATS & ACTION ==========
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Unread count
                    Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.blue.shade700, size: 20),
                        Gap(8),
                        Text(
                          '$unreadCount chưa đọc',
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
                        label: Text('Đánh dấu tất cả'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: Colors.blue.shade50,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          checkmarkColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 1, color: Colors.grey.shade300),
          
          // ========== NOTIFICATION LIST ==========
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredNotifications.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                      indent: 70,
                    ),
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ========== NOTIFICATION ITEM ==========
  Widget _buildNotificationItem(NotificationModel notification) {
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
            content: Text('Đã xóa thông báo'),
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
          // TODO: Navigate to detail or related screen
        },
        child: Container(
          color: notification.isRead ? Colors.white : Colors.blue.shade50.withOpacity(0.3),
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
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                              color: Colors.black87,
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
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    Gap(6),
                    
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                        Gap(4),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
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
    
    if (selectedFilter == 'Chưa đọc') {
      message = 'Không có thông báo chưa đọc';
      icon = Icons.check_circle_outline;
    } else if (selectedFilter == 'Đã đọc') {
      message = 'Không có thông báo đã đọc';
      icon = Icons.notifications_none;
    } else {
      message = 'Chưa có thông báo nào';
      icon = Icons.notifications_off_outlined;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          Gap(16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
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
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }
}

// ========== NOTIFICATION MODEL ==========
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

// ========== NOTIFICATION TYPES ==========
enum NotificationType {
  reminder,
  warning,
  alert,
  info,
  achievement;

  IconData get icon {
    switch (this) {
      case NotificationType.reminder:
        return Icons.access_alarm;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.alert:
        return Icons.error_outline;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.achievement:
        return Icons.emoji_events_outlined;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.reminder:
        return Colors.blue;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.alert:
        return Colors.red;
      case NotificationType.info:
        return Colors.teal;
      case NotificationType.achievement:
        return Colors.amber;
    }
  }
}