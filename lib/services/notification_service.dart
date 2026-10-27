import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';

class NotificationService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('notifications');

  Future<void> send({
    required String recipientUid,
    required String type,
    required String title,
    required String body,
    String? projectId,
    String? relatedCollection,
    String? relatedDocId,
  }) {
    return _collection.add({
      'recipientUid': recipientUid,
      'type': type,
      'title': title,
      'body': body,
      'projectId': projectId,
      'relatedCollection': relatedCollection,
      'relatedDocId': relatedDocId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fire off a [send] for each recipient, without awaiting them one by one.
  Future<void> sendToMany({
    required List<String> recipientUids,
    required String type,
    required String title,
    required String body,
    String? projectId,
    String? relatedCollection,
    String? relatedDocId,
  }) {
    return Future.wait([
      for (final uid in recipientUids)
        send(
          recipientUid: uid,
          type: type,
          title: title,
          body: body,
          projectId: projectId,
          relatedCollection: relatedCollection,
          relatedDocId: relatedDocId,
        ),
    ]);
  }

  Future<void> markAsRead(String notificationId) {
    return _collection.doc(notificationId).update({'isRead': true});
  }

  /// Single `.where()` on recipientUid — sorted client-side, same
  /// composite-index reasoning as the rest of the app's services.
  Stream<List<AppNotification>> streamForUser(String uid) {
    return _collection.where('recipientUid', isEqualTo: uid).snapshots().map((snapshot) {
      final notifications = snapshot.docs.map(AppNotification.fromDoc).toList();
      notifications.sort((a, b) => _compareNewestFirst(a.createdAt, b.createdAt));
      return notifications;
    });
  }

  int _compareNewestFirst(Timestamp? a, Timestamp? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return b.compareTo(a);
  }
}
