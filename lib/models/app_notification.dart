import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.recipientUid,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.projectId,
    this.relatedCollection,
    this.relatedDocId,
  });

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppNotification(
      id: doc.id,
      recipientUid: data['recipientUid'] as String? ?? '',
      type: data['type'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: data['createdAt'] as Timestamp?,
      projectId: data['projectId'] as String?,
      relatedCollection: data['relatedCollection'] as String?,
      relatedDocId: data['relatedDocId'] as String?,
    );
  }

  final String id;
  final String recipientUid;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final Timestamp? createdAt;
  final String? projectId;
  final String? relatedCollection;
  final String? relatedDocId;
}
