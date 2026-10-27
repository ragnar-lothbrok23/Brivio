import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.projectId,
    required this.senderUid,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.sentAt,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatMessage(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      senderUid: data['senderUid'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      senderRole: data['senderRole'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: data['sentAt'] as Timestamp?,
    );
  }

  final String id;
  final String projectId;
  final String senderUid;
  final String senderName;
  final String senderRole;
  final String text;
  final Timestamp? sentAt;
}
