import 'package:doctor_care/data/datasources/notification_remote_datasource.dart';
import 'package:doctor_care/domain/entities/notification_entity.dart';
import 'package:doctor_care/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this.remoteDataSource);

  final NotificationRemoteDataSource remoteDataSource;

  @override
  Future<List<NotificationEntity>> getNotifications({
    int limit = 20,
    String? lastDocId,
  }) async {
    return remoteDataSource.getNotifications(
      limit: limit,
      lastDocId: lastDocId,
    );
  }

  @override
  Future<void> sendNotification({
    required String title,
    required String body,
    String? imageUrl,
    required NotificationType type,
    String? actionType,
    String? actionData,
    List<String>? userIds,
    String? topic,
  }) async {
    await remoteDataSource.sendNotification(
      title: title,
      body: body,
      imageUrl: imageUrl,
      type: type,
      actionType: actionType,
      actionData: actionData,
      userIds: userIds,
      topic: topic,
    );
  }

  @override
  Future<void> sendTopicNotification({
    required String title,
    required String body,
    String? imageUrl,
    required NotificationType type,
    required String topic,
  }) async {
    await remoteDataSource.sendTopicNotification(
      title: title,
      body: body,
      imageUrl: imageUrl,
      type: type,
      topic: topic,
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await remoteDataSource.markAllAsRead();
  }

  @override
  Future<int> getUnreadCount() async {
    return remoteDataSource.getUnreadCount();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await remoteDataSource.deleteNotification(notificationId);
  }

  @override
  Future<void> deleteAllNotifications() async {
    await remoteDataSource.deleteAllNotifications();
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return remoteDataSource.watchNotifications();
  }

  @override
  Stream<int> watchUnreadCount() {
    return remoteDataSource.watchUnreadCount();
  }

  @override
  Future<void> storeToken(String userId) async {
    await remoteDataSource.storeToken(userId);
  }

  @override
  Future<String?> getToken() async {
    return remoteDataSource.getToken();
  }
}
