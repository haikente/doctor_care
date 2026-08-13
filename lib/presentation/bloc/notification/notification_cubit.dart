import 'dart:async';

import 'package:doctor_care/domain/entities/notification_entity.dart';
import 'package:doctor_care/domain/repositories/notification_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this.repository) : super(const NotificationInitial());

  final NotificationRepository repository;
  StreamSubscription<List<NotificationEntity>>? _subscription;

  void startListening() {
    _subscription?.cancel();
    emit(const NotificationLoading());

    _subscription = repository.watchNotifications().listen(
      (items) {
        final unreadCount = items.where((n) => !n.isRead).length;
        emit(NotificationLoaded(items, unreadCount: unreadCount));
      },
      onError: (e, stack) {
        print('Lỗi tải thông báo: $e');
        print(stack);
        emit(NotificationError('Tải thông báo thất bại: $e'));
      },
    );
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    emit(const NotificationInitial());
  }

  Future<void> refresh() async {
    try {
      emit(const NotificationLoading());
      final items = await repository.getNotifications();
      final unreadCount = items.where((n) => !n.isRead).length;
      emit(NotificationLoaded(items, unreadCount: unreadCount));
    } catch (e) {
      emit(NotificationError('Tải thông báo thất bại: $e'));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await repository.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await repository.markAllAsRead();
  }

  Future<void> deleteNotification(String notificationId) async {
    await repository.deleteNotification(notificationId);
  }

  Future<void> deleteAllNotifications() async {
    await repository.deleteAllNotifications();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
