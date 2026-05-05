import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.imageUrl,
    required super.type,
    required super.createdAt,
    super.isRead,
    super.actionType,
    super.actionData,
    super.metadata,
  });

  factory NotificationModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return NotificationModel(
      id: id,
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString(),
      type: _parseType(map['type']),
      createdAt: _parseCreatedAt(map['createdAt']),
      isRead: map['isRead'] == true,
        actionType: map['actionType']?.toString() ?? 'none',
      actionData: map['actionData']?.toString(),
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      if (actionType != null) 'actionType': actionType,
      if (actionData != null) 'actionData': actionData,
      if (metadata != null) 'metadata': metadata,
    };
  }

  static NotificationType _parseType(dynamic raw) {
    if (raw == null) return NotificationType.info;
    final value = raw.toString();
    for (final type in NotificationType.values) {
      if (type.name == value) return type;
    }
    return NotificationType.info;
  }

  static DateTime _parseCreatedAt(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true).toLocal();
    }
    return DateTime.now();
  }
}
