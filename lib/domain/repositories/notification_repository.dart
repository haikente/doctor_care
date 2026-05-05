import 'package:doctor_care/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications({int limit = 20, String? lastDocId});

  Future<void> sendNotification({
    required String title,
    required String body,
    String? imageUrl,   
    required NotificationType type,
    String? actionType,
    String? actionData,
    List<String>? userIds, 
    String? topic,  
  });

  Future<void> sendTopicNotification({
    required String title,
    required String body,
    String? imageUrl,
    required NotificationType type,
    required String topic,  
  });

  Future<void> markAsRead(String notificationId);
  
  Future<void> markAllAsRead();
 
  Future<int> getUnreadCount();

  Future<void> deleteNotification(String notificationId);

  Future<void> deleteAllNotifications();

  Stream<List<NotificationEntity>> watchNotifications();

  Stream<int> watchUnreadCount();

  Future<void> storeToken(String userId);

  Future<String?> getToken();
}