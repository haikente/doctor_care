import 'package:equatable/equatable.dart';

enum NotificationType {
  info,
  warning,
  error,
  success,
  promotion,
  system,
}
class NotificationEntity extends Equatable{
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? actionType;
  final String? actionData;
  final Map<String, dynamic>? metadata;

  const NotificationEntity({
    required this.id, 
    required this.title, 
    required this.body, 
    this.imageUrl, 
    required this.type, 
    required this.createdAt, 
    this.isRead = false, 
    this.actionType = "none", 
    this.actionData, 
    this.metadata
    });

    NotificationEntity copyWith({
      String? id,
      String? title,
      String? body,
      String? imageUrl,
      NotificationType? type,
      DateTime? createdAt,
      bool? isRead,
      String? actionType,
      String? actionData,
      Map<String, dynamic>? metadata,
    }) {
      return NotificationEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        imageUrl: imageUrl ?? this.imageUrl,
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
        isRead: isRead ?? this.isRead,
        actionType: actionType ?? this.actionType,
        actionData: actionData ?? this.actionData,
        metadata: metadata ?? this.metadata,
      );
    }

    @override
      List<Object?> get props => [id, title, body, imageUrl, type, createdAt, isRead, actionType, actionData, metadata];
}