import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/data/models/notification_model.dart';
import 'package:doctor_care/domain/entities/notification_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    int limit = 20,
    String? lastDocId,
  });

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

  Stream<List<NotificationModel>> watchNotifications();

  Stream<int> watchUnreadCount();

  Future<void> storeToken(String userId);

  Future<String?> getToken();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  static const _tokenKey = 'device_push_token';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  CollectionReference<Map<String, dynamic>> _collectionForUser(String uid) {
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  @override
  Future<List<NotificationModel>> getNotifications({
    int limit = 20,
    String? lastDocId,
  }) async {
    final collection = _collection;
    if (collection == null) return [];

    Query<Map<String, dynamic>> query = collection
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocId != null && lastDocId.isNotEmpty) {
      final lastDoc = await collection.doc(lastDocId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snap = await query.get();
    return snap.docs
        .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
        .toList();
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
    final targets = <String>[];

    if (userIds != null) {
      for (final userId in userIds) {
        final trimmed = userId.trim();
        if (trimmed.isNotEmpty) targets.add(trimmed);
      }
    }

    if (targets.isEmpty) {
      final uid = _auth.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        targets.add(uid);
      }
    }

    if (targets.isEmpty) return;

    final payload = <String, dynamic>{
      'title': title,
      'body': body,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      if (actionType != null) 'actionType': actionType,
      if (actionData != null) 'actionData': actionData,
      if (topic != null) 'topic': topic,
    };

    for (final userId in targets) {
      await _collectionForUser(userId).add(payload);
    }
  }

  @override
  Future<void> sendTopicNotification({
    required String title,
    required String body,
    String? imageUrl,
    required NotificationType type,
    required String topic,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'body': body,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'topic': topic,
    };

    await _firestore
        .collection('topics')
        .doc(topic)
        .collection('notifications')
        .add(payload);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final collection = _collection;
    if (collection == null) return;
    await collection.doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead() async {
    final collection = _collection;
    if (collection == null) return;

    final snap = await collection.where('isRead', isEqualTo: false).get();
    if (snap.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<int> getUnreadCount() async {
    final collection = _collection;
    if (collection == null) return 0;
    final snap = await collection.where('isRead', isEqualTo: false).get();
    return snap.docs.length;
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final collection = _collection;
    if (collection == null) return;
    await collection.doc(notificationId).delete();
  }

  @override
  Future<void> deleteAllNotifications() async {
    final collection = _collection;
    if (collection == null) return;

    final snap = await collection.get();
    if (snap.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    final collection = _collection;
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Stream<int> watchUnreadCount() {
    final collection = _collection;
    if (collection == null) return Stream.value(0);

    return collection
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  @override
  Future<void> storeToken(String userId) async {
    final token = await getToken();
    if (token == null || token.isEmpty) return;

    await _firestore.collection('users').doc(userId).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
